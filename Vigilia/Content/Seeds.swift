import Foundation

/// PLACEHOLDER seed banks — just enough to feel the mechanism on device.
///
/// These are **not** final copy. Writing the real banks is a deliberate, load-bearing task
/// (see the vault note "Scope & open questions"): the voice must stay in a quiet,
/// quasi-liturgical cadence that never names a tradition — a believer should hear an echo
/// of prayer, a secular reader should hear only calm. Neither should meet a word that
/// belongs to someone else's church. Replace these freely.
enum Seeds {

    /// The opening line. Invites the person to bring the one who hurt them to mind.
    static let welcome: [String] = [
        "Bring to mind the one who has wounded you.",
        "Name here, once, what was done to you.",
        "Who lies heavy on your heart tonight?",
        "Call to mind the one you have not forgiven.",
        "Let the hurt be spoken, and then held.",
    ]

    /// The turn. Invites the well-wishing — the second movement, where the value is.
    static let wish: [String] = [
        "Now, wish them something good.",
        "Ask that it go well with them.",
        "Wish them, in spite of it, peace.",
        "Picture them well, and unafraid.",
        "Let the light fall on them too.",
    ]
}
