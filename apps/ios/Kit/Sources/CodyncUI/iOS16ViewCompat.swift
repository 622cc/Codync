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

