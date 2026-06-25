import SwiftUI

/// One line of the ritual canvas. The wound and the well-wishing are the **same** component
/// on purpose: keeping them identical is what makes the screen read as a single continuous
/// canvas — one movement of the heart — rather than two separate tasks on two screens.
///
/// Two typographic registers live here, and the difference carries meaning: the `seed`
/// placeholder is New York *display, light* (the app's whisper), while the person's own
/// words are New York *regular* at reading size (the louder voice).
///
/// `glow` and `lift` are driven live by the parent so the line can respond to the seal
/// gesture in real time (dimming and sinking under the finger), instead of only snapping at
/// the end. The parent owns the animation timing, so there is no implicit animation here.
struct WritingLine: View {
    @Binding var text: String
    let seed: String
    let glow: Double          // luminosity of the person's words right now (0...1 of `light`)
    let lift: CGFloat         // live vertical offset from the drag / seal feedback
    let editable: Bool
    var focus: FocusState<RitualField?>.Binding
    let field: RitualField

    var body: some View {
        ZStack(alignment: .topLeading) {
            // The seed does not blink out the instant you type. It fades and lifts gently
            // away, so the invitation gives way to the voice instead of being overwritten.
            // This is the fix for both the missing fade and your words sitting on top of it.
            Text(seed)
                .font(Theme.display)
                .foregroundStyle(Theme.light.opacity(Theme.seedGlow))
                .lineSpacing(Theme.seedLeading)
                .opacity(text.isEmpty ? 1 : 0)
                .offset(y: text.isEmpty ? 0 : -14)
                .allowsHitTesting(false)
                .animation(Motion.fade, value: text.isEmpty)

            TextField("", text: $text, axis: .vertical)
                .font(Theme.body)
                .foregroundStyle(Theme.light.opacity(glow))
                .tint(Theme.light)                    // the caret is warm-bone, not system blue
                .lineSpacing(Theme.bodyLeading)
                .textInputAutocapitalization(.sentences)
                .focused(focus, equals: field)
                .disabled(!editable)                  // a sealed wound can't be re-edited
        }
        .offset(y: lift)
    }
}
