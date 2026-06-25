# Vigilia

An iOS app that turns a loving-kindness meditation into a single, quiet ritual.

You bring to mind something that weighs on you. It might be a person who hurt you, a way you have hurt yourself, a situation with more than one person caught in it, or a loss with no one to blame. You name it, then you turn toward wishing it well. When you finish, you release it: the words dissolve into light and rise, and nothing is kept. The next time you open the app, there is no history to return to. There was never meant to be.

## The idea

Vigilia is built around one practice, *Metta Bhavana* (loving-kindness), which traditionally moves through stages: kindness for yourself, for someone you love, for someone difficult, and for everyone. Vigilia holds space for any of these. The hardest of them, to wish well the one who wounded you, is one door among several, not the only one. It is a frame, not a journal. Its only job is to hold a space well enough that you want to return to it, including on the nights you are not angry at anyone, only grieving.

A session has two movements, on a single screen:

1. **Name it.** A changing opening line invites you in, and each time it opens a different kind of grief: a person, yourself, a shared situation, or a formless loss. You write what weighs on you.
2. **Wish it well.** The first line seals and dims and recedes. A second line appears in its place, matched to the same kind of grief, and you write the well-wishing at full light. Then you release it, and it rises and is gone.

The screen returns to black. The note exists nowhere.

## Why nothing is saved

Vigilia has no backend, no account, no sync, and no storage. Nothing you write is ever kept or sent anywhere.

This is the feature, not a limitation. A note you can re-read is a note you accumulate, and accumulation keeps a wound warm. A note that disappears the moment you finish is one you actually let go of. That is the difference between a release and a diary.

The disappearance is framed as an offering rather than an erasure. The words turn to light and ascend, instead of being wiped away.

## Privacy

Vigilia collects nothing, tracks nothing, and stores nothing. It makes no network requests. The bundled privacy manifest declares zero data collection, because there is none. Everything happens on your device, for a moment, and then it does not exist.

## Build

Vigilia uses XcodeGen, so the Xcode project is generated rather than committed. Install it with `brew install xcodegen`, then:

```sh
xcodegen generate
open Vigilia.xcodeproj
```

Requirements: Xcode 26 or newer, iOS 18 or newer. Portrait only, dark only.

## Project layout

| Path | What it is |
|---|---|
| `Vigilia/VigiliaApp.swift` | App entry |
| `Vigilia/Views/RitualView.swift` | The single canvas and the session's state machine |
| `Vigilia/Views/WritingLine.swift` | One styled line of the canvas (the same component for both movements) |
| `Vigilia/Views/AscensionView.swift` | The release animation |
| `Vigilia/ViewModels/RitualModel.swift` | In-memory state, persisted nowhere |
| `Vigilia/Theme/Theme.swift` | Light, colour, typography, and motion |
| `Vigilia/Content/Seeds.swift` | The opening and loving-kindness lines |

## Status

Early scaffold. The full flow runs end to end. Three things are intentionally provisional and still being tuned: the seed phrases, the exact colour and light values, and the technique for the closing animation.
