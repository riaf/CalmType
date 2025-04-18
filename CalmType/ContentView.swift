import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var appData: AppData

    var body: some View {
        VStack(spacing: 0) {
            CustomTextEditor(
                text: $appData.inputText,
                onCopy: appData.copyToClipboard
            )
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack {
                Spacer()
                Text("Copy:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("⌘ + Enter")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .background(Material.regular)
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppData())
        .frame(width: 450, height: 350)
}
