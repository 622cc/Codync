import SwiftUI
import CodyncKit
import AVFAudio
import AuthenticationServices
@_exported import Perception

// MARK: - iOS 16 View Compatibility Overloads

extension View {
    @_disfavoredOverload
    @ViewBuilder
    public func onChange<V: Equatable>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void
    ) -> some View {
        self.modifier(OnChangeCompatModifier(value: value, initial: initial, action: action))
    }

    @_disfavoredOverload
    @ViewBuilder
    public func onChange<V: Equatable>(
        of value: V,
        _ action: @escaping () -> Void
    ) -> some View {
        self.onChange(of: value) { _ in
            action()
        }
    }
}

private struct OnChangeCompatModifier<V: Equatable>: ViewModifier {
    let value: V
    let initial: Bool
    let action: (V, V) -> Void
    @State private var oldValue: V?

    func body(content: Content) -> some View {
        content
            .onAppear {
                if initial {
                    action(value, value)
                }
                oldValue = value
            }
            .onChange(of: value) { newValue in
                let prev = oldValue ?? newValue
                oldValue = newValue
                action(prev, newValue)
            }
    }
}

// MARK: - UnevenRoundedRectangle Backport for iOS 16

public struct UnevenRoundedRectangle: Shape {
    public var topLeadingRadius: CGFloat
    public var bottomLeadingRadius: CGFloat
    public var bottomTrailingRadius: CGFloat
    public var topTrailingRadius: CGFloat
    public var style: RoundedCornerStyle

    public init(
        topLeadingRadius: CGFloat = 0,
        bottomLeadingRadius: CGFloat = 0,
        bottomTrailingRadius: CGFloat = 0,
        topTrailingRadius: CGFloat = 0,
        style: RoundedCornerStyle = .continuous
    ) {
        self.topLeadingRadius = topLeadingRadius
        self.bottomLeadingRadius = bottomLeadingRadius
        self.bottomTrailingRadius = bottomTrailingRadius
        self.topTrailingRadius = topTrailingRadius
        self.style = style
    }

    public func path(in rect: CGRect) -> Path {
        let maxRadius = max(topLeadingRadius, topTrailingRadius, bottomLeadingRadius, bottomTrailingRadius)
        return Path(roundedRect: rect, cornerRadius: maxRadius, style: style)
    }
}

// MARK: - View.environment Object Compatibility for iOS 16

extension View {
    @_disfavoredOverload
    public func environment(_ object: AnyObject) -> some View {
        self
    }
}

// MARK: - Menu, Symbol & Scroll Backports for iOS 16

public struct CompatMenuActionDismissBehavior: Sendable {
    public static let disabled = CompatMenuActionDismissBehavior()
    public static let automatic = CompatMenuActionDismissBehavior()
}

public struct CompatSymbolEffect: Sendable {
    public static let pulse = CompatSymbolEffect()
    public static let bounce = CompatSymbolEffect()
    public static let replace = CompatSymbolEffect()
}

public struct CompatSymbolEffectOptions: Sendable {
    public static let repeating = CompatSymbolEffectOptions()
}

public struct CompatScrollBounceBehavior: Sendable {
    public static let basedOnSize = CompatScrollBounceBehavior()
    public static let always = CompatScrollBounceBehavior()
}

public extension View {
    @_disfavoredOverload
    func menuActionDismissBehavior(_ behavior: CompatMenuActionDismissBehavior) -> some View {
        self
    }

    @_disfavoredOverload
    func symbolEffect(_ effect: CompatSymbolEffect, options: CompatSymbolEffectOptions = .repeating, isActive: Bool = true) -> some View {
        self
    }

    @_disfavoredOverload
    func defaultScrollAnchor(_ anchor: UnitPoint?) -> some View {
        self
    }

    @_disfavoredOverload
    func scrollBounceBehavior(_ behavior: CompatScrollBounceBehavior, axes: Axis.Set = [.vertical]) -> some View {
        self
    }
}

public extension ContentTransition {
    @_disfavoredOverload
    static func symbolEffect(_ effect: CompatSymbolEffect) -> ContentTransition {
        .opacity
    }
}

// MARK: - TextSelection & TextField Backport for iOS 16

public struct TextSelection: Equatable, Sendable {
    public enum Indices: Equatable, Sendable { case selection(Range<String.Index>) }
    public var indices: Indices? { nil }
    public init(insertionPoint: String.Index) {}
}

public extension TextField where Label == Text {
    @_disfavoredOverload
    init<S: StringProtocol>(_ title: S, text: Binding<String>, selection: Binding<TextSelection?>?, axis: Axis) {
        self.init(title, text: text, axis: axis)
    }
}

// MARK: - Audio Session Permission Backport for iOS 16

public extension AVAudioSession {
    static func requestRecordPermissionAsync() async -> Bool {
        await withCheckedContinuation { continuation in
            sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}

// MARK: - Text ForegroundStyle Backport for iOS 16

public extension Text {
    @_disfavoredOverload
    func foregroundStyle(_ color: Color) -> Text {
        self.foregroundColor(color)
    }
}

// MARK: - PresentationBackground, SafeAreaPadding, Transaction & Scroll Backports for iOS 16

public extension View {
    @_disfavoredOverload
    func presentationBackground<S: ShapeStyle>(_ style: S) -> some View {
        self
    }

    @_disfavoredOverload
    func transaction<V: Equatable>(value: V, _ transform: @escaping (inout Transaction) -> Void) -> some View {
        self.transaction(transform)
    }

    @_disfavoredOverload
    func safeAreaPadding(_ insets: EdgeInsets) -> some View {
        self.padding(insets)
    }

    @_disfavoredOverload
    func onScrollVisibilityChange(threshold: Double = 0.5, _ action: @escaping (Bool) -> Void) -> some View {
        self.onAppear { action(true) }
            .onDisappear { action(false) }
    }
}

// MARK: - Animation Completion Backport for iOS 16

public func withAnimation<Result>(
    _ animation: Animation? = .default,
    _ body: () throws -> Result,
    completion: @escaping () -> Void
) rethrows -> Result {
    let result = try withAnimation(animation, body)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
        completion()
    }
    return result
}

// MARK: - WebAuthenticationSession Backport for iOS 16

public struct WebAuthenticationSession: Sendable {
    public enum PreferredBrowserSession: Sendable {
        case shared, ephemeral
    }

    public init() {}

    @MainActor
    public func authenticate(
        using url: URL,
        callbackURLScheme: String,
        preferredBrowserSession: PreferredBrowserSession = .shared
    ) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackURLScheme
            ) { callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let callbackURL = callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(throwing: ASWebAuthenticationSessionError(.canceledLogin))
                }
            }
            session.presentationContextProvider = KeyWindowPresentationProvider.shared
            session.prefersEphemeralWebBrowserSession = (preferredBrowserSession == .ephemeral)
            session.start()
        }
    }
}

final class KeyWindowPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding, @unchecked Sendable {
    static let shared = KeyWindowPresentationProvider()
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows where window.isKeyWindow {
                    return window
                }
            }
        }
        return ASPresentationAnchor()
    }
}

private struct WebAuthSessionKey: EnvironmentKey {
    static let defaultValue = WebAuthenticationSession()
}

public extension EnvironmentValues {
    @_disfavoredOverload
    var webAuthenticationSession: WebAuthenticationSession {
        get { self[WebAuthSessionKey.self] }
        set { self[WebAuthSessionKey.self] = newValue }
    }
}



