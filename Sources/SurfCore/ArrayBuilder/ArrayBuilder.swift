//
//  ArrayBuilder.swift
//
//
//  Created by pavlov on 24.05.2024.
//

import Foundation

/// Всеядный билдер для декларативных конструкций.
///
/// Например,
///```swift
///SomeItems {
///    Item1
///    Item2
///    if condition {
///        Item3a
///    } else {
///        Item3b
///    }
///}
///```
/// где `SomeItems` - это короткая функция
/// ```swift
///public func SomeItems(@ArrayBuilder<ItemType>_ content: () -> [ItemType]) -> [ItemType] {
///    content()
///}
///```
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

    public static func buildOptional(_ component: [Item]?) -> [Item] {
        return component ?? []
    }

}
