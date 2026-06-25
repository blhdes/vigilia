import SwiftUI

/// The release, drawn glyph by glyph. Each letter of the well-wishing lifts, drifts a little
/// sideways, blurs, and fades on its own slightly-offset schedule, so the words come apart
/// into light and ascend like embers, dissolving into the upper darkness. An offering, never
/// an erasure (see the vault note "Ephemerality & transmutation").
///
/// Restraint is the whole point: the rise is short and the fade keeps pace with it, so the
/// motes go out as they lift rather than flying off. It must never read as confetti.
///
/// Driven by `progress` (0 = whole and bright, 1 = gone). The renderer is `Animatable`, so
/// animating `progress` with `Motion.ascension` interpolates it frame by frame. Uses iOS 18's
/// `TextRenderer`, which gives per-glyph access to the laid-out text.
struct EmberAscension: TextRenderer, Animatable {
    /// 0 → 1 across the whole dissolve.
    var progress: Double

    // Feel — all tunable.
    private let stagger: Double = 0.35     // how much the dissolve sweeps from the line's start to its end
    private let rise: CGFloat = 46         // how far a glyph lifts (kept short; the fade finishes it)
    private let drift: CGFloat = 9         // sideways scatter, like embers
    private let maxBlur: CGFloat = 8

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let slices = layout.flatMap { line in line.flatMap { run in run } }
        let count = max(slices.count, 1)

        for (i, slice) in slices.enumerated() {
            // Each glyph begins a little after the one before it, then takes the rest of the
            // timeline to dissolve: a gentle wave from the start of the line to its end.
            let delay = (Double(i) / Double(count)) * stagger
            let local = (progress - delay) / max(1 - stagger, 0.001)
            let t = min(max(local, 0), 1)

            guard t > 0 else {
                context.draw(slice)        // not lifting yet: draw it whole
                continue
            }

            // Deterministic per-glyph jitter: organic scatter that never changes between runs.
            let jitter = sin(Double(i) * 21.17)

            var copy = context
            copy.opacity = 1 - t                                   // goes out as it lifts
            copy.translateBy(x: drift * CGFloat(jitter) * CGFloat(t),
                             y: -rise * CGFloat(pow(t, 1.3)))       // a short, easing rise
            copy.addFilter(.blur(radius: maxBlur * CGFloat(t)))    // coming apart into light
            copy.draw(slice)
        }
    }
}
