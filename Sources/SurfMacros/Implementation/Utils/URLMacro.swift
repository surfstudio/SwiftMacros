import Foundation
import SurfMacrosSupport
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum URLMacro: ExpressionMacro {

    // MARK: - Names

    private enum Names {
        static let url = "URL"
        static let argument = "string"
    }

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let (argument, value) = try getInputArgument(from: node)
        try checkURLString(value, from: argument)
        return .init(createURLExpression(with: argument))
    }

}

// MARK: - Getters

private extension URLMacro {

    static func getInputArgument(
        from node: some FreestandingMacroExpansionSyntax
    ) throws -> (argument: ExprSyntax, argumentValue: String) {
        guard
            let argument = node.argumentList.first?.expression,
            let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
            segments.count == 1,
            case .stringSegment(let literalSegment)? = segments.first
        else {
            throw CustomError(description: "#URL requires a static string literal")
        }
        return (argument: argument, argumentValue: literalSegment.content.text)
    }

}

// MARK: - Checks

private extension URLMacro {

    static func checkURLString(_ urlString: String, from argument: ExprSyntax) throws {
        guard let _ = URL(string: urlString) else {
            throw CustomError(description: "malformed url: \(argument)")
        }
    }

}

// MARK: - Creations

private extension URLMacro {

    static func createURLExpression(with argument: ExprSyntax) -> ExprSyntaxProtocol {
        let urlInit = DeclReferenceExprSyntax(baseName: .identifier(Names.url))
        let stringArgument = LabeledExprSyntax(
            label: .identifier(Names.argument),
            expression: argument
        )
        let functionCall = FunctionCallExprSyntax(
            calledExpression: urlInit,
            arguments: [stringArgument]
        )
        return ForceUnwrapExprSyntax(expression: functionCall)
    }

}
