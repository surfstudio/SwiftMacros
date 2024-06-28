// swiftlint:disable all

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody
import SurfMacrosSupport

private let testMacros: [String: Macro.Type] = ["Multicast": MulticastMacro.self]
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
    
    func testWhenThereIsAssociated() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal {
                associatedtype Item
                  
                func methodA()
            }
            """,
            expandedSource: """
            protocol BatSignal {
                associatedtype Item
                  
                func methodA()
            }
            """,
            diagnostics: [.init(message: "There should not be any associated types", line: 1, column: 1)],
            macros: testMacros
       )
    }

    func testWhenThereIsVariable() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal {
                var robinsName: String { get }
                  
                func methodA()
            }
            """,
            expandedSource: """
            protocol BatSignal {
                var robinsName: String { get }
                  
                func methodA()
            }
            """,
            diagnostics: [.init(message: "There should not be any variables", line: 1, column: 1)],
            macros: testMacros
       )
    }
    
    func testWhenFuncIsStatic() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal {
                static func methodA()

                func methodB()
            }
            """,
            expandedSource: """
            protocol BatSignal {
                static func methodA()

                func methodB()
            }
            """,
            diagnostics: [
                .init(
                    message: """
                        The only allowed format of a function is the following:
                            func <name>(<argument>, ...)
                    """,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
       )
    }
    
    func testWhenFuncThrows() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal {
                func methodA() throws

                func methodB()
            }
            """,
            expandedSource: """
            protocol BatSignal {
                func methodA() throws

                func methodB()
            }
            """,
            diagnostics: [
                .init(
                    message: """
                        The only allowed format of a function is the following:
                            func <name>(<argument>, ...)
                    """,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
       )
    }
    
    func testWhenFuncIsAsync() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal {
                func methodA() async

                func methodB()
            }
            """,
            expandedSource: """
            protocol BatSignal {
                func methodA() async

                func methodB()
            }
            """,
            diagnostics: [
                .init(
                    message: """
                        The only allowed format of a function is the following:
                            func <name>(<argument>, ...)
                    """,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
       )
    }
    
    func testWhenFuncHasAttribute() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal {
                @MainActor
                func methodA()

                func methodB()
            }
            """,
            expandedSource: """
            protocol BatSignal {
                @MainActor
                func methodA()

                func methodB()
            }
            """,
            diagnostics: [
                .init(
                    message: """
                        The only allowed format of a function is the following:
                            func <name>(<argument>, ...)
                    """,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
       )
    }
    
    func testWhenFuncReturnIsNotVoid() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal {
                func methodA() -> String

                func methodB()
            }
            """,
            expandedSource: """
            protocol BatSignal {
                func methodA() -> String

                func methodB()
            }
            """,
            diagnostics: [
                .init(
                    message: """
                        The only allowed format of a function is the following:
                            func <name>(<argument>, ...)
                    """,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
       )
    }
    
    func testWhenFuncIsGenericWithoutWhereKeyword() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal {
                func methodA<T>(input: T)

                func methodB()
            }
            """,
            expandedSource: """
            protocol BatSignal {
                func methodA<T>(input: T)

                func methodB()
            }
            """,
            diagnostics: [
                .init(
                    message: """
                        The only allowed format of a function is the following:
                            func <name>(<argument>, ...)
                    """,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
       )
    }
    
    func testWhenFuncIsGenericWithWhereKeyword() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal {
                func methodA<T>(input: T) where T: Codable

                func methodB()
            }
            """,
            expandedSource: """
            protocol BatSignal {
                func methodA<T>(input: T) where T: Codable

                func methodB()
            }
            """,
            diagnostics: [
                .init(
                    message: """
                        The only allowed format of a function is the following:
                            func <name>(<argument>, ...)
                    """,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
       )
    }


    func testWithAllPossibleArgumentFormats() {
        assertMacroExpansion(
            """
            @Multicast
            protocol BatSignal {
                func call(robin: Robin)
                func call(for robin: Robin)
                func call(_ robin: Robin)
            }
            """,
            expandedSource: """
            protocol BatSignal {
                func call(robin: Robin)
                func call(for robin: Robin)
                func call(_ robin: Robin)
            }

            public final class BatSignals: BatSignal {
                private let signals: [BatSignal]
                public init(@ArrayBuilder<BatSignal> _ signals: () -> [BatSignal]) {
                    self.signals = signals()
                }
                public func call(robin: Robin) {
                    signals.forEach {
                        $0.call(robin: robin)
                    }
                }
                public func call(for robin: Robin) {
                    signals.forEach {
                        $0.call(for: robin)
                    }
                }
                public func call(_ robin: Robin) {
                    signals.forEach {
                        $0.call(robin)
                    }
                }
            }
            """,
            macros: testMacros
       )
    }
    
}
// swiftlint:enable all
