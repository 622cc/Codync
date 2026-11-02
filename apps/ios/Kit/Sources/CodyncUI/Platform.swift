import CodyncKit
import SwiftUI
import UIKit

enum Pasteboard {
    static func copy(_ text: String?) {
        guard let text else { return }
        UIPasteboard.general.string = text
    }
}

extension View {
    func plainTextInput() -> some View {
        textInputAutocapitalization(.never).autocorrectionDisabled()
    }
}

extension View {
    /// Liquid Glass where the OS has it (content scrolls visibly underneath), a material before that.
    func glass(in shape: some Shape) -> some View {
        background(.ultraThinMaterial, in: shape)
    }
}
