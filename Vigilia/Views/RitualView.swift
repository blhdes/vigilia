import SwiftUI

/// Which line holds the caret. Sealing the wound moves focus *down* to the wish line — the
/// only direction the ritual ever travels.
enum RitualField { case wound, wish }

/// The whole app is this one screen. There is no navigation, no second view: the session is
/// a single canvas whose *state* changes — naming the wound, sealing it, wishing well, the
/// ascension, the void.
///
/// The seal / release gesture lives on a **fixed handle at the bottom centre**, never on the
/// text, so a drag can't fight the text field. A dimming glass scrim protects the bottom so
/// the writing dissolves into it rather than colliding with the handle.
struct RitualView: View {
    @State private var model = RitualModel()
    @FocusState private var focus: RitualField?
    @State private var dragY: CGFloat = 0
    @State private var ascend: Double = 0          // 0 = wish whole & bright, 1 = ascended & gone
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let sealThreshold: CGFloat = 48        // pull the handle down this far to seal
    private let releaseThreshold: CGFloat = 64     // push it up this far to release

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
                    .opacity(model.phase == .ascending ? 1 - ascend : 1)  // fades out with the ascending wish
            }

            switch model.phase {
            case .wishing:
                WritingLine(text: $model.wish,
                            seed: model.wishSeed,
                            glow: Theme.voiceGlow,
                            lift: 0,
                            editable: true,
                            isActive: focus == .wish,
                            dismissSeedOnFocus: false,     // the wish prompt stays until you write
                            focus: $focus,
                            field: .wish)
                    .transition(.opacity)
            case .ascending:
                ascendingWish                              // the same words, now a Text we can dissolve
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, Theme.margin)
        .padding(.top, Theme.topInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // The writing fades over its last stretch, dissolving toward the glass rather than
        // running into it. (Long entries may want a scroll-to-caret later.)
        .mask(
            LinearGradient(stops: [
                .init(color: .black, location: 0),
                .init(color: .black, location: 0.90),
                .init(color: .clear, location: 1.0),
            ], startPoint: .top, endPoint: .bottom)
        )
        .contentShape(Rectangle())
        // Press anywhere to begin (so pressing *over the welcome line* makes it leave at once).
        // Runs alongside the field's own tap, so caret behaviour still works.
        .simultaneousGesture(TapGesture().onEnded {
            switch model.phase {
            case .naming:    focus = .wound
            case .wishing:   focus = .wish
            case .void:      beginAgain()
            case .ascending: break
            }
        })
    }

    /// The well-wishing during the release: a plain `Text` (so the renderer can take it apart
    /// glyph by glyph) styled to match the line it replaces. Under Reduce Motion it just fades.
    private var ascendingWish: some View {
        let wish = Text(model.wish)
            .font(Theme.body)
            .foregroundStyle(Theme.light.opacity(Theme.voiceGlow))
        return Group {
            if reduceMotion {
                wish.opacity(1 - ascend)
            } else {
                wish.textRenderer(EmberAscension(progress: ascend))
            }
        }
        .lineSpacing(Theme.bodyLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - The fixed handle + dimming glass

    private var bottomZone: some View {
        ZStack {
            // The dimming "liquid glass": a dark glass that fades in from the top, deepening
            // the existing darkness rather than adding a panel. Tune the prominence here if
            // it reads too bright.
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(LinearGradient(colors: [.clear, .black, .black],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(
                    LinearGradient(colors: [.clear, Theme.backgroundBottom.opacity(0.92)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .allowsHitTesting(false)

            // The handle: pull DOWN to seal, push UP to release. Breathes once there is
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

    private var dragProgress: CGFloat {
        model.phase == .naming ? max(0, min(1, dragY / sealThreshold)) : 0
    }
    private var woundGlow: Double {
        guard model.phase == .naming else { return Theme.woundGlow }
        return Theme.voiceGlow - (Theme.voiceGlow - Theme.woundGlow) * Double(dragProgress)
    }
    private var woundLift: CGFloat {
        (model.phase == .naming && !reduceMotion) ? dragProgress * 36 : 0
    }

    // MARK: - Commit

    private func onDragEnded() {
        if model.phase == .naming, dragY > sealThreshold {
            withAnimation(Motion.seal) {
                model.seal()
                dragY = 0
            }
            focus = .wish                       // the caret follows the wound downward
        } else if model.phase == .wishing, -dragY > releaseThreshold {
            release()
        } else {
            withAnimation(Motion.seal) { dragY = 0 }   // didn't reach: settle back
        }
    }

    private func release() {
        focus = nil
        dragY = 0
        ascend = 0
        model.release()                         // instant, seamless swap: the wish becomes a Text, whole and bright
        // Mount the whole Text first, then animate the dissolve, so the renderer starts from 0.
        DispatchQueue.main.async {
            withAnimation(Motion.ascension) { ascend = 1 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Motion.ascensionDuration + 0.05) {
            withAnimation(Motion.toVoid) { model.enterVoid() }
            ascend = 0
        }
    }

    private func beginAgain() {
        withAnimation(Motion.breath) { model.beginAgain() }
        dragY = 0
        ascend = 0
        focus = nil
    }
}
