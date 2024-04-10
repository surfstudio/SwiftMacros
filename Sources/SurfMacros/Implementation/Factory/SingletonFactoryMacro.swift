import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SurfMacrosSupport

public struct SingletonFactoryMacro: MemberMacro {

    // MARK: - Names

    private enum Names {
        static let `typealias` = "Product"
        static let variable = "product"
        static let `func` = "produce"
        static let privateFunc = "produceProduct"
    }

    // MARK: - Macro

    static public func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try checkDeclOfProductProduceFunc(in: declaration)
        return try createProductDecls(node: node, for: declaration)
    }

}

// MARK: - Private Methods

private extension SingletonFactoryMacro {

    static func checkDeclOfProductProduceFunc(in declaration: DeclGroupSyntax) throws {
        guard let produceProductFunc = getProduceProductFunc(from: declaration) else {
            return
        }
        guard produceProductFunc.modifiers.contains(where: { $0.name.text == "private" }) else {
            throw DeclarationError.missedModifier(decl: .func, declName: Names.privateFunc, expected: .private)
        }
    }

    static func getProduceProductFunc(from declaration: DeclGroupSyntax) -> FunctionDeclSyntax? {
        let expectedFunc = createExpectedProduceProductFunc(withPrivateModifier: false)
        let expectedFuncWithPrivate = createExpectedProduceProductFunc(withPrivateModifier: true)
        return declaration.memberBlock.functionDecls.filter {
            compare($0, expectedFunc) || compare($0, expectedFuncWithPrivate)
        }.first
    }

    static func createExpectedProduceProductFunc(withPrivateModifier: Bool) -> FunctionDeclSyntax {
        var modifiers = [DeclModifierSyntax(name: .keyword(.static))]
        if withPrivateModifier {
            modifiers.append(.init(name: .keyword(.private)))
        }
        let returnType = IdentifierTypeSyntax(name: .identifier(Names.typealias))
        let signature = FunctionSignatureSyntax(returnClause: ReturnClauseSyntax(type: returnType))
        let name = TokenSyntax(.identifier(Names.privateFunc))
        return .init(
            modifiers: DeclModifierListSyntax(modifiers),
            name: name,
            signature: signature
        )
    }

    static func createProductDecls(
        node: AttributeSyntax,
        for declaration: DeclGroupSyntax
    ) throws -> [DeclSyntax] {
        let attributeGenericType = try getGenericType(of: node)
        let productTypeAlias = createProductTypeAlias(for: attributeGenericType)
        let productVariable = createProductVariable()
        let produceFunc = createProduceFunc()
        return [
            DeclSyntax(productTypeAlias),
            DeclSyntax(productVariable),
            DeclSyntax(produceFunc)
        ]
    }

    static func getGenericType(of attribute: AttributeSyntax) throws -> TypeSyntaxProtocol {
        guard let identifier = attribute.attributeName.as(IdentifierTypeSyntax.self) else {
            throw SyntaxError.failedCastTo(type: IdentifierTypeSyntax.self)
        }
        guard let genericArgumentClause = identifier.genericArgumentClause else {
            throw MacroError.missedGenericArgumentClause
        }
        guard let genericArgument = genericArgumentClause.arguments.first else {
            throw MacroError.emptyGenericArgumentList
        }
        return genericArgument.argument
    }

    static func createProductTypeAlias(for type: TypeSyntaxProtocol) -> TypeAliasDeclSyntax {
        return .init(name: .identifier(Names.typealias), initializer: .init(value: type))
    }

