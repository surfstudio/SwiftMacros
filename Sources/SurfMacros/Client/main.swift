import SurfMacros
import SwiftUI
import DeveloperToolsSupport
import SurfCore

// Precondtion

@Multicast
public protocol BatSignal {
    func robin()
}

private let defaultSignals: [BatSignal] = []

// Helpers

struct TestStruct: BatSignal {
    func robin() {}
}

// Debugging

let signals: BatSignal = BatSignals {
    TestStruct()
    TestStruct()
    TestStruct()
    TestStruct()
}
