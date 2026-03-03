//
//  Notch_TouchApp.swift
//  Notch Touch
//
//  Created by Suaib Sarowar on 02/03/26.
//

import SwiftUI
import AppKit

@main
struct FAHH: App {
    // Create singletons for app lifetime
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // No main window: provide an empty Settings scene so the app has no visible windows
        Settings {
            EmptyView()
        }
    }
}

/// App delegate to start background services without showing a window.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var mouseMonitor: GlobalMouseMonitor?
    private let soundManager = SoundManager()
    private let notchDetector = NotchDetector()
    private var statusItemController: StatusItemController?
    private var overlayController: NotchOverlayController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory) // Keeps app running in background (dockless optional)

        // Status bar item so the user can quit the app
        statusItemController = StatusItemController(onQuit: { NSApp.terminate(nil) })

        // Create top overlay window hosting the notch visualization
        overlayController = NotchOverlayController()
        overlayController?.show()

        // Start monitoring global mouse movement
        mouseMonitor = GlobalMouseMonitor { [weak self] globalPoint in
            guard let self else { return }
            let isInside = self.notchDetector.isPointInNotch(globalPoint)
            self.notchDetector.updatePresence(isInside: isInside) { entered in
                if entered {
                    // Visual + sound feedback when entering
                    self.overlayController?.setTriggered(true)
                    self.soundManager.playSound()
                } else {
                    // Smoothly clear visuals when exiting
                    self.overlayController?.setTriggered(false)
                }
            }
        }
        mouseMonitor?.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        mouseMonitor?.stop()
    }
}

/// Minimal status item so the app can be controlled without a window.
final class StatusItemController {
    private var statusItem: NSStatusItem?
    private let onQuit: () -> Void

    init(onQuit: @escaping () -> Void) {
        self.onQuit = onQuit
        setup()
    }

    private func setup() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "FAHH"

        let menu = NSMenu()
        let quitItem = NSMenuItem(title: "Quit FAHH", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        item.menu = menu

        statusItem = item
    }

    @objc private func quit() {
        onQuit()
    }
}
