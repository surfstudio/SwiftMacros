import Foundation

// MARK: - Wrapper

@propertyWrapper
public struct WeakReference<Input: AnyObject> {

    public var wrappedValue: Input? {
        let input = WeakLocator.shared.provide(Input.self)?.unit
        #if DEBUG
        if input == nil {
            fatalError("⚠️ Weak for \(Input.self) not found in WeakLocator")
        }
        #endif
        return input
    }

    public init() {}

}
