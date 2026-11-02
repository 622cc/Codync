import SwiftUI
import CodyncKit
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

public extension ButtonStyle where Self == BorderedButtonStyle {
    static var glass: BorderedButtonStyle { .bordered }
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


