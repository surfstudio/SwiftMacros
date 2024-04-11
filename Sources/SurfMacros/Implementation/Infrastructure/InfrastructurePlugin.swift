import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct InfrastructurePlugin {
    static let providingMacros: [Macro.Type] = [
        PreviewsMacro.self
    ]
}
