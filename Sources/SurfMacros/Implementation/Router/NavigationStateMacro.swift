import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SurfMacrosSupport

public struct NavigationStateMacro: MemberMacro {

    // MARK: - Names

    private enum Names {
        enum Navigation {
            static let type = "NavigationPath"
            static let variable = "navigationPath"
        }

        enum Initial {
            static let variable = "initial"
        }

        enum Signals {

            enum Destination {
                static let type = "Destination"
                static let argument = "destination"
            }

            static let push = "push"
            static let pop = "pop"
            static let popToRoot = "popToRoot"

            static let append = "append"
            static let removeLast = "removeLast"
        }
    }

    // MARK: - Macro

    static public func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try checkDeclarationType(declaration: declaration)
        return createNavigationStateMacroDecls()
    }
}

// MARK: - Private Methods

private extension  NavigationStateMacro {

    static func checkDeclarationType(declaration: some DeclGroupSyntax) throws {
        if declaration.as(StructDeclSyntax.self) == nil {
            throw MacroError.error("Can be attached to structs only")
        }
    }

    static func createNavigationStateMacroDecls() -> [DeclSyntax] {
        let navigationPathVariable = createNavigationPathVariable()
        let initialVariable = createInitialVariable()
        let pushFunc = createPushFunc()
        let popFunc = createPopFunc()
        let popToRootFunc = createPopToRootFunc()

        return [
            DeclSyntax(navigationPathVariable),
            DeclSyntax(initialVariable),
            DeclSyntax(pushFunc),
            DeclSyntax(popFunc),
            DeclSyntax(popToRootFunc)
        ]
    }

    static func createNavigationPathVariable() -> VariableDeclSyntax {
        let patternBinding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: .identifier(Names.Navigation.variable)),
            typeAnnotation: .init(type: IdentifierTypeSyntax(name: .identifier(Names.Navigation.type)))
        )
        return .init(bindingSpecifier: .keyword(.var), bindings: [patternBinding])
    }

    static func createInitialVariable() -> VariableDeclSyntax {
        let staticModifier = DeclModifierSyntax(name: .keyword(.static))
        let accessorBlock = createInitialVariableAccessorBlock()
        let patternBinding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: .identifier(Names.Initial.variable)),
            typeAnnotation: .init(type: IdentifierTypeSyntax(name: .keyword(.Self))),
            accessorBlock: accessorBlock
        )
        return .init(
            modifiers: [staticModifier],
            bindingSpecifier: .keyword(.var),
            bindings: [patternBinding]
        )
    }

    static func createInitialVariableAccessorBlock() -> AccessorBlockSyntax {
        let initMemberAccessExpr = createInitMemberAccessExpr()
        let labeledExpr = LabeledExprSyntax(
            label: .identifier(Names.Navigation.variable),
            colon: .colonToken(),
            expression: FunctionCallExprSyntax(calledExpression: initMemberAccessExpr)
        )
        let functionCallExpr = FunctionCallExprSyntax(
            calledExpression: initMemberAccessExpr,
            arguments: [labeledExpr]
        )
        return .init(accessors: .getter([.init(item: .expr(ExprSyntax(functionCallExpr)))]))
    }

    static func createInitMemberAccessExpr() -> MemberAccessExprSyntax {
        return .init(declName: .init(baseName: .keyword(.`init`)))
    }

    static func createPushFunc() -> FunctionDeclSyntax {
        let destinationParameter = FunctionParameterSyntax(
            firstName: .identifier(Names.Signals.Destination.argument),
            type: IdentifierTypeSyntax(name: .identifier(Names.Signals.Destination.type))
        )
        let functionalCallExpr = createFunctionCallExpr(
            baseName: .identifier(Names.Navigation.variable),
            declName: .identifier(Names.Signals.append),
            argumentName: .identifier(Names.Signals.Destination.argument)
        )
        return createMutatingFunc(
            name: .identifier(Names.Signals.push),
            parameters: [destinationParameter],
            body: createMutatingFuncBody(expression: functionalCallExpr)
        )
    }

    static func createPopFunc() -> FunctionDeclSyntax {
        let functionalCallExpr = createFunctionCallExpr(
            baseName: .identifier(Names.Navigation.variable),
            declName: .identifier(Names.Signals.removeLast)
        )
        return createMutatingFunc(
            name: .identifier(Names.Signals.pop),
            parameters: [],
            body: createMutatingFuncBody(expression: functionalCallExpr)
        )
    }

    static func createPopToRootFunc() -> FunctionDeclSyntax {
        let infixOperatorExpr = createPopToRootInfixOperatorExpr()
        return createMutatingFunc(
            name: .identifier(Names.Signals.popToRoot),
            body: createMutatingFuncBody(expression: infixOperatorExpr)
        )
    }

    static func createPopToRootInfixOperatorExpr() -> InfixOperatorExprSyntax {
        return .init(
            leftOperand: DeclReferenceExprSyntax(baseName: .identifier(Names.Navigation.variable)),
            operator: AssignmentExprSyntax(),
            rightOperand: FunctionCallExprSyntax(calledExpression: createInitMemberAccessExpr())
        )
    }

    static func createFunctionCallExpr(
        baseName: TokenSyntax,
        declName: TokenSyntax,
        argumentName: TokenSyntax? = nil
    ) -> FunctionCallExprSyntax {
        let memberAccessExpr = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: baseName),
            declName: .init(baseName: declName)
        )
        let arguments: LabeledExprListSyntax
        if let argumentName {
            arguments = [.init(expression: DeclReferenceExprSyntax(baseName: argumentName))]
        } else {
            arguments = []
        }
        return .init(calledExpression: memberAccessExpr, arguments: arguments)
    }

    static func createMutatingFuncBody(expression: ExprSyntaxProtocol) -> CodeBlockSyntax {
        return .init(statements: [.init(item: .expr(ExprSyntax(expression)))])
    }

    static func createMutatingFunc(
        name: TokenSyntax,
        parameters: FunctionParameterListSyntax = [],
        body: CodeBlockSyntax
    ) -> FunctionDeclSyntax {
        let mutatingModifier = DeclModifierSyntax(name: .keyword(.mutating))
        let signature = FunctionSignatureSyntax(parameterClause: .init(parameters: parameters))
        return .init(modifiers: [mutatingModifier], name: name, signature: signature, body: body)
    }

}
