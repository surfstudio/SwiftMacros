import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SignalsPlugin.providingMacros,
        UtilsPlugin.providingMacros,
        InfrastructurePlugin.providingMacros,
        FactoryPlugin.providingMacros,
        RouterPlugin.providingMacros
    ].flatMap { $0 }
}
