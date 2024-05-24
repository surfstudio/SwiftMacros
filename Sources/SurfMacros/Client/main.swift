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

// Debugging
