import SwiftUI

public extension View {
    @_disfavoredOverload
    func navigationDestination<D: Identifiable, C: View>(
        item: Binding<D?>,
        @ViewBuilder destination: @escaping (D) -> C
    ) -> some View {
        self.navigationDestination(isPresented: Binding(
            get: { item.wrappedValue != nil },
            set: { if !$0 { item.wrappedValue = nil } }
        )) {
            if let value = item.wrappedValue {
                destination(value)
            }
        }
    }
}
