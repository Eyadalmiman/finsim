import SwiftUI
import SwiftData

/// Runs the fraud challenges that follow the OTP trap, in order, then lands on
/// the results dashboard. Persists every mistake/pass to SwiftData and keeps
/// the license completion percentage updated as the user advances.
struct BLChallengeSequenceView: View {
    /// Mistakes made on the OTP trap earlier in this run.
    let otpMistakes: Int

    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @AppStorage("currentUserEmail") private var currentUserEmail = ""

    @State private var current: SimulationChallenge = .deliveryScam
    @State private var mistakesThisRun: [SimulationChallenge: Int] = [:]
    @State private var finished = false

    private var user: User? {
        users.current(email: currentUserEmail)
    }

    /// Mistakes for every challenge in this run, OTP included.
    private var allMistakes: [SimulationChallenge: Int] {
        var all = mistakesThisRun
        all[.otpPhishing] = otpMistakes
        return all
    }

    /// Total mistakes made this run, OTP included.
    private var totalMistakes: Int { allMistakes.values.reduce(0, +) }

    var body: some View {
        Group {
            if finished {
                BLResultsView(mistakes: allMistakes)
            } else {
                challengeBody
                    .safeAreaInset(edge: .top, spacing: 0) { header }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .id(current)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var challengeBody: some View {
        switch current {
        case .deliveryScam:
            DeliveryScamView(onMistake: { record(.deliveryScam) },
                             onPassed: { pass(.deliveryScam) })
        case .vishingCall:
            FakeCallView(onMistake: { record(.vishingCall) },
                         onPassed: { pass(.vishingCall) })
        case .socialMediaAd:
            InvestmentAdView(onMistake: { record(.socialMediaAd) },
                             onPassed: { pass(.socialMediaAd) })
        default:
            // The OTP trap runs on the bank dashboard before this flow starts.
            EmptyView()
        }
    }

    /// Slim secure-training banner so the user always knows this is FinSim.
    private var header: some View {
        HStack {
            ExperienceExitButton()
            Spacer()
            VStack(spacing: 1) {
                Text(current.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text(tr("Challenge \(current.rawValue + 1) of \(SimulationChallenge.allCases.count)",
                        "التحدي \(current.rawValue + 1) من \(SimulationChallenge.allCases.count)"))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.75))
            }
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.finSimGreen)
    }

    // MARK: - Progress plumbing

    private func record(_ challenge: SimulationChallenge) {
        mistakesThisRun[challenge, default: 0] += 1
        if let user {
            user.recordChallengeMistake(challenge)
            try? modelContext.save()
        }
    }

    private func pass(_ challenge: SimulationChallenge) {
        if let user {
            user.recordChallengePassed(challenge)

            // Keep the persisted percentage current as the user advances.
            let completed = challenge.rawValue + 1
            user.bankingLicenseProgress = SimulationChallenge.score(completed: completed, totalMistakes: totalMistakes)

            if challenge.next == nil {
                user.bankingLicenseCompleted = user.bankingLicenseProgress >= SimulationChallenge.passThreshold
            }
            try? modelContext.save()
        }

        withAnimation(.easeInOut(duration: 0.35)) {
            if let next = challenge.next {
                current = next
            } else {
                finished = true
            }
        }
    }
}
