import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct UtilsPlugin {
    static let providingMacros: [Macro.Type] = [
        URLMacro.self
    ]
}
