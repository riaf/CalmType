import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appData: AppData
    var onRequestClose: () -> Void = {}

    @AppStorage("showShortcutHints") private var showShortcutHints = true
    @AppStorage("clearInputAfterCopy") private var clearInputAfterCopy = true
    @AppStorage("closeWindowAfterCopy") private var closeWindowAfterCopy = true

    @State private var isCopyFeedbackVisible = false

    private var canCopy: Bool {
        !appData.inputText.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomTextEditor(
                text: $appData.inputText,
                onCopy: handleCopy,
                onCancel: onRequestClose
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(12)

            HStack {
                Button(String(localized: "Copy")) {
                    handleCopy()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
                .disabled(!canCopy)

                Button(String(localized: "Clear")) {
                    appData.clearInput()
                }
                .buttonStyle(.bordered)
                .disabled(!canCopy)

                Text("\(appData.inputText.count)")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 28, alignment: .trailing)
                Text(String(localized: "Characters"))
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Spacer()

                if showShortcutHints {
                    Text(String(localized: "Shortcut: ⌘ + Enter"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.bar)
        }
        .overlay(alignment: .topTrailing) {
            if isCopyFeedbackVisible {
                Text(String(localized: "Copied"))
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: Capsule())
                    .padding(12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private func handleCopy() {
        guard appData.copyToClipboard() else { return }

        if clearInputAfterCopy {
            appData.clearInput()
        }

        withAnimation(.snappy(duration: 0.2, extraBounce: 0)) {
            isCopyFeedbackVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.snappy(duration: 0.2, extraBounce: 0)) {
                isCopyFeedbackVisible = false
            }
        }

        if closeWindowAfterCopy {
            onRequestClose()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppData())
        .frame(width: 450, height: 350)
}
