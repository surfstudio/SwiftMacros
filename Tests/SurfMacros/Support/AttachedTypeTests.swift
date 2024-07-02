//
//  AttachedTypeTests.swift
//
//
//  Created by pavlov on 02.07.2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SurfMacrosSupport
import XCTest

class AttachedTypeTests: SupporingTestsBase {

    // MARK: - Tests

    func testWhenWrongAttachedType(
        originalSource: (String) -> String,
        expandedSource: (String) -> String,
        allowedDecls: [Decls],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let diagnosticMessage =  "Macro can be attached to \(allowedDecls) only"
        let wrongDecls = Decls.allCases.filter { !allowedDecls.contains($0) && $0 != .func }

        wrongDecls
            .map { $0.rawValue }
            .forEach {
                launchTest(
                    originalSource($0),
                    expandedSource: expandedSource($0),
                    diagnosticMessage: diagnosticMessage,
                    file: file,
                    line: line
                )
            }
    }

}
