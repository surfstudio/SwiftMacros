//
//  File.swift
//  
//
//  Created by pavlov on 24.05.2024.
//

import Foundation

enum MulticastError: Error, CustomStringConvertible {
    case wrongFunctionFormat

    var description: String {
        switch self {
        case .wrongFunctionFormat:
            return """
                The only allowed format of a function is the following:
                    func <name>(<argument>, ...)
            """
        }
    }

}
