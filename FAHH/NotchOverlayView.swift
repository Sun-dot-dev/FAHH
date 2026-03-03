//
//  NotchOverlayView.swift
//  Notch Touch
//
//  Created by Suaib Sarowar on 02/03/26.
//

import SwiftUI
import AppKit
internal import Combine

/// Observable controller to drive the glow animation state from AppDelegate.
final class NotchOverlayModel: ObservableObject {
    @Published var isTriggered: Bool = false
}

/// Manages a borderless overlay window that hosts the SwiftUI view at the top center.
final class NotchOverlayController {
    private var window: NSWindow?
    private let model = NotchOverlayModel()

    // Overlay disabled completely
    func show() {
        // no-op
    }

    func setTriggered(_ value: Bool) {
        // overlay disabled
    }

    func hide() {
        // overlay disabled
    }
}

/// Overlay disabled — placeholder view
struct NotchOverlayView: View {
    var body: some View {
        EmptyView()
    }
}

#Preview {
    EmptyView()
}
