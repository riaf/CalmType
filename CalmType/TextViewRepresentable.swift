import SwiftUI
import AppKit
import Carbon.HIToolbox

/// A SwiftUI wrapper for NSTextView that handles Cmd+Enter and Esc directly.
struct CustomTextEditor: NSViewRepresentable {
    @Binding var text: String
    var onCopy: () -> Void
    var onCancel: () -> Void = {
        NotificationCenter.default.post(name: .hideMainWindow, object: nil)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        // Create scroll view container
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        scroll.hasHorizontalScroller = false
        scroll.drawsBackground = false
        scroll.borderType = .noBorder

        // Configure text view
        let textView = CopyOnCmdEnterTextView(frame: .zero)
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = NSSize(width: 5, height: 5)
        textView.onCopy = onCopy
        textView.onCancel = onCancel
        // Ensure background and text color are set for visibility
        textView.drawsBackground = true
        textView.backgroundColor = .textBackgroundColor

        // Enable dynamic resizing within scroll view
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: scroll.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true

        // Embed text view in scroll view
        scroll.documentView = textView
        return scroll
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CustomTextEditor
        init(_ parent: CustomTextEditor) { self.parent = parent }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            parent.text = tv.string
        }
    }
}

/// NSTextView subclass that triggers onCopy() for Cmd+Enter and onCancel() for Esc.
class CopyOnCmdEnterTextView: NSTextView {
    var onCopy: (() -> Void)?
    var onCancel: (() -> Void)?

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command)
            && (event.keyCode == UInt16(kVK_Return) || event.keyCode == UInt16(kVK_ANSI_KeypadEnter))
        {
            onCopy?()
        } else if event.keyCode == UInt16(kVK_Escape) {
            onCancel?()
        } else {
            super.keyDown(with: event)
        }
    }
}