import SwiftUI

public extension View {

    /// Регистрирует слабую ссылку в статическом локаторе.
    /// - Parameters:
    ///  - input: инстанс объекта
    ///  - type: тип объекта
    ///  - Note: Помните что хранимая ссылка слабая. Какой-нибудь объект должен её держать.
    @inlinable
    func weakReference<T: AnyObject>(_ input: T, as type: T.Type) -> some View {
        WeakLocator.shared.store(T.self, reference: .init(input))
        return self
    }

}
