import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody
import SurfMacrosSupport

private let testMacros: [String: Macro.Type] = ["multicast": MulticastMacro.self]
#endif

final class MulticastMacroTests: XCTestCase {
    
    func testWhenAttachedTypeIsNotProtocol() {
        let attached: (String) -> String = {
            """
            @Multicast
            \($0) BatSignal {}
            """
        }
        let expandedSource: (String) -> String = {
            """
            \($0) BatSignal {}
            """
        }
        let diagnostic = DiagnosticSpec(
            message: "Macro can be attached to protocol only",
            line: 1,
            column: 1
        )
        let wrongDecls: [Decls] = [.class, .enum, .struct]

        wrongDecls
            .map { $0.rawValue }
            .forEach {
                assertMacroExpansion(
                    attached($0),
                    expandedSource: expandedSource($0),
                    diagnostics: [diagnostic],
                    macros: testMacros
            )
        }
    }
    
    func testWhenThereIsGeneric() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal<Item> {

            }
            """,
            expandedSource: """
            protocol BatSignal<Item> {

            }
            """,
            diagnostics: [.init(message: "There should not be generic", line: 1, column: 1)],
            macros: testMacros
       )
    }
    
    
    
    func testWhenThereIsNoAppropriateFunc() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal {
                func foo()
            }
            let defaultSignals: [BatSignal] = []
            """,
            expandedSource: """
            protocol BatSignal {
                func foo()
            }
            public final class BatSignals: BatSignal {
                private let signals: [BatSignal]
                public init(@ArrayBuilder<BatSignal> _ signals: () -> [BatSignal]) {
                    self.signals = defaultSignals + signals()
                }
                func foo() {
                    signals.forEach {
                        $0.foo()
                    }
                }
            }
            let defaultSignals: [BatSignal] = []
            """,
            macros: testMacros
       )
    }
    
}

// Tests:
// 1. Not a protocol
// 2. There is an assocciated type
// 3. There is a variable
// 3. All functions that are unappropriate
// 4. All types of parameter styles in functions (3)
