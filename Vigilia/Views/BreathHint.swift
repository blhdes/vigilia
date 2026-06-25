import SwiftUI

/// A faint, slowly breathing chevron that signals the seal / release gesture exists, and in
/// which direction. It only appears once there is something to commit, and it never raises
/// its voice: it pulses between barely-there and almost-there, at the tempo of a breath.
///
/// This is the discoverability fix. The gesture used to be invisible; now there is a quiet
/// mark telling you it is here, and which way to draw.
struct BreathHint: View {
    let systemName: String        // "chevron.compact.down" to seal, "chevron.compact.up" to release
    let visible: Bool

    @State private var breathe = false

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 22, weight: .ultraLight))
            // The breathing is a slow opacity pulse on the mark itself.
            .foregroundStyle(Theme.light.opacity(breathe ? 0.30 : 0.12))
            .onAppear {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    breathe = true
                }
            }
            // The gate: fade the whole hint in/out as it becomes (ir)relevant. Kept in the
            // layout even when hidden, so nothing jumps when it appears.
            .opacity(visible ? 1 : 0)
            .animation(Motion.fade, value: visible)
            .accessibilityHidden(true)
    }
}
