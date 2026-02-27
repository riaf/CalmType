import SwiftUI

@main
struct CalmTypeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(String(localized: "New Window")) {
                    appDelegate.showMainWindow()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
