import SwiftUI

/// A faint, slowly breathing chevron that marks the fixed handle and signals which way to
/// draw it. It only appears once there is something to commit, and it never raises its voice.
///
/// Under Reduce Motion it holds still at a steady, faint glow instead of pulsing.
struct BreathHint: View {
    let systemName: String        // "chevron.compact.down" to seal, "chevron.compact.up" to release
    let visible: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathe = false

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 22, weight: .ultraLight))
            .foregroundStyle(Theme.light.opacity((breathe && !reduceMotion) ? 0.30 : 0.18))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    breathe = true
                }
            }
            // Fade the whole hint in/out as it becomes (ir)relevant. Kept in the layout even
            // when hidden, so nothing jumps when it appears.
            .opacity(visible ? 1 : 0)
            .animation(Motion.fade, value: visible)
            .accessibilityHidden(true)
    }
}
