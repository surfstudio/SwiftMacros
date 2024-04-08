import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody

private let testMacros: [String: Macro.Type] = ["NavigationState": NavigationStateMacro.self]
#endif

final class NavigationStateMacroTests: XCTestCase {
    func testMacroExpansion() {
        assertMacroExpansion(
            """
            @NavigationState
            struct MainState {
                enum Destination: Hashable {
                    case final
                }
            }
            """,
            expandedSource: """
            struct MainState {
                enum Destination: Hashable {
                    case final
                }

                var navigationPath: NavigationPath

                static var initial: Self {
                    .init(navigationPath: .init())
                }

                mutating func push(destination: Destination) {
                    navigationPath.append(destination)
                }

                mutating func pop() {
                    navigationPath.removeLast()
                }

                mutating func popToRoot() {
                    navigationPath = .init()
                }
            }
            """,
            macros: testMacros
       )
    }

    func testWhenAttachedTypeIsNotStruct() {
        let attached: (String) -> String = {
            """
            @NavigationState
            \($0) MainState {
                enum Destination: Hashable {
                    case final
                }
            }
            """
        }
        let expandedSource: (String) -> String = {
            """
            \($0) MainState {
                enum Destination: Hashable {
                    case final
                }
            }
            """
        }
        let diagnostic = DiagnosticSpec(
            message: "error(\"Can be attached to structs only\")",
            line: 1,
            column: 1
        )

        ["class", "enum"].forEach {
            assertMacroExpansion(
                attached($0),
                expandedSource: expandedSource($0),
                diagnostics: [diagnostic],
                macros: testMacros
            )
        }
    }
}































