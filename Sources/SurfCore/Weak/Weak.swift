import Foundation

/// Обертка для слабой ссылки на объект.
public struct Weak<Unit: AnyObject> {

    private(set) weak var unit: Unit?

    public init(_ unit: Unit) {
        self.unit = unit
    }

}

extension Weak {

    func asAny() -> Weak<AnyObject> {
        Weak<AnyObject>(unit as AnyObject)
    }

    func unwrapped<T: AnyObject>() -> Weak<T>? {
        guard let unit = unit as? T else {
            return nil
        }
        return .init(unit)
    }

}
