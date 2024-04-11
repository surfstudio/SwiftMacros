import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct RouterPlugin {
    static let providingMacros: [Macro.Type] = [
        NavigationStateMacro.self
    ]
}
