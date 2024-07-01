// swiftlint:disable all

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody
import SurfMacrosSupport

private let macro = "Multicast"
private let type = MulticastMacro.self
private let testMacros: [String: Macro.Type] = [macro: type]
#endif

final class MulticastMacroTests: XCTestCase {

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
