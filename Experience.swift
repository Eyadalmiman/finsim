import SwiftUI

// MARK: - Learning Experience

/// The three self-contained simulations reachable from the Home screen.
/// Each is presented as a full-screen cover so the main tab bar never
/// follows the user into the experience.
enum LearningExperience: String, Identifiable {
    case bankingLicense
    case investment
    case library

    var id: String { rawValue }
}

// MARK: - Exit Experience Environment

/// A closure injected into an experience that dismisses the whole experience
/// and returns the user to the Home screen, no matter how deep they've navigated.
struct ExitExperienceKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var exitExperience: () -> Void {
        get { self[ExitExperienceKey.self] }
        set { self[ExitExperienceKey.self] = newValue }
    }
}

// MARK: - Experience Container

/// Hosts a single experience in its own navigation stack and makes the
/// `exitExperience` action available to every screen inside it.
struct ExperienceContainerView: View {
    let experience: LearningExperience
    let onExit: () -> Void

    var body: some View {
        NavigationStack {
            content
        }
        .environment(\.exitExperience, onExit)
    }

    @ViewBuilder
    private var content: some View {
        switch experience {
        case .bankingLicense:
            BLAboutView()
        case .investment:
            INAboutView()
        case .library:
            LIBAboutView()
        }
    }
}

// MARK: - Exit Button

/// A circular translucent button that exits the current experience.
struct ExperienceExitButton: View {
    @Environment(\.exitExperience) private var exitExperience

    var icon: String = "xmark"

    var body: some View {
        Button(action: exitExperience) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.white.opacity(0.18)))
        }
        .accessibilityLabel("Exit experience")
    }
}
