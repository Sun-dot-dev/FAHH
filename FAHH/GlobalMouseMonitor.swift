//
//  GlobalMouseMonitor.swift
//  Notch Touch
//
//  Created by Suaib Sarowar on 02/03/26.
//

import AppKit
import CoreGraphics

/// Monitors global mouse movement using a CGEvent tap (preferred) with a fallback to NSEvent global monitor.
final class GlobalMouseMonitor {
    typealias Handler = (_ globalPoint: CGPoint) -> Void

    private let handler: Handler

    // CGEvent tap properties
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    // NSEvent fallback
    private var nseventMonitor: Any?

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    /// Start listening to global mouse moved events.
    func start() {
        // First, try CGEvent tap for best performance and reliability
        let mask = CGEventMask(1 << CGEventType.mouseMoved.rawValue) | CGEventMask(1 << CGEventType.leftMouseDragged.rawValue) | CGEventMask(1 << CGEventType.rightMouseDragged.rawValue) | CGEventMask(1 << CGEventType.otherMouseDragged.rawValue)

        let callback: CGEventTapCallBack = { proxy, type, event, refcon in
            guard type == .mouseMoved || type == .leftMouseDragged || type == .rightMouseDragged || type == .otherMouseDragged else {
                return Unmanaged.passUnretained(event)
            }
            let location = event.location
            let monitor = Unmanaged<GlobalMouseMonitor>.fromOpaque(refcon!).takeUnretainedValue()
            monitor.handler(location)
            return Unmanaged.passUnretained(event)
        }

        let refcon = Unmanaged.passUnretained(self).toOpaque()
        if let tap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                       place: .headInsertEventTap,
                                       options: .defaultTap,
                                       eventsOfInterest: mask,
                                       callback: callback,
                                       userInfo: refcon) {
            eventTap = tap
            let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            runLoopSource = source
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        } else {
            // Fallback: NSEvent global monitor (less efficient, but works for many cases)
            nseventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]) { [weak self] event in
                self?.handler(event.locationInWindow)
            }
        }
    }

    /// Stop listening and clean up resources.
    func stop() {
        if let monitor = nseventMonitor {
            NSEvent.removeMonitor(monitor)
            nseventMonitor = nil
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            runLoopSource = nil
        }
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            eventTap = nil
        }
    }
}
