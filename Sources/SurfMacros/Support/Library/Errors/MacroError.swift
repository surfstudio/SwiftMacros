import Foundation

public enum MacroError: Error {
    case emptyArgumentsList

    case missedGenericArgumentClause
    case emptyGenericArgumentList

    case error(_ description: String)
}
