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

    /// Live finger travel for the current gesture. Drives the wound's dim-and-sink in real
    /// time so the swipe never feels dead. Reset (with animation) on commit or settle-back.
    @State private var dragY: CGFloat = 0

    private let sealThreshold: CGFloat = 90      // how far down to seal the wound
    private let releaseThreshold: CGFloat = 90   // how far up to release the wish

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Theme.lineGap) {
                // The wound. Editable while naming; afterwards a dimmed, read-only memory
                // that has receded into the penumbra. It fades out as the wish ascends.
                if model.phase != .void {
                    WritingLine(text: $model.wound,
                                seed: model.welcomeSeed,
                                glow: woundGlow,
                                lift: woundLift,
                                editable: model.phase == .naming,
                                focus: $focus,
                                field: .wound)
                        .opacity(model.phase == .ascending ? 0 : 1)

                    // Pull down to seal. The hint appears once the wound has been named.
                    BreathHint(systemName: "chevron.compact.down",
                               visible: model.phase == .naming && model.canSeal)
                        .padding(.top, 2)
                }

                // The well-wishing. Appears on the next line of the *same* canvas — one
                // continuous flow, no new screen — and plays the ascension when released.
                if model.phase == .wishing || model.phase == .ascending {
                    WritingLine(text: $model.wish,
                                seed: model.wishSeed,
                                glow: Theme.voiceGlow,
                                lift: wishLift,
                                editable: model.phase == .wishing,
                                focus: $focus,
                                field: .wish)
                        .ascending(model.phase == .ascending)
                        .transition(.opacity)

                    // Send up to release.
                    BreathHint(systemName: "chevron.compact.up",
                               visible: model.phase == .wishing && model.canRelease)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, Theme.margin)
            .padding(.top, Theme.topInset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .contentShape(Rectangle())
        // Draw the wound DOWN to seal it; send the wish UP to release it. The wound now
        // responds the whole way (see `woundGlow` / `woundLift`), so the gesture is felt as
        // it happens, not only at the end. Starting the drag from the hint / open area below
        // the text is the most reliable spot (a drag over long text can fight the field).
        .simultaneousGesture(dragGesture)
        // In the void, a silent tap begins a new vigil. No button — the emptiness is the point.
        .onTapGesture { if model.phase == .void { beginAgain() } }
        // A single low haptic beat as the wound locks; a soft one as the wish is released.
        .sensoryFeedback(trigger: model.phase) { _, now in
            switch now {
            case .wishing:   return .impact(weight: .heavy, intensity: 0.5)
            case .ascending: return .impact(weight: .light, intensity: 0.3)
            default:         return nil
            }
        }
        // A beat of stillness to let the welcome line breathe, then the field invites you in.
        .task {
            try? await Task.sleep(for: .seconds(0.6))
            if model.phase == .naming { focus = .wound }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Live drag feedback

    /// 0 → 1 across the current gesture's threshold (downward while naming, upward while wishing).
    private var dragProgress: CGFloat {
        switch model.phase {
        case .naming:  return max(0, min(1, dragY / sealThreshold))
        case .wishing: return max(0, min(1, -dragY / releaseThreshold))
        default:       return 0
        }
    }

    /// The wound burns at full light while you write, and dims toward the penumbra as you
    /// push it down. Once sealed it stays dim.
    private var woundGlow: Double {
        guard model.phase == .naming else { return Theme.woundGlow }
        return Theme.voiceGlow - (Theme.voiceGlow - Theme.woundGlow) * Double(dragProgress)
    }

    /// The wound sinks as you draw it down.
    private var woundLift: CGFloat {
        model.phase == .naming ? max(0, dragY) * 0.3 : 0
    }

    /// The wish rises a little as you lift it, then the ascension carries it the rest of the way.
    private var wishLift: CGFloat {
        model.phase == .wishing ? min(0, dragY) * 0.35 : 0
    }

    // MARK: - Gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in dragY = value.translation.height }  // tracked live, no animation
            .onEnded { _ in onDragEnded() }
    }

    private func onDragEnded() {
        if model.phase == .naming, dragY > sealThreshold {
            // Seal: the wound settles into its dimmed, locked state; the caret follows down.
            withAnimation(Motion.seal) {
                model.seal()
                dragY = 0
            }
            focus = .wish
        } else if model.phase == .wishing, -dragY > releaseThreshold {
            // Release: the wish keeps rising into the ascension, then the screen returns to void.
            focus = nil
            withAnimation(Motion.ascension) {
                model.release()
                dragY = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Motion.ascensionDuration) {
                withAnimation(Motion.toVoid) { model.enterVoid() }
            }
        } else {
            // Didn't reach the threshold: settle gently back to where it was.
            withAnimation(Motion.seal) { dragY = 0 }
        }
    }

    private func beginAgain() {
        withAnimation(Motion.breath) { model.beginAgain() }
        dragY = 0
        focus = nil
    }
}
