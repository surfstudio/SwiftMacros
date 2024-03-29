import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SurfMacrosSupport

public struct PreviewsMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let inputClosureBody = try getInputClosure(from: node).statements
        let previewsVariable = createPreviewsVariable(getterBody: inputClosureBody)
        let structName = context.makeUniqueName("View")
        let previewsStruct = createPreviewsStruct(name: structName, previewsVariable: previewsVariable)
        return [DeclSyntax(previewsStruct)]
    }

    private static func getInputClosure(
        from node: some FreestandingMacroExpansionSyntax
    ) throws -> ClosureExprSyntax {
        if let closure = node.trailingClosure {
            return closure
        }
        guard let firstArgument = node.argumentList.first else {
            throw MacroError.emptyArgumentsList
        }
        guard let closure = firstArgument.expression.as(ClosureExprSyntax.self) else {
            throw SyntaxError.failedCastTo(type: ClosureExprSyntax.self)
        }
        return closure
    }

    private static func createPreviewsVariable(getterBody: CodeBlockItemListSyntax) -> VariableDeclSyntax {
        let type = SomeOrAnyTypeSyntax(
            someOrAnySpecifier: .keyword(.some),
            constraint: IdentifierTypeSyntax(name: .identifier("View"))
        )
        let patternBinding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: "previews"),
            typeAnnotation: .init(type: type),
            accessorBlock: .init(accessors: .getter(getterBody))
        )
        let staticModifier = DeclModifierSyntax(name: .init(.keyword(.static)))
        return .init(
            modifiers: [staticModifier],
            bindingSpecifier: .init(.keyword(.var)),
            bindings: [patternBinding]
        )
    }

    private static func createPreviewsStruct(
        name: TokenSyntax,
        previewsVariable: VariableDeclSyntax
    ) -> StructDeclSyntax {
        let previewProviderProtocol = IdentifierTypeSyntax(name: .init(.identifier("PreviewProvider")))
        let previewProviderConformance = InheritanceClauseSyntax(
            inheritedTypes: [InheritedTypeSyntax(type: previewProviderProtocol)]
        )
        return .init(
            name: name,
            inheritanceClause: previewProviderConformance,
            memberBlock: MemberBlockSyntax(members: [MemberBlockItemSyntax(decl: previewsVariable)])
        )
    }
}
