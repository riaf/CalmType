import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @AppStorage("showShortcutHints") private var showShortcutHints = true
    @AppStorage("clearInputAfterCopy") private var clearInputAfterCopy = true
    @AppStorage("closeWindowAfterCopy") private var closeWindowAfterCopy = true

    var body: some View {
        Form {
            Section {
                KeyboardShortcuts.Recorder("App Toggle:", name: .toggleCalmTypeWindow)
            } header: {
                Text(String(localized: "Shortcuts"))
            }

            Section {
                Toggle(String(localized: "Show shortcut hint in main window"), isOn: $showShortcutHints)
                Toggle(String(localized: "Clear input after successful copy"), isOn: $clearInputAfterCopy)
                Toggle(String(localized: "Close window after successful copy"), isOn: $closeWindowAfterCopy)
            } header: {
                Text(String(localized: "Behavior"))
            }
        }
        .padding()
        .frame(minWidth: 420, idealWidth: 460)
    }
}

#Preview {
    SettingsView()
}
