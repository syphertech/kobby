import SwiftUI

// Custom Wave Shape
struct WaveShape: Shape {
    // Animatable data to control the phase of the wave
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midHeight = rect.height / 2
        let baseWavelength = rect.width / 10
        let baseAmplitude = rect.height / 4

        // Create a more complex wave path
        path.move(to: CGPoint(x: 0, y: midHeight))
        for x in stride(from: 0, to: rect.width, by: 1) {
            let relativeX = x / baseWavelength
            let y = midHeight +
                (baseAmplitude * sin(relativeX + phase)) + // Base wave
                (baseAmplitude / 2 * sin(2 * relativeX + phase * 1.5)) + // Second harmonic
                (baseAmplitude / 3 * sin(3 * relativeX + phase * 2)) // Third harmonic
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

struct SoundWaveAnimationView: View {
    @State private var phase: CGFloat = 2
    
    var body: some View {
        VStack {
            WaveShape(phase: phase)
                .stroke(Color.indigo, lineWidth: 2)
                .frame(height: 100)
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false)
                    ) {
                        phase = .pi * 5 // Complete one full wave cycle
                    }
                }
        }
        .padding()
    }
}

#Preview {
    SoundWaveAnimationView()
}
