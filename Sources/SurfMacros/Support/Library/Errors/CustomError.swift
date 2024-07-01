//
//  CustomError.swift
//
//
//  Created by pavlov on 30.06.2024.
//

import Foundation

public struct CustomError: Error, CustomStringConvertible {

    public let description: String

    public init(description: String) {
        self.description = description
    }

}
