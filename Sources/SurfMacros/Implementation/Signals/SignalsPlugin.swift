import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct SignalsPlugin {
    static let providingMacros: [Macro.Type] = [
        MulticastMacro.self,
        ObjcBridgeMacro.self,
        CompletionHandlerMacro.self
    ]
}
