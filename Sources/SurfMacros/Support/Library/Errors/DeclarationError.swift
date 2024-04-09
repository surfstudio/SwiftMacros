import Foundation
import SwiftSyntax

public enum DeclarationError: Error, CustomStringConvertible {
    case wrongAttaching(expected: Types)
    case missedModifier(declName: String, declType: Types, expected: Modifiers)
    case missedInheritance(declName: String, declType: Types, expected: String)

    public var description: String {
        switch self {
        case .wrongAttaching(let expectedType):
            return "Macro can be attached to \(expectedType) only"
        case .missedModifier(let declName, let declType, let expectedModifier):
            return "\(declType) \(declName) must be \(expectedModifier)"
        case .missedInheritance(let declName, let declType, let expectedInheritance):
            return "\(declType) \(declName) must inherit from \(expectedInheritance)"
        }
    }
}
