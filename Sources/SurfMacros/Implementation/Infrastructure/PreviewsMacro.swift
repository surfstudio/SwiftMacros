import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PreviewsMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let closureBodyDesc = getArgumentClosure(from: node).statements.description
        let varDeclSyntax = try VariableDeclSyntax("static var previews: some View { \(raw: closureBodyDesc) }")
//        let structName = getViewName(from: node, in: context)
        let structDeclSyntax = try StructDeclSyntax("fileprivate struct Content_Previews: PreviewProvider") {
            varDeclSyntax
        }
        return [DeclSyntax(structDeclSyntax)]
    }

    private static func getArgumentClosure(from node: some FreestandingMacroExpansionSyntax) -> ClosureExprSyntax {
        if let closure = node.trailingClosure {
            return closure
        } else if let closure = node.argumentList.first?.expression.as(ClosureExprSyntax.self) {
            return closure
        } else {
            fatalError("compiler bug: the macro does not have any arguments or a trailing closure")
        }
    }

    private static func getViewName(
        from node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> String {
        guard let fileDesc = context.location(of: node)?.file.description else {
            fatalError("compiler bug: cannot get location of the node")
        }
        guard let fileName = fileDesc.components(separatedBy: "/").last else {
            fatalError("compiler bug: cannot get name of the current file")
        }
        guard let viewName = fileName.components(separatedBy: ".swift").first else {
            fatalError("compiler bug: file name is corrupted")
        }
        return viewName
    }
}
