import SwiftUI
import KeyboardShortcuts
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private(set) var mainWindow: NSWindow?
    let appData = AppData()
    private var previousActiveApp: NSRunningApplication?

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
        window.minSize = NSSize(width: 520, height: 300)
        window.isMovableByWindowBackground = true
        window.collectionBehavior.insert(.moveToActiveSpace)

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
        cachePreviousActiveAppIfNeeded()
        NSApplication.shared.activate(ignoringOtherApps: true)
        mainWindow?.makeKeyAndOrderFront(nil)
    }

    private func hideMainWindow() {
        mainWindow?.orderOut(nil)
        restorePreviousActiveAppIfNeeded()
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

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if sender == mainWindow {
            hideMainWindow()
            return false
        }
        return true
    }

    private func cachePreviousActiveAppIfNeeded() {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else { return }
        let currentPID = ProcessInfo.processInfo.processIdentifier
        guard frontmostApp.processIdentifier != currentPID else { return }
        previousActiveApp = frontmostApp
    }

    private func restorePreviousActiveAppIfNeeded() {
        guard let app = previousActiveApp,
              !app.isTerminated else { return }
        _ = app.activate(options: [.activateIgnoringOtherApps])
    }
}
