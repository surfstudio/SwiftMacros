import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SurfMacrosSupport

public struct CompletionHandlerMacro: PeerMacro {

    // MARK: - Names

    private enum Names {
        static let completion = "completion"
        static let emptyClosure = "EmptyClosure"

        static var `protocol` = ""

        static var `class`: String {
            return `protocol` + "Handler"
        }

    }

    // MARK: - Macro

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw DeclarationError.wrongAttaching(expected: [.protocol])
        }
        Names.protocol = protocolDecl.name.text
        try SignalsMacroGroupSupport.checkProtocolDeclaration(protocolDecl)
        let protocolFuncDecls = protocolDecl.memberBlock.functionDecls
        let handlerClass = createHandlerClass(with: protocolFuncDecls)
        return [.init(handlerClass)]
    }

}

// MARK: - Creations

private extension CompletionHandlerMacro {

    static func createHandlerClass(with protocolFuncDecls: [FunctionDeclSyntax]) -> ClassDeclSyntax {
        let publicModifier = DeclModifierSyntax(name: .keyword(.public))
        let protocolIdentifier = createProtocolIdentifier()
        let memberBlock = createMemberBlock(with: protocolFuncDecls)
        return .init(
            modifiers: [publicModifier],
            name: .identifier(Names.class),
            inheritanceClause: .init(inheritedTypes: [.init(type: protocolIdentifier)]),
            memberBlock: memberBlock
        )
    }

    static func createProtocolIdentifier() -> IdentifierTypeSyntax {
        return .init(name: .identifier(Names.protocol))
    }

    static func createMemberBlock(with protocolFuncDecls: [FunctionDeclSyntax]) -> MemberBlockSyntax {
        let itemList = MemberBlockItemListSyntax {
            createCompletionProperty()
            createInit()
            for funcDecl in protocolFuncDecls {
                SignalsMacroGroupSupport.createFuncDecl(
                    from: funcDecl,
                    with: createFuncBody(),
                    modifiers: [.init(name: .keyword(.public))]
                )
            }
        }
        return .init(members: itemList)
    }

    static func createCompletionProperty() -> VariableDeclSyntax {
        let privateModifier = DeclModifierSyntax(name: .keyword(.private))
        let type = createCompletionType()
        let patternBinding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: .identifier(Names.completion)),
            typeAnnotation: .init(type: type)
        )
        return .init(
            modifiers: [privateModifier],
            bindingSpecifier: .keyword(.let),
            bindings: [patternBinding]
        )
    }

    static func createInit() -> InitializerDeclSyntax {
        let publicModifier = DeclModifierSyntax(name: .keyword(.public))
        let signature = createInitSignature()
        let body = createInitBody()
        return .init(modifiers: [publicModifier], signature: signature, body: body)
    }

    static func createInitSignature() -> FunctionSignatureSyntax {
        let type = createCompletionType()
        let defaultNil = InitializerClauseSyntax(value: NilLiteralExprSyntax())
        let completionParameter = FunctionParameterSyntax(
            firstName: .identifier(Names.completion),
            type: type,
            defaultValue: defaultNil
        )
        return .init(parameterClause: .init(parameters: [completionParameter]))
    }

    static func createInitBody() -> CodeBlockSyntax {
        let selfCompletion = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .keyword(.`self`)),
            declName: .init(baseName: .identifier(Names.completion))
        )
        let completion = DeclReferenceExprSyntax(baseName: .identifier(Names.completion))
        let assigmentOperator = InfixOperatorExprSyntax(
            leftOperand: selfCompletion,
            operator: AssignmentExprSyntax(),
            rightOperand: completion
        )
        return .init(statements: [.init(item: .expr(.init(assigmentOperator)))])
    }

    static func createCompletionType() -> TypeSyntaxProtocol {
        return OptionalTypeSyntax(wrappedType: IdentifierTypeSyntax(name: .identifier(Names.emptyClosure)))
    }

    static func createFuncBody() -> CodeBlockSyntax {
        let completion = DeclReferenceExprSyntax(baseName: .identifier(Names.completion))
        let completionCall = FunctionCallExprSyntax(
            calledExpression: OptionalChainingExprSyntax(expression: completion)
        )
        return .init(statements: [.init(item: .expr(.init(completionCall)))])
    }

}
