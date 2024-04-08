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
                private static func produceProduct() -> Product {
                    return 3
                }
            }
            """,
            expandedSource: """
            struct Factory {
                private static func produceProduct() -> Product {
                    return 3
                }

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
                private static func produceProduct() -> Product {
                    return 3
                }
            }
            """,
            expandedSource: """
            struct Factory {
                private static func produceProduct() -> Product {
                    return 3
                }

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
            struct Factory {
                private static func produceProduct() -> Product {
                    return 3
                }
            }
            """,
            expandedSource: """
            struct Factory {
                private static func produceProduct() -> Product {
                    return 3
                }
            }
            """,
            diagnostics: [DiagnosticSpec(message: "missedGenericArgumentClause", line: 1, column: 1)],
            macros: testMacros
       )
    }

    func testMacrosWhenNotPrivateProduceProductMethod() {
         assertMacroExpansion(
            """
            @SingletonFactory<Int>
            struct Factory {
                static func produceProduct() -> Product {
                    return 3
                }
            }
            """,
            expandedSource: """
            struct Factory {
                static func produceProduct() -> Product {
                    return 3
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "error(\"produceProduct func should be private\")", line: 1, column: 1)
            ],
            macros: testMacros
       )
    }
}
