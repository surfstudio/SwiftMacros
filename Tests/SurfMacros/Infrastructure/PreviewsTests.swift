import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody

let testMacros: [String: Macro.Type] = ["Previews": PreviewsMacro.self]
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
            fileprivate struct Content_Previews: PreviewProvider {
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
            fileprivate struct Content_Previews: PreviewProvider {
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
            fileprivate struct Content_Previews: PreviewProvider {
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
}
