import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SurfMacrosSupport

public struct PreviewsMacro: DeclarationMacro {

    // MARK: -  Names

    private enum Names {
        static let variable = "previews"
        static let type = "View"
        static let `protocol` = "PreviewProvider"
    }

    // MARK: - Macro
    
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let inputClosureBody = try getInputClosure(from: node).statements
        let previewsVariable = createPreviewsVariable(getterBody: inputClosureBody)
        let structName = context.makeUniqueName(Names.type)
        let previewsStruct = createPreviewsStruct(name: structName, previewsVariable: previewsVariable)
        return [DeclSyntax(previewsStruct)]
    }

}

// MARK: - Private Methods

private extension PreviewsMacro {
 
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
            constraint: IdentifierTypeSyntax(name: .identifier(Names.type))
        )
        let patternBinding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: .identifier(Names.variable)),
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
        let previewProviderProtocol = IdentifierTypeSyntax(name: .init(.identifier(Names.protocol)))
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
