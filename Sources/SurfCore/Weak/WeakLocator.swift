import Foundation

@usableFromInline
final class WeakLocator {

    @usableFromInline
    static let shared = WeakLocator()

    private init() {}

    private var references: [String: Weak<AnyObject>] = [:]

    // MARK: - Methods

    @usableFromInline
    func store<T: AnyObject>(_ type: T.Type, reference: Weak<T>) {
        references[getKey(from: type)] = reference.asAny()
    }

    @usableFromInline
    func provide<T: AnyObject>(_ type: T.Type) -> Weak<T>? {
        return references[getKey(from: type)]?.unwrapped()
    }

}

// MARK: - Private

private extension WeakLocator {

    func getKey<T: AnyObject>(from type: T.Type) -> String {
        return "\(type.self)"
    }

}
