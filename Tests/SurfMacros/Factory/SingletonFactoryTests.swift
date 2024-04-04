import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody

private let testMacros: [String: Macro.Type] = ["SingletonFactory": SingletonFactoryMacro.self]
#endif

final class SingletonFactoryMacroTests: XCTestCase {
    func testMacroWhenOneGenericType() {
        assertMacroExpansion(
            """
            @SingletonFactory<Int>
            struct Factory {
            }
            """,
            expandedSource: """
            struct Factory {

                typealias Product = Int

                private static var product: Product?

                static func produce() -> Product {
                    if let product = Self.product {
                        return product
                    } else {
                        let product = produceProduct()
                        Self.product = product
                        return product
                    }
                }
            }
            """,
            macros: testMacros
       )
    }

    func testMacroWhenSeveralGenericType() {
        assertMacroExpansion(
            """
            @SingletonFactory<Encodable & Decodable & Codable>
            struct Factory {
            }
            """,
            expandedSource: """
            struct Factory {

                typealias Product = Encodable & Decodable & Codable

                private static var product: Product?

                static func produce() -> Product {
                    if let product = Self.product {
                        return product
                    } else {
                        let product = produceProduct()
                        Self.product = product
                        return product
                    }
                }
            }
            """,
            macros: testMacros
       )
    }

    func testMacrosWhenNoGenericArgumentClause() {
         assertMacroExpansion(
            """
            @SingletonFactory
            struct Factory {}
            """,
            expandedSource: """
            struct Factory {}
            """,
            diagnostics: [DiagnosticSpec(message: "missedGenericArgumentClause", line: 1, column: 1)],
            macros: testMacros
       )
    }
}
