//
//  Copyright © Surf. All rights reserved.
//

import Foundation

/// Замыкание без параметра
public typealias EmptyClosure = () -> Void

/// Замыкание с одним параметром
public typealias Closure<T> = (T) -> Void
