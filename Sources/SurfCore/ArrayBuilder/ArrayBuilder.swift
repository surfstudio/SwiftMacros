//
//  ArrayBuilder.swift
//
//
//  Created by pavlov on 24.05.2024.
//

import Foundation

@resultBuilder
public enum ArrayBuilder<Item> {

    public static func buildExpression(_ expression: Item) -> [Item] {
        return [expression]
    }

    public static func buildExpression(_ expressions: [Item]) -> [Item] {
        return expressions
    }

    public static func buildExpression(_ expression: ()) -> [Item] {
        return []
    }

    public static func buildBlock(_ components: [Item]...) -> [Item] {
        return components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[Item]]) -> [Item] {
        return .init(components.joined())
    }

    public static func buildEither(first component: [Item]) -> [Item] {
        return component
    }

    public static func buildEither(second component: [Item]) -> [Item] {
        return component
    }

}
