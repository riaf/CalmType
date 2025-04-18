import SwiftUI
import KeyboardShortcuts
import AppKit
// Removed Carbon.HIToolbox import; key event handling moved to CustomTextEditor

extension AppDelegate {
    static var shared: AppDelegate? {
        NSApp.delegate as? AppDelegate
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    private(set) var mainWindow: NSWindow?
    private var hostingView: NSView?
    let appData = AppData()

    private let mainWindowIdentifier = NSUserInterfaceItemIdentifier("mainWindow")
    private let settingsWindowIdentifier = NSUserInterfaceItemIdentifier("settingsWindow")

    // Observer token for hideMainWindow notification
    private var hideMainWindowObserver: NSObjectProtocol?

    // private var eventMonitor: Any? // Removed; event handling in CustomTextEditor

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupKeyboardShortcuts()
        setupNotificationObserver()
        // Show main window on launch
        showMainWindow()
    }
    
    /// If the app becomes active and no windows are visible, open the main window
    func applicationDidBecomeActive(_ notification: Notification) {
        let hasVisible = NSApp.windows.contains { $0.isVisible }
        if !hasVisible {
            showMainWindow()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Remove notification observer
        if let observer = hideMainWindowObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        // Local event monitoring removed; no teardown required
    }

    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyDown(for: .toggleCalmTypeWindow) { [weak self] in
            self?.toggleMainWindow()
        }
    }

    private func setupNotificationObserver() {
        // Observe hideMainWindow notification
        hideMainWindowObserver = NotificationCenter.default.addObserver(
            forName: .hideMainWindow,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.hideMainWindow()
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

        window.center()
        mainWindow = window
    }

    func showMainWindow() {
        if mainWindow == nil {
            createMainWindow()
        }
        NSApplication.shared.activate(ignoringOtherApps: true)
        mainWindow?.makeKeyAndOrderFront(nil)
        // Key event monitoring handled by CustomTextEditor
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

    // findNSTextView removed; using CustomTextEditor lookup

    private func findScrollView(in view: NSView?) -> NSScrollView? {
        guard let v = view else { return nil }
        if let sv = v as? NSScrollView { return sv }
        for sub in v.subviews {
            if let found = findScrollView(in: sub) { return found }
        }
        return nil
    }

    private func getTextView() -> NSTextView? {
        guard let host = hostingView,
              let scroll = findScrollView(in: host),
              let tv = scroll.documentView as? NSTextView else {
            return nil
        }
        return tv
    }

    func openSettingsWindow() {
        let existingWindow = NSApp.windows.first { $0.identifier == settingsWindowIdentifier }
        if let window = existingWindow {
            // Bring settings window to front above floating main window
            NSApp.activate(ignoringOtherApps: true)
            window.level = .floating
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
            window.level = .floating
            NSApp.activate(ignoringOtherApps: true)
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
        guard let window = notification.object as? NSWindow, window == mainWindow else { return }
        DispatchQueue.main.async {
            if let tv = self.getTextView() {
                window.makeFirstResponder(tv)
            }
        }
    }

    func windowDidResignKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == mainWindow {
            // Do not hide if switching to settings window
            if let keyWin = NSApp.keyWindow, keyWin.identifier == settingsWindowIdentifier {
                return
            }
            hideMainWindow()
        }
    }
}
