import SurfMacros
import SwiftUI
import DeveloperToolsSupport

// Precondtion
 @SingletonFactory<Codable>
 struct Factory {
     private static func produceProduct() -> Product {
         return 3
     }
 }

// Helpers

// Debugging
