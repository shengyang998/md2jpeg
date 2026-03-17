import SwiftUI

struct StatusBanner: View {
    enum Tone: Equatable {
        case info
        case loading
        case warning
        case error

        var defaultSymbol: String? {
            switch self {
            case .info:
                return "info.circle.fill"
            case .loading:
                return nil
            case .warning:
                return "exclamationmark.triangle.fill"
            case .error:
                return "xmark.octagon.fill"
            }
        }

        var accentColor: Color {
            switch self {
            case .info, .loading:
                return .accentColor
            case .warning:
                return .orange
            case .error:
                return .red
            }
        }
    }

    let message: String
    var tone: Tone = .info
    var symbol: String? = nil
    var lineLimit: Int? = nil

    @Environment(\.overlayColors) private var colors

    var body: some View {
        OverlaySurface(
            shapeStyle: .capsule,
            borderColor: tone.accentColor,
            borderOpacity: tone == .info ? 0.12 : 0.35,
            shadowOpacity: 0.08,
            shadowRadius: 16,
            shadowY: 8
        ) {
            HStack(spacing: 8) {
                leadingAccessory

                Text(message)
                    .lineLimit(lineLimit)
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(colors.labelPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
    }

    @ViewBuilder
    private var leadingAccessory: some View {
        if tone == .loading {
            ProgressView()
                .controlSize(.small)
                .tint(colors.labelPrimary)
        } else if let resolvedSymbol = symbol ?? tone.defaultSymbol {
            Image(systemName: resolvedSymbol)
                .foregroundStyle(tone.accentColor)
        }
    }
}
