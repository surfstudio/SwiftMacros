import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SurfMacrosSupport

public struct MulticastMacro: PeerMacro {

    // MARK: - Names

    private enum Names {

        static let variable = "signals"
        static let arrayBuilder = "ArrayBuilder"
        static let dollarIdentifier = "$0"
        static let forEach = "forEach"

        static var `protocol` = ""

        static var `class`: String {
            return `protocol` + "s"
        }

    }

    // MARK: - Macro

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw DeclarationError.wrongAttaching(expected: .protocol)
        }
        try checkProtocolDeclaration(protocolDecl)
        Names.protocol = protocolDecl.name.text
        let protocolFuncDecls = protocolDecl.memberBlock.functionDecls
        let signalsClass = createSignalsClass(with: protocolFuncDecls)
        return [.init(signalsClass)]
    }

}

// MARK: - Checks

private extension MulticastMacro {

    static func checkProtocolDeclaration(_ declaration: ProtocolDeclSyntax) throws {
        try checkMembers(of: declaration)
    }

}

// MARK: - Creations

private extension MulticastMacro {

    static func createSignalsClass(with protocolFuncDecls: [FunctionDeclSyntax]) -> ClassDeclSyntax {
        let publicModifier = createPublicModifier()
        let finalModifier = DeclModifierSyntax(name: .keyword(.final))
        let signalProtocolIdentifier = createProtocolIdentifier()
        let memberBlock = createSignalsClassMemberBlock(with: protocolFuncDecls)
        return .init(
            modifiers: [publicModifier, finalModifier],
            name: .identifier(Names.class),
            inheritanceClause: .init(inheritedTypes: [.init(type: signalProtocolIdentifier)]),
            memberBlock: memberBlock
        )
    }

}

// MARK: - Private Methods

private extension MulticastMacro {

    static func checkMembers(of decl: ProtocolDeclSyntax) throws {
        try decl.memberBlock.members.forEach { member in
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self),
               !isAppropriateFuncDecl(funcDecl) {
                throw MulticastError.wrongFunctionFormat
            } else if member.decl.is(VariableDeclSyntax.self) {
                throw DeclarationError.unexpectedVariable
            } else if member.decl.is(AssociatedTypeDeclSyntax.self) {
                throw DeclarationError.unexpectedAssociatedType
            }
        }
    }

    static func isAppropriateFuncDecl(_ decl: FunctionDeclSyntax) -> Bool {
        if !decl.modifiers.contains(where: isStatic),
           case .identifier = decl.name.tokenKind,
           decl.signature.returnClause == nil,
           decl.signature.effectSpecifiers == nil,
           decl.genericWhereClause == nil,
           decl.genericParameterClause == nil,
           decl.attributes.isEmpty {
            return true
        }
        return false
    }

    static func isStatic(_ modifier: DeclModifierSyntax) -> Bool {
        modifier.name.tokenKind == .keyword(.static)
    }

    static func createPublicModifier() -> DeclModifierSyntax {
        return .init(name: .keyword(.public))
    }

    static func createProtocolIdentifier() -> IdentifierTypeSyntax {
        return .init(name: .identifier(Names.protocol))
    }

    static func createSignalsClassMemberBlock(with protocolFuncDecls: [FunctionDeclSyntax]) -> MemberBlockSyntax {
        let itemList = MemberBlockItemListSyntax {
            createSignalsVariable()
            createSignalsClassInit()
            for funcDecl in protocolFuncDecls {
                transformIntoSignalsClassFuncDecl(funcDecl)
            }
        }
        return .init(members: itemList)
    }

    static func createSignalsVariable() -> VariableDeclSyntax {
        let privateModifier = DeclModifierSyntax(name: .keyword(.private))
        let signalsArrayType = createArrayOfSignalsType()
        let patternBinding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: .identifier(Names.variable)),
            typeAnnotation: .init(type: signalsArrayType)
        )
        return .init(modifiers: [privateModifier], bindingSpecifier: .keyword(.let), bindings: [patternBinding])
    }

    static func createArrayOfSignalsType() -> ArrayTypeSyntax {
        return .init(element: createProtocolIdentifier())
    }

    static func createSignalsClassInit() -> InitializerDeclSyntax {
        let publicModifier = createPublicModifier()
        let signature = createSignalsClassInitSignature()
        let body = createSignalsClassInitBody()
        return .init(modifiers: [publicModifier], signature: signature, body: body)
    }

    static func createSignalsClassInitSignature() -> FunctionSignatureSyntax {
        let attributeArgumentGenericType = createProtocolIdentifier()
        let attributeName = IdentifierTypeSyntax(
            name: .identifier(Names.arrayBuilder),
            genericArgumentClause: .init(arguments: [.init(argument: attributeArgumentGenericType)])
        )
        let returnTypeOfInputFunction = createArrayOfSignalsType()
        let inputFunctionType = FunctionTypeSyntax(
            parameters: [],
            returnClause: .init(type: returnTypeOfInputFunction)
        )
        let arrayBuilderParameter = FunctionParameterSyntax(
            attributes: [.attribute(.init(attributeName: attributeName))],
            firstName: .wildcardToken(),
            secondName: .identifier(Names.variable),
            type: inputFunctionType
        )
        return .init(parameterClause: .init(parameters: [arrayBuilderParameter]))
    }

    static func createSignalsClassInitBody() -> CodeBlockSyntax {
        let leftOperand = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .keyword(.`self`)),
            declName: .init(baseName: .identifier(Names.variable))
        )
        let rightOperand = FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(baseName: .identifier(Names.variable))
        )
        let infixOperatorExpr = InfixOperatorExprSyntax(
            leftOperand: leftOperand,
            operator: AssignmentExprSyntax(),
            rightOperand: rightOperand
        )
        return .init(statements: [.init(item: .expr(.init(infixOperatorExpr)))])
    }

    static func transformIntoSignalsClassFuncDecl(_ funcDecl: FunctionDeclSyntax) -> FunctionDeclSyntax {
        let funcCall = transformIntoCall(functionDecl: funcDecl)
        let trailingClosure = ClosureExprSyntax(statements: [.init(item: .expr(.init(funcCall)))])
        let forEachCall = FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: .identifier(Names.variable)),
                declName: .init(baseName: .identifier(Names.forEach))
            ),
            trailingClosure: trailingClosure,
            argumentsBuilder: {}
        )
        let publicModifier = createPublicModifier()

        var signalsClassFuncDecl = funcDecl.trimmed
        signalsClassFuncDecl.body = .init(statements: [.init(item: .expr(.init(forEachCall)))])
        signalsClassFuncDecl.modifiers = [publicModifier]
        return signalsClassFuncDecl
    }

    static func transformIntoCall(functionDecl: FunctionDeclSyntax) -> FunctionCallExprSyntax {
        let calledExpression = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .dollarIdentifier(Names.dollarIdentifier)),
            declName: .init(baseName: functionDecl.name)
        )
        let arguments = LabeledExprListSyntax {
            for parameter in functionDecl.signature.parameterClause.parameters {
                LabeledExprSyntax(
                    label: parameter.firstName.tokenKind == .wildcard ? nil : parameter.firstName,
                    expression: DeclReferenceExprSyntax(baseName: parameter.secondName ?? parameter.firstName)
                )
            }
        }
        return .init(calledExpression: calledExpression, arguments: arguments)
    }

}
