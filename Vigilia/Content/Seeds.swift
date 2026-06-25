import Foundation

/// The seed banks: the changing lines that open a vigil and turn it toward kindness.
///
/// Grief is not only caused by others, so the seeds are grouped into **registers** — a
/// person, yourself, a shared situation, a formless loss. Each open draws one register at
/// random and shows a welcome line and a turn from *the same* register, so the two always
/// cohere (you are never asked to "wish them well" about a grief that has no "them"). The
/// hardest case, blessing the one who hurt you, is simply one register among several now,
/// not the only door — which is also what makes the app worth returning to on the nights
/// you are not angry at anyone, only grieving.
///
/// Still **drafts** — the voice is the user's to own. The cadence stays quiet and
/// quasi-liturgical and never names a tradition: a believer hears an echo of prayer, a
/// secular reader hears only calm. Within a register, any welcome pairs with any turn, so
/// keep each register's "who" consistent (its *them* / *yourself* / *all of you* / *it*).
enum Seeds {

    struct Register {
        let welcomes: [String]   // the opening: what to bring to mind
        let turns: [String]      // the loving-kindness line that answers it
    }

    /// A person who wronged you — the original "love your enemy" case. Who: *them*.
    static let aPerson = Register(
        welcomes: [
            "Bring to mind the one who has wounded you.",
            "Call to mind the one you have not forgiven.",
            "Whose name still tightens your chest?",
            "Bring the one who wronged you into this quiet.",
            "Who has taken something you cannot get back?",
        ],
        turns: [
            "Wish them, in spite of it, peace.",
            "Ask that it go well with them.",
            "Wish them well on their way.",
            "Let the light fall on them too.",
            "Wish for them what you would wish for yourself.",
        ]
    )

    /// Yourself — regret, shame, the harm you caused. Who: *yourself*.
    static let yourself = Register(
        welcomes: [
            "Where have you failed yourself?",
            "Name what you cannot forgive in yourself.",
            "What do you keep punishing yourself for?",
            "Bring to mind the harm you caused.",
            "Where are you hardest on yourself tonight?",
        ],
        turns: [
            "Offer yourself the kindness you would give a friend.",
            "Wish yourself, too, some mercy.",
            "Let yourself be more than your worst day.",
            "Wish yourself gently forward.",
            "Set it down. You are allowed.",
        ]
    )

    /// A shared situation, more than one caught in it. Who: *all of you*.
    static let aSituation = Register(
        welcomes: [
            "Bring to mind the rift, and all it holds.",
            "Call to mind those caught in it with you.",
            "What has come between you and them?",
            "Bring the whole tangled situation into the light.",
            "Who is hurting, on every side of this?",
        ],
        turns: [
            "Wish them all, each one, some peace.",
            "Let it come to rest between you.",
            "Wish every side of it gently free.",
            "Hope for a way through, for all of you.",
            "Let something good be salvaged here.",
        ]
    )

    /// A loss with no one to blame. Who: *it, and you in it*.
    static let aLoss = Register(
        welcomes: [
            "Bring to mind the loss that no one chose.",
            "Name the grief that has no one to blame.",
            "What was taken that no one meant to take?",
            "Bring the ache of it into this quiet.",
            "What weighs on you that simply happened?",
        ],
        turns: [
            "Let the light fall on it, and on you.",
            "Wish the world, and yourself in it, some softness.",
            "Let something good come, in time, of this.",
            "Wish gentleness toward all of it.",
            "Hold it a moment, then let it rise.",
        ]
    )

    static let registers: [Register] = [aPerson, yourself, aSituation, aLoss]

    /// Draw a coherent opening: a welcome line and a turn from the *same* register.
    static func draw() -> (welcome: String, turn: String) {
        let register = registers.randomElement() ?? aPerson
        return (register.welcomes.randomElement() ?? "",
                register.turns.randomElement() ?? "")
    }
}
