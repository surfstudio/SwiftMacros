import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody
let macro = "ObjcBridge"
let type = ObjcBridgeMacro.self
private let testMacros: [String: Macro.Type] = [macro: type]
#endif

final class ObjcBridgeMacroTests: XCTestCase {

    func testAttachedType() {
        let runner = AttachedTypeTests(macro: macro, type: type)
        runner.testWhenWrongAttachedType(
            originalSource: {
                """
                @\(macro)
                public \($0) SomeClass
                """
            },
            expandedSource: {
                """
                public \($0) SomeClass
                """
            },
            allowedDecls: [.class, .enum, .protocol, .struct]
        )
    }

    func testWhenThereIsGenericClause() {
        let runner = SupporingTestsBase(macro: macro, type: type)
        runner.launchTest(
            """
            @ObjcBridge
            public class SomeName<T> {}
            """,
            expandedSource: """
            public class SomeName<T> {}
            """,
            diagnosticMessage: "Generic types cannot be represented in objc."
        )
    }

    func testProperUsage() {
        assertMacroExpansion(
            """
            @ObjcBridge
            public class SomeName {}
            """,
            expandedSource: """
            public class SomeName {}

            public class SomeNameObjcBridge: NSObject {
                public let entity: SomeName
                public init(_ entity: SomeName) {
                    self.entity = entity
                }
            }
            """,
            macros: testMacros
       )
    }
}
