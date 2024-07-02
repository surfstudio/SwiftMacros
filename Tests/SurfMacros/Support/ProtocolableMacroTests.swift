//
//  ProtocolableMacroTests.swift
//
//
//  Created by pavlov on 01.07.2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SurfMacrosSupport
import XCTest

final class ProtocolableMacroTests: SupporingTestsBase {

    // MARK: - Tests

    func testWhenThereIsAssociated(file: StaticString = #file, line: UInt = #line) {
        let originalSource = """
        @\(self.macro)
        protocol BatSignal {
            associatedtype Item
        
            func methodA()
        }
        """

        let expandedSource = """
        protocol BatSignal {
            associatedtype Item
        
            func methodA()
        }
        """

        let diagnosticsMessage = "There should not be any associated types"

        launchTest(
            originalSource,
            expandedSource: expandedSource,
            diagnosticMessage: diagnosticsMessage,
            file: file,
            line: line
        )
    }

    func testWhenThereIsVariable(file: StaticString = #file, line: UInt = #line) {
        let originalSource = """
        @\(self.macro)
        protocol BatSignal {
            var robinsName: String { get }
        
            func methodA()
        }
        """

        let expandedSource = """
        protocol BatSignal {
            var robinsName: String { get }
        
            func methodA()
        }
        """

        let diagnosticMessage = "There should not be any variables"

        launchTest(
            originalSource,
            expandedSource: expandedSource,
            diagnosticMessage: diagnosticMessage,
            file: file,
            line: line
        )
    }

    func testWhenFuncIsStatic(file: StaticString = #file, line: UInt = #line) {
        let originalSource = """
        @\(self.macro)
        protocol BatSignal {
            static func methodA()

            func methodB()
        }
        """

        let expandedSource = """
        protocol BatSignal {
            static func methodA()

            func methodB()
        }
        """

        let diagnosticMessage = """
        The only allowed format of a function is the following:
            func <name>(<argument>, ...)
        """

        launchTest(
            originalSource,
            expandedSource: expandedSource,
            diagnosticMessage: diagnosticMessage,
            file: file,
            line: line
        )
    }

    func testWhenFuncThrows(file: StaticString = #file, line: UInt = #line) {
        let originalSource = """
        @\(self.macro)
        protocol BatSignal {
            func methodA() throws

            func methodB()
        }
        """

        let expandedSource = """
        protocol BatSignal {
            func methodA() throws

            func methodB()
        }
        """

        let diagnosticMessage = """
        The only allowed format of a function is the following:
            func <name>(<argument>, ...)
        """

        launchTest(
            originalSource,
            expandedSource: expandedSource,
            diagnosticMessage: diagnosticMessage,
            file: file,
            line: line
        )
    }

    func testWhenFuncIsAsync(file: StaticString = #file, line: UInt = #line) {
        let originalSource = """
        @\(self.macro)
        protocol BatSignal {
            func methodA() async

            func methodB()
        }
        """

        let expandedSource = """
        protocol BatSignal {
            func methodA() async

            func methodB()
        }
        """

        let diagnosticMessage = """
        The only allowed format of a function is the following:
            func <name>(<argument>, ...)
        """

        launchTest(
            originalSource,
            expandedSource: expandedSource,
            diagnosticMessage: diagnosticMessage,
            file: file,
            line: line
        )
    }

    func testWhenFuncHasAttribute(file: StaticString = #file, line: UInt = #line) {
        let originalSource = """
        @\(self.macro)
        protocol BatSignal {
            @MainActor
            func methodA()

            func methodB()
        }
        """

        let expandedSource = """
        protocol BatSignal {
            @MainActor
            func methodA()

            func methodB()
        }
        """

        let diagnosticMessage = """
        The only allowed format of a function is the following:
            func <name>(<argument>, ...)
        """

        launchTest(
            originalSource,
            expandedSource: expandedSource,
            diagnosticMessage: diagnosticMessage,
            file: file,
            line: line
        )
    }

    func testWhenFuncReturnIsNotVoid(file: StaticString = #file, line: UInt = #line) {
        let originalSource = """
        @\(self.macro)
        protocol BatSignal {
            func methodA() -> String

            func methodB()
        }
        """

        let expandedSource = """
        protocol BatSignal {
            func methodA() -> String

            func methodB()
        }
        """

        let diagnosticMessage = """
        The only allowed format of a function is the following:
            func <name>(<argument>, ...)
        """

        launchTest(
            originalSource,
            expandedSource: expandedSource,
            diagnosticMessage: diagnosticMessage,
            file: file,
            line: line
        )
    }

    func testWhenFuncIsGenericWithoutWhereKeyword(file: StaticString = #file, line: UInt = #line) {
        let originalSource = """
        @\(self.macro)
        protocol BatSignal {
            func methodA<T>(input: T)

            func methodB()
        }
        """

        let expandedSource = """
        protocol BatSignal {
            func methodA<T>(input: T)

            func methodB()
        }
        """

        let diagnosticMessage = """
        The only allowed format of a function is the following:
            func <name>(<argument>, ...)
        """

        launchTest(
            originalSource,
            expandedSource: expandedSource,
            diagnosticMessage: diagnosticMessage,
            file: file,
            line: line
        )
    }

    func testWhenFuncIsGenericWithWhereKeyword(file: StaticString = #file, line: UInt = #line) {
        let originalSource = """
        @\(self.macro)
        protocol BatSignal {
            func methodA<T>(input: T) where T: Codable

            func methodB()
        }
        """

        let expandedSource = """
        protocol BatSignal {
            func methodA<T>(input: T) where T: Codable

            func methodB()
        }
        """

        let diagnosticMessage = """
        The only allowed format of a function is the following:
            func <name>(<argument>, ...)
        """

        launchTest(
            originalSource,
            expandedSource: expandedSource,
            diagnosticMessage: diagnosticMessage,
            file: file,
            line: line
        )
    }

}
