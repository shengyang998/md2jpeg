import SwiftUI

struct ExportProgressOverlay: View {
    let progress: Double
    @Environment(\.overlayColors) private var colors

    var body: some View {
        BlockingStatusOverlay {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.18))
                    .frame(width: 220, height: 220)
                    .blur(radius: 40)
                    .offset(x: -70, y: -70)

                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .blur(radius: 50)
                    .offset(x: 90, y: 90)

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 120, height: 120)

                        Circle()
                            .stroke(colors.labelPrimary.opacity(0.12), lineWidth: 8)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        Color.white.opacity(0.95),
                                        Color.accentColor,
                                        Color.white.opacity(0.8)
                                    ],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: Color.accentColor.opacity(0.28), radius: 10)
                            .animation(.easeInOut(duration: 0.3), value: progress)

                        VStack(spacing: 4) {
                            Text("\(Int(progress * 100))%")
                                .font(.title2.weight(.semibold).monospacedDigit())
                                .foregroundStyle(colors.labelPrimary)

                            Text("complete")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(colors.labelSecondary)
                        }
                    }

                    VStack(spacing: 8) {
                        Text("Exporting")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(colors.labelPrimary)

                        Text("Preparing your image...")
                            .font(.footnote)
                            .foregroundStyle(colors.labelSecondary)
                    }

                    Text("Please keep this view open until the export finishes.")
                        .font(.caption)
                        .foregroundStyle(colors.labelSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}
