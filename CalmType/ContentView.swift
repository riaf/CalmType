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
            ZStack(alignment: .topLeading) {
                CustomTextEditor(
                    text: $appData.inputText,
                    onCopy: handleCopy,
                    onCancel: onRequestClose
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 6)

                if appData.inputText.isEmpty {
                    Text(String(localized: "Type your text here..."))
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 16)
                        .padding(.leading, 18)
                        .allowsHitTesting(false)
                }
            }

            Divider()

            HStack(spacing: 10) {
                if showShortcutHints {
                    Text(String(localized: "Shortcut: ⌘ + Enter"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(String(localized: "Clear")) {
                    appData.clearInput()
                }
                .buttonStyle(.bordered)
                .disabled(!canCopy)

                Button(String(localized: "Copy")) {
                    handleCopy()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
                .disabled(!canCopy)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.bar)
        }
        .overlay(alignment: .topTrailing) {
            if isCopyFeedbackVisible {
                Text(String(localized: "Copied"))
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: Capsule(style: .continuous))
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
