import Foundation
import Observation

/// The phases of a single vigil. The app is only ever in one of these, and it always moves
/// *forward* — naming → wishing → ascending → void. There is no way back to an earlier
/// phase, by design: you cannot return to re-edit the wound. The only way is onward.
enum RitualPhase {
    case naming      // bringing the wound to mind and naming it
    case wishing     // the wound is sealed and dimmed; now writing the well-wishing
    case ascending   // the words rise and dissolve into light
    case void        // total black; nothing of the note remains
}

@Observable
final class RitualModel {

    private(set) var phase: RitualPhase = .naming

    var wound: String = ""
    var wish: String = ""

    /// The changing opening line, and the loving-kindness line. Chosen fresh each launch so
    /// the app greets you a little differently every time — the structure of the ritual
    /// lives in this language, not in any visible "step 1 / step 2" chrome.
    private(set) var welcomeSeed: String
    private(set) var wishSeed: String

    init() {
        welcomeSeed = Seeds.welcome.randomElement() ?? ""
        wishSeed = Seeds.wish.randomElement() ?? ""
    }

    var canSeal: Bool { phase == .naming && !wound.isBlank }
    var canRelease: Bool { phase == .wishing && !wish.isBlank }

    /// The swipe-down: the person decides the wound is fully named. It locks for good.
    func seal() {
        guard canSeal else { return }
        phase = .wishing
    }

    /// The release: the well-wishing is offered up, and the ascension begins.
    func release() {
        guard canRelease else { return }
        phase = .ascending
    }

    /// The note turns to nothing. Because nothing was ever written to disk, "letting go" is
    /// literally just this — clearing two strings from memory. Ephemerality by construction,
    /// not by a cleanup step we could forget.
    func enterVoid() {
        phase = .void
        wound = ""
        wish = ""
    }

    /// A new vigil, with new seeds.
    func beginAgain() {
        welcomeSeed = Seeds.welcome.randomElement() ?? ""
        wishSeed = Seeds.wish.randomElement() ?? ""
        phase = .naming
    }
}

private extension String {
    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}
