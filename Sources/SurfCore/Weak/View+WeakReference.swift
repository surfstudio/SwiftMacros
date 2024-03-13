import SwiftUI

public extension View {

    @inlinable
    func weakReference<T: AnyObject>(_ input: T, as type: T.Type) -> some View {
        WeakLocator.shared.store(T.self, reference: .init(input))
        return self
    }

}
