//
//  LabeledExprSyntax.swift
//
//
//  Created by pavlov on 23.05.2024.
//

import SwiftSyntax

public extension LabeledExprSyntax {
    init(label: TokenSyntax?, expression: ExprSyntaxProtocol) {
        var label = label
        label?.trailingTrivia = .spaces(.zero)
        self.init(
            label: label,
            colon: label == nil ? nil : .colonToken(),
            expression: expression
        )
    }
}