    static func createProductVariable() -> VariableDeclSyntax {
        let staticModifier = DeclModifierSyntax(name: .init(.keyword(.static)))
        let privateModifier = DeclModifierSyntax(name: .init(.keyword(.private)))
        let type = OptionalTypeSyntax(wrappedType: IdentifierTypeSyntax(name: .identifier(Names.typealias)))
        let patternBinding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: .identifier(Names.variable)),
            typeAnnotation: .init(type: type)
        )
        return .init(
            modifiers: [privateModifier, staticModifier],
            bindingSpecifier: .init(.keyword(.var)),
            bindings: [patternBinding]
        )
    }

    static func createProduceFunc() -> FunctionDeclSyntax {
        let staticModifier = DeclModifierSyntax(name: .init(.keyword(.static)))
        let returnType = IdentifierTypeSyntax(name: .identifier(Names.typealias))
        let signature = FunctionSignatureSyntax(returnClause: ReturnClauseSyntax(type: returnType))
        let body = createProduceFuncBody()
        return .init(
            modifiers: [staticModifier],
            name: .identifier(Names.func),
            signature: signature,
            body: body
        )
    }

    static func createProduceFuncBody() -> CodeBlockSyntax {
        let ifElseExpr = createIfElseExpr()
        let statement = CodeBlockItemSyntax(item: .expr(ExprSyntax(ifElseExpr)))
        return .init(statements: [statement])
    }

    static func createIfElseExpr() -> IfExprSyntax {
        let ifCondition = createIfCondition()
        let ifBody = createIfBody()
        let elseBody = createElseBody()
        return .init(
            conditions: [ifCondition],
            body: ifBody,
            elseBody: .codeBlock(elseBody)
        )
    }

    static func createIfCondition() -> ConditionElementSyntax {
        let initializer = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .keyword(.Self)),
            declName: DeclReferenceExprSyntax(baseName: .identifier(Names.variable))
        )
        let condition = OptionalBindingConditionSyntax(
            pattern: IdentifierPatternSyntax(identifier: .identifier(Names.variable)),
            initializer: InitializerClauseSyntax(value: initializer)
        )
        return .init(condition: .optionalBinding(condition))
    }

    static func createIfBody() -> CodeBlockSyntax {
        let returnStatement = createReturnProductStatement()
        let statement = CodeBlockItemSyntax(item: .stmt(StmtSyntax(returnStatement)))
        return .init(statements: [statement])
    }

    static func createReturnProductStatement() -> ReturnStmtSyntax {
        return .init(expression: DeclReferenceExprSyntax(baseName: .identifier(Names.variable)))
    }

    static func createElseBody() -> CodeBlockSyntax {
        let productVariable = createElseBodyProductVariable()
        let productAssigment = createElseBodyProductAssigment()
        let returnStatement = createReturnProductStatement()
        return .init(
            statements: [
                CodeBlockItemSyntax(item: .decl(DeclSyntax(productVariable))),
                CodeBlockItemSyntax(item: .expr(ExprSyntax(productAssigment))),
                CodeBlockItemSyntax(item: .stmt(StmtSyntax(returnStatement)))
            ]
        )
    }

    static func createElseBodyProductVariable() -> VariableDeclSyntax {
        let produceProductFunctionCall = FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(baseName: .identifier(Names.privateFunc))
        )
        let binding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: .identifier(Names.variable)),
            initializer: InitializerClauseSyntax(value: produceProductFunctionCall)
        )
        return .init(bindingSpecifier: .keyword(.let), bindings: [binding])
    }

    static func createElseBodyProductAssigment() -> InfixOperatorExprSyntax {
        let leftOperand = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .keyword(.Self)),
            declName: DeclReferenceExprSyntax(baseName: .identifier(Names.variable))
        )
        let rightOperand = DeclReferenceExprSyntax(baseName: .identifier(Names.variable))
        return .init(leftOperand: leftOperand, operator: AssignmentExprSyntax(), rightOperand: rightOperand)
    }

}

// it would take much time to write the complete implementation of compare functions for each type
// so, it's been decided to place compressions nedeed only for this macro here

private func compare(_ lhs: FunctionDeclSyntax, _ rhs: FunctionDeclSyntax) -> Bool {
    return compare(lhs.modifiers,rhs.modifiers) &&
        compare(lhs.signature, rhs.signature) &&
        compare(lhs.name, rhs.name)
}

private func compare(_ lhs: DeclModifierListSyntax, _ rhs: DeclModifierListSyntax) -> Bool {
    return lhs.count == rhs.count && lhs.indices.map { compare(lhs[$0], rhs[$0]) }.filter { !$0 }.count == .zero
}

private func compare(_ lhs: DeclModifierSyntax, _ rhs: DeclModifierSyntax) -> Bool {
    return compare(lhs.name, rhs.name)
}

private func compare(_ lhs: FunctionSignatureSyntax, _ rhs: FunctionSignatureSyntax) -> Bool {
    guard
        let lhsReturnClause = lhs.returnClause,
        let rhsReturnClause = rhs.returnClause
    else {
        return false
    }
    return compare(lhsReturnClause, rhsReturnClause)
}

private func compare(_ lhs: ReturnClauseSyntax, _ rhs: ReturnClauseSyntax) -> Bool {
    guard
        let lhsIdentifier = lhs.type.as(IdentifierTypeSyntax.self),
        let rhsIdentifier = rhs.type.as(IdentifierTypeSyntax.self)
    else {
        return false
    }
    return compare(lhsIdentifier, rhsIdentifier)
}

private func compare(_ lhs: IdentifierTypeSyntax, _ rhs: IdentifierTypeSyntax) -> Bool {
    return compare(lhs.name, rhs.name)
}

private func compare(_ lhs: TokenSyntax, _ rhs: TokenSyntax) -> Bool {
    return lhs.kind == rhs.kind && lhs.presence == rhs.presence
}
