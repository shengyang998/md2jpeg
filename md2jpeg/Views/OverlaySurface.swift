import SwiftUI

struct OverlaySurface<Content: View>: View {
    enum ShapeStyle {
        case capsule
        case circle
        case roundedCard(cornerRadius: CGFloat = 30)
    }

    let shapeStyle: ShapeStyle
    var borderColor: Color = .white
    var borderOpacity: Double = 0
    var borderLineWidth: CGFloat = 1
    var shadowOpacity: Double = 0
    var shadowRadius: CGFloat = 24
    var shadowY: CGFloat = 18
    var scrimOpacity: Double? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            if let scrimOpacity {
                Rectangle()
                    .fill(Color.black.opacity(scrimOpacity))
                    .ignoresSafeArea()
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
            }

            surfaceBody
        }
    }

    @ViewBuilder
    private var surfaceBody: some View {
        switch shapeStyle {
        case .capsule:
            content()
                .background(.ultraThinMaterial, in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(borderColor.opacity(borderOpacity), lineWidth: borderLineWidth)
                }
                .glassEffect(.regular, in: Capsule())
                .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, y: shadowY)
        case .circle:
            content()
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(borderColor.opacity(borderOpacity), lineWidth: borderLineWidth)
                }
                .glassEffect(.regular, in: Circle())
                .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, y: shadowY)
        case let .roundedCard(cornerRadius):
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            content()
                .background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape
                        .strokeBorder(borderColor.opacity(borderOpacity), lineWidth: borderLineWidth)
                }
                .glassEffect(.regular, in: shape)
                .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, y: shadowY)
        }
    }
}
