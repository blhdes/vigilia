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
/// gesture in real time. The parent owns that animation timing, so there is none here.
struct WritingLine: View {
    @Binding var text: String
    let seed: String
    let glow: Double            // luminosity of the person's words right now (0...1 of `light`)
    let lift: CGFloat           // live vertical offset from the drag / seal feedback
    let editable: Bool
    let isActive: Bool          // is this line's field currently focused
    let dismissSeedOnFocus: Bool
    var focus: FocusState<RitualField?>.Binding
    let field: RitualField

    /// The welcome line leaves the instant you press in (so no field sits over it); the wish
    /// line stays as a prompt while the field is focused-but-empty, leaving only when you write.
    private var showSeed: Bool {
        text.isEmpty && !(dismissSeedOnFocus && isActive)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(seed)
                .font(Theme.display)
                .foregroundStyle(Theme.light.opacity(Theme.seedGlow))
                .lineSpacing(Theme.seedLeading)
                .opacity(showSeed ? 1 : 0)
                .allowsHitTesting(false)
                .animation(Motion.fade, value: showSeed)

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
