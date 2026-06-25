import SwiftUI

/// Which line holds the caret. Sealing the wound moves focus *down* to the wish line — the
/// only direction the ritual ever travels.
enum RitualField { case wound, wish }

/// The whole app is this one screen. There is no navigation, no second view: the session is
/// a single canvas whose *state* changes — naming the wound, sealing it, wishing well, the
/// ascension, the void. Keeping it to one surface is what makes the ritual feel seamless.
struct RitualView: View {
    @State private var model = RitualModel()
    @FocusState private var focus: RitualField?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Theme.lineGap) {
                // The wound. Editable while naming; afterwards a dimmed, read-only memory
                // that has receded into the penumbra. It fades out entirely as the wish
                // ascends, so the screen can return to nothing.
                if model.phase != .void {
                    WritingLine(text: $model.wound,
                                seed: model.welcomeSeed,
                                isLocked: model.phase != .naming,
                                focus: $focus,
                                field: .wound)
                        .opacity(model.phase == .ascending ? 0 : 1)
                        .animation(Motion.toVoid, value: model.phase)
                }

                // The well-wishing. Appears on the next line of the *same* canvas — one
                // continuous flow, no new screen — and plays the ascension when released.
                if model.phase == .wishing || model.phase == .ascending {
                    WritingLine(text: $model.wish,
                                seed: model.wishSeed,
                                isLocked: false,
                                focus: $focus,
                                field: .wish)
                        .ascending(model.phase == .ascending)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, Theme.margin)
            .padding(.top, Theme.topInset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .contentShape(Rectangle())
        // Swipe DOWN to push the wound down and seal it; swipe UP to send the wish up and
        // release it. The gestures embody the metaphor, and they are deliberate — never an
        // automatic trigger on a typing pause, because people stop to think mid-sentence.
        // (Gesture reliability over a text field is fiddly; this may want refinement.)
        .simultaneousGesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    let dy = value.translation.height
                    if model.phase == .naming, dy > 60 {
                        seal()
                    } else if model.phase == .wishing, dy < -60 {
                        release()
                    }
                }
        )
        // In the void, a silent tap begins a new vigil. No button — the emptiness is the point.
        .onTapGesture {
            if model.phase == .void { beginAgain() }
        }
        // A single low haptic beat at the exact moment the wound locks: closure you can feel.
        .sensoryFeedback(trigger: model.phase) { _, now in
            now == .wishing ? .impact(weight: .heavy, intensity: 0.5) : nil
        }
        .preferredColorScheme(.dark)
    }

    private func seal() {
        withAnimation(Motion.seal) { model.seal() }
        if model.phase == .wishing { focus = .wish }   // the caret follows the wound downward
    }

    private func release() {
        guard model.canRelease else { return }
        focus = nil
        withAnimation(Motion.ascension) { model.release() }
        // After the words have risen and gone out, the screen returns to the void.
        DispatchQueue.main.asyncAfter(deadline: .now() + Motion.ascensionDuration) {
            withAnimation(Motion.toVoid) { model.enterVoid() }
        }
    }

    private func beginAgain() {
        withAnimation(Motion.breath) { model.beginAgain() }
    }
}
