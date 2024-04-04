import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody

private let testMacros: [String: Macro.Type] = ["Previews": PreviewsMacro.self]
#endif

final class PreviewsMacroTests: XCTestCase {
    func testMacroWhenClosureProvidedAsArgument() {
        assertMacroExpansion(
            """
            #Previews {
                Group {
                    SomeView(state: .constant(.init(state1)))
                        .previewLayout(.sizeThatFits)
                        .previewDisplayName("state1")
                    SomeView(state: .constatnt(.init(state2)))
                        .previewLayout(.sizeThatFits)
                        .previewDisplayName("state2")
                }
            }
            """,
            expandedSource: """
            struct __macro_local_4ViewfMu_: PreviewProvider {
                static var previews: some View {
                    Group {
                        SomeView(state: .constant(.init(state1)))
                            .previewLayout(.sizeThatFits)
                            .previewDisplayName("state1")
                        SomeView(state: .constatnt(.init(state2)))
                            .previewLayout(.sizeThatFits)
                            .previewDisplayName("state2")
                    }
                }
            }
            """,
            macros: testMacros
       )
    }

    func testMacroWhenClosureProvidedAsTrailingOne() {
        assertMacroExpansion(
            """
            #Previews({
                ForEach(AppRootPoint.allCases) { rootPoint in
                    ContentView(state: .constant(.init(rootPoint: rootPoint)))
                        .previewLayout(.sizeThatFits)
                        .previewDisplayName("\\(rootPoint.rawValue))")
                }
            })
            """,
            expandedSource: """
            struct __macro_local_4ViewfMu_: PreviewProvider {
                static var previews: some View {
                    ForEach(AppRootPoint.allCases) { rootPoint in
                        ContentView(state: .constant(.init(rootPoint: rootPoint)))
                            .previewLayout(.sizeThatFits)
                            .previewDisplayName("\\(rootPoint.rawValue))")
                    }
                }
            }
            """,
            macros: testMacros
       )
    }

    func testMacrosWhenOneViewProvided() {
        assertMacroExpansion(
            """
            #Previews {
                SomeView(state: .constant(.init(state)))
                    .previewLayout(.sizeThatFits)
                    .previewDisplayName("state1")
            }
            """,
            expandedSource: """
            struct __macro_local_4ViewfMu_: PreviewProvider {
                static var previews: some View {
                    SomeView(state: .constant(.init(state)))
                        .previewLayout(.sizeThatFits)
                        .previewDisplayName("state1")
                }
            }
            """,
            macros: testMacros
       )
    }

    func testMacrosWhenNoTrailingClosure() {
         assertMacroExpansion(
            """
            #Previews
            """,
            expandedSource: """
            #Previews
            """,
            diagnostics: [DiagnosticSpec(message: "emptyArgumentsList", line: 1, column: 1)],
            macros: testMacros
       )
    }

    func testMacrosWhenNoArgumentClosure() {
         assertMacroExpansion(
            """
            #Previews()
            """,
            expandedSource: """
            #Previews()
            """,
            diagnostics: [DiagnosticSpec(message: "emptyArgumentsList", line: 1, column: 1)],
            macros: testMacros
       )
    }

    func testMacrosWhenProvidedNonClosureTypeAsArgument() {
         assertMacroExpansion(
            """
            #Previews(1)
            """,
            expandedSource: """
            #Previews(1)
            """,
            diagnostics: [
                DiagnosticSpec(message: "failedCastTo(type: SwiftSyntax.ClosureExprSyntax)", line: 1, column: 1)
            ],
            macros: testMacros
       )
    }
}
