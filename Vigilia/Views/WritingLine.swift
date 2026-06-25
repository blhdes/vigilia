import SwiftUI

/// One line of the ritual canvas. The wound and the well-wishing are the **same** component
/// on purpose: keeping them identical is what makes the screen read as a single continuous
/// canvas — one movement of the heart — rather than two separate tasks on two screens.
///
/// Two typographic registers live here, and the difference carries meaning: the `seed`
/// placeholder is New York *display, light* (the app's whisper), while the person's own
/// words are New York *regular* at reading size (the louder voice). The seed vanishes the
/// instant they begin to write, exactly like the welcome line.
struct WritingLine: View {
    @Binding var text: String
    let seed: String
    let isLocked: Bool
    var focus: FocusState<RitualField?>.Binding
    let field: RitualField

    var body: some View {
        ZStack(alignment: .topLeading) {
            // The seed: a faint invitation, never competing with the person's voice.
            // (The few points of inset here may want tuning on device so it sits exactly
            // under where the caret begins.)
            if text.isEmpty {
                Text(seed)
                    .font(Theme.display)
                    .foregroundStyle(Theme.light.opacity(Theme.seedGlow))
                    .lineSpacing(Theme.seedLeading)
                    .allowsHitTesting(false)
            }

            TextField("", text: $text, axis: .vertical)
                .font(Theme.body)
                .foregroundStyle(Theme.light.opacity(isLocked ? Theme.woundGlow : Theme.voiceGlow))
                .tint(Theme.light)                    // the caret is warm-bone, not system blue
                .lineSpacing(Theme.bodyLeading)
                .textInputAutocapitalization(.sentences)
                .focused(focus, equals: field)
                .disabled(isLocked)                   // a sealed wound can't be re-edited
        }
        .animation(Motion.seal, value: isLocked)
    }
}
