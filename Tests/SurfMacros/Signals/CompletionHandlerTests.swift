// swiftlint:disable all

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody
import SurfMacrosSupport

private let testMacro = "CompletionHandler"
private let testType = CompletionHandlerMacro.self
private let testMacros: [String: Macro.Type] = [testMacro: testType]
#endif

final class CompletionHandlerMacroTests: XCTestCase {

    func testWhenAttachedTypeIsNotProtocol() {
        let runner = AttachedTypeTests(macro: testMacro, type: testType)
        runner.testWhenWrongAttachedType(
            originalSource: {
                """
                @\(testMacro)
                \($0) BatSignal {}
                """
            },
            expandedSource: {
                """
                \($0) BatSignal {}
                """
            },
            allowedDecls: [.protocol]
        )
    }

    func testAllWrongProtocolFormats() {
        let runner = ProtocolableMacroTests(macro: testMacro, type: testType)
        runner.testWhenFuncHasAttribute()
        runner.testWhenFuncIsAsync()
        runner.testWhenFuncIsGenericWithWhereKeyword()
        runner.testWhenFuncIsGenericWithoutWhereKeyword()
        runner.testWhenFuncIsStatic()
        runner.testWhenFuncReturnIsNotVoid()
        runner.testWhenFuncThrows()
        runner.testWhenThereIsAssociated()
        runner.testWhenThereIsVariable()
    }

    func testWithAllPossibleArgumentFormats() {
        assertMacroExpansion(
            """
            @\(testMacro)
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

            public class BatSignalHandler: BatSignal {
                private let completion: EmptyClosure?
                public init(completion: EmptyClosure? = nil) {
                    self.completion = completion
                }
                public func call(robin: Robin) {
                    completion?()
                }
                public func call(for robin: Robin) {
                    completion?()
                }
                public func call(_ robin: Robin) {
                    completion?()
                }
            }
            """,
            macros: testMacros
       )
    }
    
}
// swiftlint:enable all
