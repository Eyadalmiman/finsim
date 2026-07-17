import SwiftUI

// MARK: - App Color Palette

extension Color {
    // FinSim Wrapper - Deep Green
    static let finSimGreen = Color(red: 0.0, green: 0.32, blue: 0.11)
    static let finSimDarkGreen = Color(red: 0.0, green: 0.24, blue: 0.08)
    static let finSimLightGreen = Color(red: 0.0, green: 0.40, blue: 0.16)

    // Banking Simulation - Purple/Blue
    static let bankPurple = Color(red: 0.33, green: 0.17, blue: 0.60)
    static let bankBlue = Color(red: 0.26, green: 0.35, blue: 0.80)
    static let bankLightPurple = Color(red: 0.50, green: 0.30, blue: 0.82)
    static let bankAccent = Color(red: 0.40, green: 0.25, blue: 0.90)

    // Disclaimer / Warning
    static let disclaimerRed = Color(red: 0.42, green: 0.10, blue: 0.05)

    // CTA Blue
    static let ctaBlue = Color(red: 0.12, green: 0.46, blue: 0.96)

    // Danger
    static let dangerRed = Color(red: 0.92, green: 0.15, blue: 0.22)
}

// MARK: - Glassmorphic Card Modifier

struct GlassmorphicCard: ViewModifier {
    var cornerRadius: CGFloat = 16
    var fillOpacity: Double = 0.12

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(fillOpacity))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
    }
}

// MARK: - Green Section Card Modifier

struct GreenSectionCard: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.finSimGreen)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
    }
}

// MARK: - View Extensions

extension View {
    func glassmorphic(cornerRadius: CGFloat = 16, opacity: Double = 0.12) -> some View {
        modifier(GlassmorphicCard(cornerRadius: cornerRadius, fillOpacity: opacity))
    }

    func greenSection(cornerRadius: CGFloat = 16) -> some View {
        modifier(GreenSectionCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.ctaBlue)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Danger Button Style

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.dangerRed)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Pressable Card Style

/// Press feedback for card-like tappable surfaces: a subtle scale with a
/// spring, per HIG (feedback within ~100ms, no layout shift).
struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(duration: 0.25), value: configuration.isPressed)
    }
}

// MARK: - Liquid Glass Button Style

struct LiquidGlassButtonStyle: ButtonStyle {
    var tint: Color = .accentColor
    var isProminent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .glassEffect(
                isProminent ? .regular.tint(tint).interactive() : .regular.tint(tint.opacity(0.55)).interactive(),
                in: RoundedRectangle(cornerRadius: 25, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Liquid Glass View Modifier

extension View {
    /// Wraps any tappable content (buttons, NavigationLinks, Menu labels) in an
    /// iOS 26 Liquid Glass background, optionally tinted to preserve brand color.
    @ViewBuilder
    func liquidGlass(cornerRadius: CGFloat = 16, tint: Color? = nil, interactive: Bool = true) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        switch (tint, interactive) {
        case let (.some(tint), true):
            self.glassEffect(.regular.tint(tint).interactive(), in: shape)
        case let (.some(tint), false):
            self.glassEffect(.regular.tint(tint), in: shape)
        case (.none, true):
            self.glassEffect(.regular.interactive(), in: shape)
        case (.none, false):
            self.glassEffect(.regular, in: shape)
        }
    }
}

// MARK: - Social Sign-In Button Style

struct SocialButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Disclaimer Banner

struct DisclaimerBanner: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.disclaimerRed)
            )
    }
}

// MARK: - Green Pattern Background

struct GreenPatternBackground: View {
    var body: some View {
        ZStack {
            Color.finSimGreen
                .ignoresSafeArea()

            GeometryReader { geo in
                Canvas { context, size in
                    let spacingX: CGFloat = 55
                    let spacingY: CGFloat = 50
                    let arrowW: CGFloat = 22
                    let arrowH: CGFloat = 18

                    for row in stride(from: -spacingY, through: size.height + spacingY, by: spacingY) {
                        let rowIndex = Int(round(row / spacingY))
                        let xOffset: CGFloat = (rowIndex % 2 == 0) ? 0 : spacingX / 2

                        for col in stride(from: -spacingX, through: size.width + spacingX, by: spacingX) {
                            let cx = col + xOffset
                            let cy = row

                            var path = Path()
                            path.move(to: CGPoint(x: cx, y: cy - arrowH / 2))
                            path.addLine(to: CGPoint(x: cx + arrowW / 2, y: cy))
                            path.addLine(to: CGPoint(x: cx + arrowW / 4, y: cy))
                            path.addLine(to: CGPoint(x: cx + arrowW / 4, y: cy + arrowH / 2))
                            path.addLine(to: CGPoint(x: cx - arrowW / 4, y: cy + arrowH / 2))
                            path.addLine(to: CGPoint(x: cx - arrowW / 4, y: cy))
                            path.addLine(to: CGPoint(x: cx - arrowW / 2, y: cy))
                            path.closeSubpath()

                            context.fill(path, with: .color(Color.white.opacity(0.035)))
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Glassmorphic Text Field

struct GlassmorphicTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.20), lineWidth: 1)
        )
        .foregroundColor(.white)
        .tint(.white)
    }
}

// MARK: - Section Header (for Settings / Account)

struct SectionHeader: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)
        }
    }
}

// MARK: - Page Header Banner

struct PageHeaderBanner: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.white.opacity(0.15)))

            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.finSimLightGreen, .finSimGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

// MARK: - Settings Row Icon

/// Small tinted icon square used at the leading edge of settings rows,
/// matching the iOS Settings idiom for scanability.
struct SettingsRowIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.footnote.weight(.semibold))
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.white.opacity(0.16))
            )
    }
}
