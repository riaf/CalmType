import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("App Toggle:", name: .toggleCalmTypeWindow)
        }
        .padding()
        .frame(minWidth: 300, idealWidth: 400)
    }
}

#Preview {
    SettingsView()
}
