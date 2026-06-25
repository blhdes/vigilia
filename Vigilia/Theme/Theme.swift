import SwiftUI

/// The visual language of Vigilia, in one place.
///
/// Governing rule: **the light emerges from the text, not from the background.** The
/// person's words are the only thing glowing in the dark, so almost everything below is a
/// *luminosity* (an opacity of `light`) rather than a separate colour. The darkness does
/// the dramatic work for free — a dimmed line genuinely recedes; a bright one genuinely
/// burns. The exact values here are placeholders, meant to be tuned against the build.
enum Theme {

    // MARK: Colour

    /// The one light in the app. Not pure white — a faint, warm-bone glow, like luminous ink.
    static let light = Color(red: 0.95, green: 0.92, blue: 0.84)

    /// A deep black that isn't flat: a near-imperceptible blue-violet underneath, with a
    /// little warmth, never a cold grey. The faint top-to-bottom shift keeps it from reading
    /// as a switched-off screen.
    static let background = LinearGradient(
        colors: [
            Color(red: 0.055, green: 0.052, blue: 0.078),
            Color(red: 0.026, green: 0.024, blue: 0.042),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// The dark end of the background, reused by the bottom dimming scrim so the glass reads
    /// as the same darkness deepening, not a foreign panel laid on top.
    static let backgroundBottom = Color(red: 0.026, green: 0.024, blue: 0.042)

    // MARK: Luminosity states (as opacities of `light`)

    /// The person's own words, at full light.
    static let voiceGlow: Double = 1.0
    /// The sealed wound: dropped in luminosity, receded into the penumbra.
    static let woundGlow: Double = 0.26
    /// A seed phrase: fainter than the voice. The app whispers; the person speaks.
    static let seedGlow: Double = 0.5

    // MARK: Type — New York (Apple's system serif), in two registers

    /// Seeds: New York *display*, light weight, large — so they breathe like verses.
    static let display = Font.system(size: 27, weight: .light, design: .serif)
    /// The person's text: New York *regular*, at reading size.
    static let body = Font.system(size: 20, weight: .regular, design: .serif)

    // MARK: Spacing

    static let seedLeading: CGFloat = 12   // wide leading lets the seeds breathe
    static let bodyLeading: CGFloat = 7
    static let lineGap: CGFloat = 20       // between the wound line and the wish line
    static let margin: CGFloat = 28
    static let topInset: CGFloat = 96
    static let bottomZoneHeight: CGFloat = 104   // the fixed pull-handle + dimming-glass zone
}

/// Motion is slow, at the tempo of a breath — never the tempo of a UI animation. Nothing
/// bounces, nothing is snappy (so: `easeInOut`, long durations, no springs). Test every
/// future animation against one sentence: does it *hold the space*, or does it react fast?
enum Motion {
    static let ascensionDuration: Double = 3.6
    static let voidDuration: Double = 2.4

    static let breath = Animation.easeInOut(duration: 1.6)
    /// The seed giving way to the voice. Quick and soft: it should clear out of the way of
    /// the first words, not linger over them (this is what fixes the raw, instant pop).
    static let fade = Animation.easeOut(duration: 0.5)
    static let seal = Animation.easeInOut(duration: 1.1)
    static let ascension = Animation.easeIn(duration: ascensionDuration)
    static let toVoid = Animation.easeInOut(duration: voidDuration)
}
