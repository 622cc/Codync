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

    public init<Wrapped>(_ type: Wrapped.Type) where Value == Optional<Wrapped> {}

    public var wrappedValue: Value {
        EnvironmentStoreResolver.resolve(Value.self, in: environment)
    }
}

// MARK: - Audio Compatibility for iOS 16
import AVFoundation

public extension AVAudioSession.CategoryOptions {
    static let allowBluetoothHFP: AVAudioSession.CategoryOptions = .allowBluetooth
}

public extension AVAudioSession {
    static func requestRecordPermissionAsync() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}

// MARK: - View & Transition Compatibility for iOS 16

public extension ContentTransition {
    static func numericText(value: Double) -> ContentTransition { .identity }
    static func numericText(countsDown: Bool = false) -> ContentTransition { .identity }
}

public extension View {
    @ViewBuilder
    func onChange<V: Equatable>(of value: V, _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void) -> some View {
        self.onChange(of: value) { newValue in
            action(newValue, newValue)
        }
    }

    @ViewBuilder
    func onChange<V: Equatable>(of value: V, initial: Bool, _ action: @escaping () -> Void) -> some View {
        self.onChange(of: value) { _ in
            action()
        }
    }

    @ViewBuilder
    func onChange<V: Equatable>(of value: V, initial: Bool, _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void) -> some View {
        self.onChange(of: value) { newValue in
            action(newValue, newValue)
        }
    }
}

#if canImport(AppIntents)
import AppIntents

public extension Button where Label: View {
    init<I: AppIntent>(intent: I, @ViewBuilder label: () -> Label) {
        self.init(action: {}, label: label)
    }
}
#endif
