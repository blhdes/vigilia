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
}

/// Motion is slow, at the tempo of a breath — never the tempo of a UI animation. Nothing
/// bounces, nothing is snappy (so: `easeInOut`, long durations, no springs). Test every
/// future animation against one sentence: does it *hold the space*, or does it react fast?
enum Motion {
    static let ascensionDuration: Double = 3.6
    static let voidDuration: Double = 2.4

    static let breath = Animation.easeInOut(duration: 1.6)
    static let seal = Animation.easeInOut(duration: 1.1)
    static let ascension = Animation.easeIn(duration: ascensionDuration)
    static let toVoid = Animation.easeInOut(duration: voidDuration)
}
