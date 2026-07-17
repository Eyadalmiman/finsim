import Foundation
import SwiftData
import CryptoKit

@Model
final class User {
    var name: String
    var email: String
    var dateOfBirth: Date
    var idNumber: String
    var isVerified: Bool
    var passwordHash: String = ""

    // Simulation Progress
    var bankingLicenseProgress: Double
    var bankingLicenseCompleted: Bool
    var investmentBalance: Double
    var investmentIncomePerSecond: Double
    /// How many of each investment (by catalog index) the player owns.
    var investmentCounts: [Int] = []
    /// Live market price multiplier per asset (1.0 = fair price).
    var assetPriceMultipliers: [Double] = []
    /// Total money actually paid for the units currently held, per asset.
    /// Value − basis = unrealized profit/loss.
    var assetCostBasis: [Double] = []
    /// When the investment game last banked income — used to pay out
    /// (capped) offline earnings on the next visit.
    var investingLastSeen: Date?

    // Crypto market: fractional units held, dollars paid, and the live
    // simulated price per coin (by CryptoCoin catalog index).
    var cryptoUnits: [Double] = []
    var cryptoCostBasis: [Double] = []
    var cryptoPrices: [Double] = []
    /// Last time the crypto simulation advanced (drives catch-up ticks).
    var cryptoLastTick: Date?

    // Banking License training record (persisted so the app remembers how
    // the user handled each challenge across all runs).
    /// Times the user fell for the OTP phishing trap across all runs.
    var phishingMistakeCount: Int = 0
    /// Whether the user has ever resolved the phishing challenge correctly.
    var phishingPassed: Bool = false
    var deliveryMistakeCount: Int = 0
    var deliveryPassed: Bool = false
    var vishingMistakeCount: Int = 0
    var vishingPassed: Bool = false
    var adMistakeCount: Int = 0
    var adPassed: Bool = false

    // Library reading record: stable subject IDs the user has read to the end.
    var readSubjectIDs: [String] = []

    /// Marks a library subject as fully read (idempotent).
    func markSubjectRead(_ id: String) {
        guard !readSubjectIDs.contains(id) else { return }
        readSubjectIDs.append(id)
    }

    /// True once every subject in the library has been read to the end.
    var hasReadEntireLibrary: Bool {
        let read = Set(readSubjectIDs)
        return Library.allSubjectIDs.allSatisfy { read.contains($0) }
    }

    /// Wipes every bit of learning/game progress while keeping the account —
    /// the demo switch: one tap returns the app to a fresh-player state.
    func resetProgress() {
        bankingLicenseProgress = 0
        bankingLicenseCompleted = false
        phishingMistakeCount = 0
        phishingPassed = false
        deliveryMistakeCount = 0
        deliveryPassed = false
        vishingMistakeCount = 0
        vishingPassed = false
        adMistakeCount = 0
        adPassed = false
        readSubjectIDs = []
        investmentBalance = 99_999.99
        investmentIncomePerSecond = 0
        investmentCounts = []
        assetPriceMultipliers = []
        assetCostBasis = []
        investingLastSeen = nil
        cryptoUnits = []
        cryptoCostBasis = []
        cryptoPrices = []
        cryptoLastTick = nil
    }

    /// Records a mistake on the given challenge.
    func recordChallengeMistake(_ challenge: SimulationChallenge) {
        switch challenge {
        case .otpPhishing:   phishingMistakeCount += 1
        case .deliveryScam:  deliveryMistakeCount += 1
        case .vishingCall:   vishingMistakeCount += 1
        case .socialMediaAd: adMistakeCount += 1
        }
    }

    /// Marks the given challenge as passed at least once.
    func recordChallengePassed(_ challenge: SimulationChallenge) {
        switch challenge {
        case .otpPhishing:   phishingPassed = true
        case .deliveryScam:  deliveryPassed = true
        case .vishingCall:   vishingPassed = true
        case .socialMediaAd: adPassed = true
        }
    }

    init(
        name: String,
        email: String,
        password: String,
        dateOfBirth: Date,
        idNumber: String
    ) {
        self.name = name
        self.email = email
        self.dateOfBirth = dateOfBirth
        self.idNumber = idNumber
        self.isVerified = true
        self.passwordHash = User.hash(password)
        self.bankingLicenseProgress = 0.0
        self.bankingLicenseCompleted = false
        self.investmentBalance = 99_999.99
        self.investmentIncomePerSecond = 0.0
    }

    static func hash(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    func matches(password: String) -> Bool {
        passwordHash == User.hash(password)
    }

    var maskedID: String {
        guard idNumber.count > 4 else { return idNumber }
        let prefix = String(idNumber.prefix(3))
        let suffix = String(idNumber.suffix(2))
        let stars = String(repeating: "*", count: max(0, idNumber.count - 5))
        return "\(prefix)\(stars)\(suffix)"
    }

    // DateFormatter is expensive to create, so it is built once, not per render.
    private static let dobFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    var formattedDOB: String {
        User.dobFormatter.string(from: dateOfBirth)
    }

    var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }
}

// MARK: - Current-User Lookup

extension Array where Element == User {
    /// The account matching the signed-in email, falling back to the first
    /// stored account. The one implementation behind every screen's
    /// current-user resolution.
    func current(email: String) -> User? {
        first(where: { $0.email.lowercased() == email.lowercased() }) ?? first
    }
}

// MARK: - Social Sign-In

/// A third-party sign-in provider. In this local-only simulator each provider
/// maps to a persisted on-device account (no backend / CloudKit involved).
enum SocialProvider {
    case apple
    case google

    var email: String {
        switch self {
        case .apple: return "apple.user@finsim.local"
        case .google: return "google.user@finsim.local"
        }
    }

    var displayName: String {
        switch self {
        case .apple: return "Apple User"
        case .google: return "Google User"
        }
    }
}

extension User {
    /// Restores the local account for the given provider, creating one on first
    /// use. Returns the account so the caller can mark it as the current user.
    @MainActor
    static func signIn(with provider: SocialProvider, existing: [User], context: ModelContext) -> User {
        if let account = existing.first(where: { $0.email.lowercased() == provider.email }) {
            return account
        }
        let account = User(
            name: provider.displayName,
            email: provider.email,
            password: UUID().uuidString,
            dateOfBirth: Date(),
            idNumber: "1150000089"
        )
        context.insert(account)
        return account
    }
}
