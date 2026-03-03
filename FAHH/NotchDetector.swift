//
//  NotchDetector.swift
//  Notch Touch
//
//  Created by Suaib Sarowar on 02/03/26.
//

import AppKit

/// Detects whether a global point is within a top-center "notch" rectangle and emits enter/exit transitions.
final class NotchDetector {
    // Tunable notch rectangle size (in screen points). Adjust height/width as desired.
    private let notchWidthRatio: CGFloat = 0.20 // 20% of screen width centered
    private let notchHeight: CGFloat = 30       // 30pt tall area at the very top

    private var isInside: Bool = false

    init() {}

    /// Returns true if the given global point is inside the computed notch area of the current main screen.
    func isPointInNotch(_ point: CGPoint) -> Bool {
        guard let screen = NSScreen.main else { return false }
        let frame = screen.frame // In global coordinates (origin at bottom-left)

        // Define a rectangle centered horizontally at the top of the screen.
        let notchWidth = frame.width * notchWidthRatio
        let notchX = frame.midX - notchWidth / 2.0
        let notchY = frame.maxY - notchHeight
        let notchRect = CGRect(x: notchX, y: notchY, width: notchWidth, height: notchHeight)
        return notchRect.contains(point)
    }

    /// Update presence state and invoke callback when an entry occurs.
    /// - Parameters:
    ///   - isInside: current inside/not status
    ///   - onEnter: called with `true` when entering; `false` when exiting (not used here but available)
    func updatePresence(isInside: Bool, onEnter: (_ entered: Bool) -> Void) {
        if isInside && !self.isInside {
            // Transition: outside -> inside
            self.isInside = true
            onEnter(true)
        } else if !isInside && self.isInside {
            // Transition: inside -> outside
            self.isInside = false
            onEnter(false)
        }
        // Otherwise, no state change; do nothing (prevents repeated triggers while staying inside)
    }
}
