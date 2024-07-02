import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody

private let testMacros: [String: Macro.Type] = ["URL": URLMacro.self]
#endif

final class URLMacroTests: XCTestCase {
    func testExpansionWithMalformedURLEmitsError() {
        assertMacroExpansion(
            """
            let invalid = #URL("https://not a url.com")
            """,
            expandedSource: """
                let invalid = #URL("https://not a url.com")
                """,
            diagnostics: [
                .init(message: #"malformed url: "https://not a url.com""#, line: 1, column: 15, severity: .error)
            ],
            macros: testMacros
        )
    }

    func testExpansionWithStringInterpolationEmitsError() {
        assertMacroExpansion(
            #"""
            #URL("https://\(domain)/api/path")
            """#,
            expandedSource: #"""
                #URL("https://\(domain)/api/path")
                """#,
            diagnostics: [
                .init(message: "#URL requires a static string literal", line: 1, column: 1, severity: .error)
            ],
            macros: testMacros
        )
    }

    func testExpansionWithValidURL() {
        assertMacroExpansion(
            """
            let valid = #URL("https://swift.org/")
            """,
            expandedSource: """
                let valid = URL(string: "https://swift.org/")!
                """,
            macros: testMacros
        )
    }

}
