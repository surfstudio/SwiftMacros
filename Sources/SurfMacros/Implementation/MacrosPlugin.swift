import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        InfrastructurePlugin.providingMacros,
        FactoryPlugin.providingMacros
    ].flatMap { $0 }
}
