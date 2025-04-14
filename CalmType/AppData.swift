import SwiftUI
import AppKit

extension Notification.Name {
    static let hideMainWindow = Notification.Name("hideMainWindow")
}

class AppData: ObservableObject {
    @Published var inputText: String = ""

    func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(inputText, forType: .string)
        print("Copied to clipboard (Cmd+Enter): \(inputText)")
        NotificationCenter.default.post(name: .hideMainWindow, object: nil)
    }
}
