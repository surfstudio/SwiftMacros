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
        static let method = "produce"
        static let privateMethod = "produceProduct"
    }

    // MARK: - Macro

    static public func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try checkDeclOfProductProduceMethod(in: declaration)
        return try createProductDecls(node: node, for: declaration)
    }
}

// MARK: - Private Methods

private extension SingletonFactoryMacro {

    static func checkDeclOfProductProduceMethod(in declaration: DeclGroupSyntax) throws {
        let privateModifier = DeclModifierSyntax(name: .keyword(.private))
        if
            let produceProductMethod = getProduceProductMethod(from: declaration),
            !produceProductMethod.modifiers.contains(where: { $0.name.text == privateModifier.name.text }) {
            throw MacroError.custom("produceProduct method should be private")
        }
    }

    static func getProduceProductMethod(from declaration: DeclGroupSyntax) -> FunctionDeclSyntax? {
        let expectedModifiersWithPrivate = DeclModifierListSyntax([
            DeclModifierSyntax(name: .keyword(.private)),
            DeclModifierSyntax(name: .keyword(.static))
        ])
        let expectedModifiers = DeclModifierListSyntax([DeclModifierSyntax(name: .keyword(.static))])
        let expectedReturnType = IdentifierTypeSyntax(name: .identifier(Names.typealias))
        let expectedSignature = FunctionSignatureSyntax(returnClause: ReturnClauseSyntax(type: expectedReturnType))
        let expectedName = TokenSyntax(.identifier(Names.privateMethod))

        return declaration.memberBlock.functionDecls.filter {
            (Comparator.compare($0.modifiers, expectedModifiersWithPrivate) ||
             Comparator.compare($0.modifiers, expectedModifiers)) &&
            Comparator.compare($0.signature, expectedSignature) &&
            Comparator.compare($0.name, expectedName)
        }.first
    }

    static func createProductDecls(
        node: AttributeSyntax,
        for declaration: DeclGroupSyntax
    ) throws -> [DeclSyntax] {
        let attributeGenericType = try getGenericType(of: node)
        let productTypeAlias = createProductTypeAlias(for: attributeGenericType)
        let productVariable = createProductVariable()
        let produceMethod = createProduceMethod()
        return [
            DeclSyntax(productTypeAlias),
            DeclSyntax(productVariable),
            DeclSyntax(produceMethod)
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

    static func createProduceMethod() -> FunctionDeclSyntax {
        let staticModifier = DeclModifierSyntax(name: .init(.keyword(.static)))
        let returnType = IdentifierTypeSyntax(name: .identifier(Names.typealias))
        let signature = FunctionSignatureSyntax(returnClause: ReturnClauseSyntax(type: returnType))
        let body = createProduceMethodBody()
        return .init(
            modifiers: [staticModifier],
            name: .identifier(Names.method),
            signature: signature,
            body: body
        )
    }

    static func createProduceMethodBody() -> CodeBlockSyntax {
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
            calledExpression: DeclReferenceExprSyntax(baseName: .identifier(Names.privateMethod))
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
