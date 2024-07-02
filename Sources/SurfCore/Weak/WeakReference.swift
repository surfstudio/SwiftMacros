import Foundation

// MARK: - Wrapper

/// Слабая ссылка на любой протокол.
///  - Note: Значение get-only. ProjectedValue ($) отсутствует.
///  - Warning: Если объект по какой-то причине обнулился, то в `Debug` сборке будет краш.
@propertyWrapper
public struct WeakReference<Input: AnyObject> {

    public var wrappedValue: Input? {
        let input = WeakLocator.shared.provide(Input.self)?.unit
        #if DEBUG
        if input == nil {
            debugPrint("⚠️ Weak for \(Input.self) not found in WeakLocator")
        }
        #endif
        return input
    }

    public init() {}

}
