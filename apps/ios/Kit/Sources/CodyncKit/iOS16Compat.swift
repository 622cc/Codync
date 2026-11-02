import Foundation
import SwiftUI
@_exported import Perception

// MARK: - Global Perception / Observation compatibility for iOS 16
public typealias AppObservable = Perception.Perceptible

// MARK: - EnvironmentStore Compatibility for iOS 16

public final class EnvironmentStoreResolver: @unchecked Sendable {
    nonisolated(unsafe) public static var resolvers: [(Any.Type, (EnvironmentValues) -> Any?)] = []

    public static func register<T>(_ type: T.Type, resolver: @escaping (EnvironmentValues) -> T?) {
        resolvers.append((type, resolver))
    }

    public static func resolve<T>(_ type: T.Type, in env: EnvironmentValues) -> T {
        for (regType, resolver) in resolvers {
            if regType == type, let result = resolver(env) as? T {
                return result
            }
        }
        fatalError("No EnvironmentStore resolver registered for type \(type)")
    }
}

@propertyWrapper
public struct EnvironmentStore<Value>: DynamicProperty {
    @Environment(\.self) private var environment

    public init(_ type: Value.Type) {}

    public var wrappedValue: Value {
        EnvironmentStoreResolver.resolve(Value.self, in: environment)
    }
}
