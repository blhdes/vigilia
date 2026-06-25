import SwiftUI

/// Which line holds the caret. Sealing the wound moves focus *down* to the wish line — the
/// only direction the ritual ever travels.
enum RitualField { case wound, wish }

/// The whole app is this one screen. There is no navigation, no second view: the session is
/// a single canvas whose *state* changes — naming the wound, sealing it, wishing well, the
/// ascension, the void.
///
/// The seal / release gesture lives on a **fixed handle at the bottom centre**, never on the
/// text. Reading a drag over a text field fought the field and made the seal unreliable; a
/// dedicated handle is robust and always in the same place. A dimming glass scrim sits over
/// the bottom so the writing dissolves into it instead of colliding with the handle.
struct RitualView: View {
    @State private var model = RitualModel()
    @FocusState private var focus: RitualField?

    /// Live finger travel on the bottom handle. Drives the wound's dim-and-sink in real time.
    @State private var dragY: CGFloat = 0

    private let sealThreshold: CGFloat = 48      // pull the handle down this far to seal
    private let releaseThreshold: CGFloat = 64   // push it up this far to release

    private var isWriting: Bool { model.phase == .naming || model.phase == .wishing }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            writingContent
        }
        // The handle floats just above the keyboard while writing, and rests at the bottom
        // otherwise. It reserves its own space, so the text can never sit beneath it.
        .safeAreaInset(edge: .bottom) {
            bottomZone
                .opacity(isWriting ? 1 : 0)
                .allowsHitTesting(isWriting)
                .animation(Motion.toVoid, value: isWriting)
        }
        .sensoryFeedback(trigger: model.phase) { _, now in
            switch now {
            case .wishing:   return .impact(weight: .heavy, intensity: 0.5)
            case .ascending: return .impact(weight: .light, intensity: 0.3)
            default:         return nil
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - The writing

    private var writingContent: some View {
        VStack(alignment: .leading, spacing: Theme.lineGap) {
            if model.phase != .void {
                WritingLine(text: $model.wound,
                            seed: model.welcomeSeed,
                            glow: woundGlow,
                            lift: woundLift,
                            editable: model.phase == .naming,
                            isActive: focus == .wound,
                            dismissSeedOnFocus: true,      // welcome leaves the moment you press in
                            focus: $focus,
                            field: .wound)
                    .opacity(model.phase == .ascending ? 0 : 1)
            }

            if model.phase == .wishing || model.phase == .ascending {
                WritingLine(text: $model.wish,
                            seed: model.wishSeed,
                            glow: Theme.voiceGlow,
                            lift: wishLift,
                            editable: model.phase == .wishing,
                            isActive: focus == .wish,
                            dismissSeedOnFocus: false,     // the wish prompt stays until you write
                            focus: $focus,
                            field: .wish)
                    .ascending(model.phase == .ascending)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, Theme.margin)
        .padding(.top, Theme.topInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // The writing fades out over its last stretch, so it dissolves toward the glass
        // rather than running into it. (Long entries may want a scroll-to-caret later.)
        .mask(
            LinearGradient(stops: [
                .init(color: .black, location: 0),
                .init(color: .black, location: 0.90),
                .init(color: .clear, location: 1.0),
            ], startPoint: .top, endPoint: .bottom)
        )
        .contentShape(Rectangle())
        // Press anywhere in the canvas to begin (and so press *over the welcome line* makes it
        // leave at once). Run alongside the field's own tap so caret behaviour still works.
        .simultaneousGesture(TapGesture().onEnded {
            switch model.phase {
            case .naming:    focus = .wound
            case .wishing:   focus = .wish
            case .void:      beginAgain()
            case .ascending: break
            }
        })
    }

    // MARK: - The fixed handle + dimming glass

    private var bottomZone: some View {
        ZStack {
            // The dimming "liquid glass": a dark glass that fades in from the top, deepening
            // the existing darkness rather than adding a panel. Liquid Glass proper on iOS 26;
            // a thin material below. Tune the prominence here if it reads too bright.
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(LinearGradient(colors: [.clear, .black, .black],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(
                    LinearGradient(colors: [.clear, Theme.backgroundBottom.opacity(0.92)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .allowsHitTesting(false)

            // The handle: pull DOWN to seal, push UP to release. It breathes once there is
            // something to commit, and marks the fixed centre you draw from.
            BreathHint(systemName: model.phase == .wishing ? "chevron.compact.up" : "chevron.compact.down",
                       visible: (model.phase == .naming && model.canSeal)
                             || (model.phase == .wishing && model.canRelease))
                .padding(.bottom, 6)
        }
        .frame(height: Theme.bottomZoneHeight)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 6)
                .onChanged { value in dragY = value.translation.height }
                .onEnded { _ in onDragEnded() }
        )
    }

    // MARK: - Live feedback

    /// 0 → 1 across the current gesture's threshold (down while naming, up while wishing).
    private var dragProgress: CGFloat {
        switch model.phase {
        case .naming:  return max(0, min(1, dragY / sealThreshold))
        case .wishing: return max(0, min(1, -dragY / releaseThreshold))
        default:       return 0
        }
    }

    /// The wound burns at full light while you write, dimming toward the penumbra as you draw
    /// it down. Once sealed it stays dim.
    private var woundGlow: Double {
        guard model.phase == .naming else { return Theme.woundGlow }
        return Theme.voiceGlow - (Theme.voiceGlow - Theme.woundGlow) * Double(dragProgress)
    }
    private var woundLift: CGFloat { model.phase == .naming ? dragProgress * 36 : 0 }
    private var wishLift: CGFloat { model.phase == .wishing ? -dragProgress * 60 : 0 }

    // MARK: - Commit

    private func onDragEnded() {
        if model.phase == .naming, dragY > sealThreshold {
            withAnimation(Motion.seal) {
                model.seal()
                dragY = 0
            }
            focus = .wish                       // the caret follows the wound downward
        } else if model.phase == .wishing, -dragY > releaseThreshold {
            focus = nil
            withAnimation(Motion.ascension) {
                model.release()
                dragY = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Motion.ascensionDuration) {
                withAnimation(Motion.toVoid) { model.enterVoid() }
            }
        } else {
            withAnimation(Motion.seal) { dragY = 0 }   // didn't reach: settle back
        }
    }

    private func beginAgain() {
        withAnimation(Motion.breath) { model.beginAgain() }
        dragY = 0
        focus = nil
    }
}
