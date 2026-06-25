import SwiftUI

/// The release. The words themselves rise, fade, and dissolve upward into the dark — an
/// offering, never an erasure. (See the vault note "Ephemerality & transmutation": the
/// distinction between *ascending* and *deleting* is load-bearing and must survive here.
/// Ascending reads as letting go; wiping would read as repression.)
///
/// This is a deliberately restrained **placeholder**. The final technique — a particle
/// system vs. dissolving the actual glyphs — is still an open question. Whatever replaces
/// it must read as rising-and-offering, and must never look like festive confetti.
private struct Ascending: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        content
            .blur(radius: active ? 16 : 0)      // the letters come apart
            .opacity(active ? 0 : 1)            // and fade to nothing
            .scaleEffect(active ? 1.06 : 1)     // loosening as they lift
            .offset(y: active ? -240 : 0)       // rising into the upper darkness
    }
}

extension View {
    /// Apply the ascension to a piece of text. Animate the `active` flag with
    /// `Motion.ascension` so the rise happens at the tempo of a breath.
    func ascending(_ active: Bool) -> some View {
        modifier(Ascending(active: active))
    }
}
