// swiftlint:disable all

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody
import SurfMacrosSupport

private let macro = "CompletionHandler"
private let type = CompletionHandlerMacro.self
private let testMacros: [String: Macro.Type] = [macro: type]
#endif

final class CompletionHandlerMacroTests: XCTestCase {

    func testAllWrongProtocolFormats() {
        let runner = ProtocolableMacroTests(macro: macro, type: type)
        runner.testWhenAttachedTypeIsNotProtocol()
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
            @\(macro)
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

            private class BatSignalHandler: BatSignal {
                private let completion: EmptyClosure?
                init(completion: EmptyClosure? = nil) {
                    self.completion = completion
                }
                func call(robin: Robin) {
                    completion?()
                }
                func call(for robin: Robin) {
                    completion?()
                }
                func call(_ robin: Robin) {
                    completion?()
                }
            }
            """,
            macros: testMacros
       )
    }
    
}
// swiftlint:enable all
