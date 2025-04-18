import SwiftUI
import AppKit
import OSLog

extension Notification.Name {
    static let hideMainWindow = Notification.Name("hideMainWindow")
}

class AppData: ObservableObject {
    @Published var inputText: String = ""

    func copyToClipboard() {
        let content = inputText
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let success = pasteboard.setString(content, forType: .string)
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CalmType", category: "Clipboard")
        if success {
            // Log only length publicly; redact actual content as private
            logger.info("Copied to clipboard: length=\(content.count), data=\(content, privacy: .private)")
        } else {
            // Log failure with length info
            logger.error("Failed to copy to clipboard: length=\(content.count)")
        }
        inputText = ""
        NotificationCenter.default.post(name: .hideMainWindow, object: nil)
    }
}
