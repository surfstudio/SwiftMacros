//
//  SupporingTestsBase.swift
//
//
//  Created by pavlov on 02.07.2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SurfMacrosSupport
import XCTest

class SupporingTestsBase {

    // MARK: - Properties

    let macro: String
    let type: Macro.Type

    // MARK: - Init

    init(macro: String, type: Macro.Type) {
        self.macro = macro
        self.type = type
    }

    // MARK: - Methods

    func launchTest(
        _ originalSource: String,
        expandedSource: String,
        diagnosticMessage: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertMacroExpansion(
            originalSource,
            expandedSource: expandedSource,
            diagnostics: [
                .init(
                    message: diagnosticMessage,
                    line: 1,
                    column: 1
                )
            ],
            macros: [macro: type],
            file: file,
            line: line
       )
    }

}
