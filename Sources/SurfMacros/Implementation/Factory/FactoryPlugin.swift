import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct FactoryPlugin {
    static let providingMacros: [Macro.Type] = [
        SingletonFactoryMacro.self
    ]
}
