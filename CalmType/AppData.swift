import SwiftUI
import AppKit
import OSLog

class AppData: ObservableObject {
    @Published var inputText: String = ""
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CalmType", category: "Clipboard")

    @discardableResult
    func copyToClipboard() -> Bool {
        let content = inputText
        guard !content.isEmpty else {
            logger.notice("Copy skipped: input is empty")
            return false
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let success = pasteboard.setString(content, forType: .string)

        if success {
            // Log only length publicly; redact actual content as private
            logger.info("Copied to clipboard: length=\(content.count), data=\(content, privacy: .private)")
        } else {
            // Log failure with length info
            logger.error("Failed to copy to clipboard: length=\(content.count)")
        }
        return success
    }

    func clearInput() {
        inputText = ""
    }
}
