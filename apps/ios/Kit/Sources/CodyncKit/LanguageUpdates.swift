import Foundation
import Perception

/// Translation lookups participate in SwiftUI observation without recreating screens or losing drafts.
@Perceptible
final class LanguageUpdates: @unchecked Sendable {
    static let shared = LanguageUpdates()
    private let lock = NSLock()
    private var _revision: Int = 0

    var revision: Int {
        lock.lock()
        defer { lock.unlock() }
        return _revision
    }

    func changed() {
        lock.lock()
        _revision &+= 1
        lock.unlock()
    }
}
