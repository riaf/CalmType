import SwiftUI

@main
struct CalmTypeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(appDelegate.appData)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(String(localized: "New Window")) {
                    if appDelegate.mainWindow == nil {
                        appDelegate.showMainWindow()
                    }
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button(String(localized: "Settings...")) {
                    appDelegate.openSettingsWindow()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
