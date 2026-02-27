import SwiftUI
import KeyboardShortcuts
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private(set) var mainWindow: NSWindow?
    let appData = AppData()

    private let mainWindowIdentifier = NSUserInterfaceItemIdentifier("mainWindow")

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupKeyboardShortcuts()
        showMainWindow()
    }

    /// If the app becomes active and no windows are visible, open the main window.
    func applicationDidBecomeActive(_ notification: Notification) {
        let hasVisible = NSApp.windows.contains { $0.isVisible }
        if !hasVisible {
            showMainWindow()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showMainWindow()
        }
        return true
    }

    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyDown(for: .toggleCalmTypeWindow) { [weak self] in
            self?.toggleMainWindow()
        }
    }

    private func createMainWindow() {
        guard mainWindow == nil else { return }

        let contentView = ContentView(
            onRequestClose: { [weak self] in
                self?.hideMainWindow()
            }
        )
        .environmentObject(appData)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 350),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)

        window.identifier = mainWindowIdentifier
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.level = .normal
        window.backgroundColor = .windowBackgroundColor
        window.isOpaque = true
        window.hasShadow = true

        window.title = "CalmType"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.toolbarStyle = .unifiedCompact

        window.contentView = NSHostingView(rootView: contentView)

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

    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == mainWindow {
            mainWindow = nil
        }
    }
}
