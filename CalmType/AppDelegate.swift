import SwiftUI
import KeyboardShortcuts
import AppKit
import Carbon.HIToolbox

extension AppDelegate {
    static var shared: AppDelegate? {
        NSApp.delegate as? AppDelegate
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    var mainWindow: NSWindow?
    var hostingView: NSView?
    let appData = AppData()

    private let mainWindowIdentifier = NSUserInterfaceItemIdentifier("mainWindow")
    let settingsWindowIdentifier = NSUserInterfaceItemIdentifier("settingsWindow")

    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupKeyboardShortcuts()
        setupNotificationObserver()
        setupLocalEventMonitor()
        showMainWindow()
    }

    func applicationWillTerminate(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        removeLocalEventMonitor()
    }

    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyDown(for: .toggleCalmTypeWindow) { [weak self] in
            self?.toggleMainWindow()
        }
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(forName: .hideMainWindow, object: nil, queue: .main) { [weak self] _ in
            self?.hideMainWindow()
        }
    }

    private func setupLocalEventMonitor() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, let window = self.mainWindow, window.isVisible else { return event }
            let isCmdEnter = event.modifierFlags.contains(.command) &&
                (event.keyCode == kVK_Return || event.keyCode == kVK_ANSI_KeypadEnter)
            if isCmdEnter {
                var responder: NSResponder? = window.firstResponder
                var isTargetResponder = false
                while responder != nil {
                    if responder == self.hostingView {
                        isTargetResponder = true
                        break
                    }
                    responder = responder?.nextResponder
                }
                if isTargetResponder {
                    self.appData.copyToClipboard()
                    return nil
                }
            }
            return event
        }
    }

    private func removeLocalEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func createMainWindow() {
        guard mainWindow == nil else { return }

        let contentView = ContentView().environmentObject(appData)
        let hostingView = NSHostingView(rootView: contentView)
        self.hostingView = hostingView

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 350),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)

        window.identifier = mainWindowIdentifier
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.level = .floating
        window.backgroundColor = .windowBackgroundColor
        window.isOpaque = true
        window.hasShadow = true

        // Set the window title to display the app name.
        window.title = "CalmType"
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false

        // Hide window controls if required, or leave them visible.
        window.standardWindowButton(.closeButton)?.isHidden = false
        window.standardWindowButton(.miniaturizeButton)?.isHidden = false
        window.standardWindowButton(.zoomButton)?.isHidden = false

        window.contentView = hostingView

        DispatchQueue.main.async {
            if let textView = self.findNSTextView(in: self.hostingView) {
                window.initialFirstResponder = textView
            } else {
                window.initialFirstResponder = self.hostingView
            }
        }
        window.center()
        mainWindow = window
    }

    func showMainWindow() {
        if mainWindow == nil {
            createMainWindow()
        }
        NSApplication.shared.activate(ignoringOtherApps: true)
        mainWindow?.makeKeyAndOrderFront(nil)
    }

    private func hideMainWindow() {
        mainWindow?.orderOut(nil)
    }

    private func toggleMainWindow() {
        if let window = mainWindow, window.isVisible {
            hideMainWindow()
        } else {
            showMainWindow()
        }
    }

    private func findNSTextView(in view: NSView?) -> NSTextView? {
        guard let view = view else { return nil }
        if let textView = view as? NSTextView, textView.isEditable, textView.acceptsFirstResponder {
            return textView
        }
        for subview in view.subviews {
            if let textView = findNSTextView(in: subview) {
                return textView
            }
        }
        if let scrollView = view as? NSScrollView,
           let docView = scrollView.documentView as? NSTextView,
           docView.isEditable, docView.acceptsFirstResponder {
            return docView
        }
        return nil
    }

    func openSettingsWindow() {
        let existingWindow = NSApp.windows.first { $0.identifier == settingsWindowIdentifier }
        if let window = existingWindow {
            window.makeKeyAndOrderFront(self)
        } else {
            let settingsView = SettingsView().environmentObject(appData)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 200),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered, defer: false)
            window.identifier = settingsWindowIdentifier
            window.center()
            window.setFrameAutosaveName("Settings Window")
            window.contentView = NSHostingView(rootView: settingsView)
            window.isReleasedWhenClosed = false
            window.makeKeyAndOrderFront(self)
        }
    }

    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == mainWindow {
            mainWindow = nil
            hostingView = nil
        }
    }

    func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == mainWindow {
            DispatchQueue.main.async {
                if let textView = self.findNSTextView(in: self.hostingView) {
                    window.makeFirstResponder(textView)
                }
            }
        }
    }

    func windowDidResignKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == mainWindow {
            hideMainWindow()
        }
    }
}
