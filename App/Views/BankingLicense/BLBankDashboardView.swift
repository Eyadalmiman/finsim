import SwiftUI
import SwiftData

struct BLBankDashboardView: View {
    @Environment(\.exitExperience) private var exitExperience
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @AppStorage("currentUserEmail") private var currentUserEmail = ""

    @State private var selectedBankTab = 0
    @State private var showFeatureAlert = false
    @State private var showTransfer = false

    // OTP phishing trap life cycle
    @State private var showPhishingTrap = false
    @State private var trapTriggeredThisVisit = false
    @State private var mistakesThisRun = 0
    @State private var showChallenges = false

    private var user: User? {
        users.current(email: currentUserEmail)
    }

    var body: some View {
        ZStack {
            dashboard

            if showPhishingTrap {
                BLPhishingAlertView(
                    onMistake: recordMistake,
                    onPassed: completeChallenge
                )
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .task {
            // Spring the trap 2 seconds after entering the dashboard.
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            triggerTrap()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showTransfer) {
            BLTransferView()
        }
        .navigationDestination(isPresented: $showChallenges) {
            BLChallengeSequenceView(otpMistakes: mistakesThisRun)
        }
        .alert(tr("Check Back Later!", "عد لاحقاً!"), isPresented: $showFeatureAlert) {
            Button(tr("Okay!", "حسناً!"), role: .cancel) { }
        } message: {
            Text(tr("This Feature isn't ready yet, please come back later.", "هذه الميزة ليست جاهزة بعد، يرجى العودة لاحقاً."))
        }
    }

    // MARK: - Phishing trap plumbing

    private func triggerTrap() {
        guard !trapTriggeredThisVisit else { return }
        trapTriggeredThisVisit = true
        mistakesThisRun = 0
        withAnimation(.easeInOut(duration: 0.3)) {
            showPhishingTrap = true
        }
    }

    /// Persist every time the user falls for the trap.
    private func recordMistake() {
        mistakesThisRun += 1
        if let user {
            user.phishingMistakeCount += 1
            try? modelContext.save()
        }
    }

    /// The user made the safe choice: persist the outcome and hand off to the
    /// remaining challenges. The final score is computed at the end of the flow.
    private func completeChallenge() {
        if let user {
            user.phishingPassed = true
            // Partial credit so the Account page reflects progress mid-flow.
            user.bankingLicenseProgress = SimulationChallenge.score(completed: 1, totalMistakes: mistakesThisRun)
            try? modelContext.save()
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            showPhishingTrap = false
        }
        showChallenges = true
    }

    private var dashboard: some View {
        VStack(spacing: 0) {
            // Purple gradient header
            VStack(spacing: 12) {
                HStack {
                    // Profile
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white.opacity(0.7))

                    Text(tr("Hi, Eyad Almiman", "مرحباً، إياد الميمان"))
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: exitExperience) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .accessibilityLabel("Exit experience")
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Credit Card
                BankCreditCardView()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
            .background(
                LinearGradient(
                    colors: [Color.bankPurple, Color.bankBlue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Action Grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    BankActionTile(icon: "creditcard", title: tr("Account and Card", "الحساب والبطاقة"), color: .blue) {
                        showFeatureAlert = true
                    }
                    BankActionTile(icon: "arrow.left.arrow.right", title: tr("Transfer", "تحويل"), color: .purple) {
                        // Interacting with Transfer springs the trap early.
                        if trapTriggeredThisVisit {
                            showTransfer = true
                        } else {
                            triggerTrap()
                        }
                    }
                    BankActionTile(icon: "banknote", title: tr("Withdraw", "سحب"), color: .indigo) {
                        showFeatureAlert = true
                    }
                    BankActionTile(icon: "iphone", title: tr("Mobile prepaid", "شحن الجوال"), color: .green) {
                        showFeatureAlert = true
                    }
                    BankActionTile(icon: "doc.text", title: tr("Pay the bill", "دفع الفواتير"), color: .blue) {
                        showFeatureAlert = true
                    }
                    BankActionTile(icon: "piggybank", title: tr("Save online", "ادخار إلكتروني"), color: .teal) {
                        showFeatureAlert = true
                    }
                    BankActionTile(icon: "creditcard.fill", title: tr("Credit card", "بطاقة ائتمانية"), color: .orange) {
                        showFeatureAlert = true
                    }
                    BankActionTile(icon: "list.clipboard", title: tr("Transaction report", "تقرير العمليات"), color: .blue) {
                        showFeatureAlert = true
                    }
                    BankActionTile(icon: "person.2", title: tr("Beneficiary", "المستفيدون"), color: .red) {
                        showFeatureAlert = true
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))

            // Bank Tab Bar
            HStack {
                BankTabItem(icon: "house.fill", title: tr("Home", "الرئيسية"), isSelected: selectedBankTab == 0) {
                    selectedBankTab = 0
                }
                BankTabItem(icon: "envelope.fill", title: tr("Mail", "البريد"), isSelected: selectedBankTab == 1) {
                    selectedBankTab = 1
                    showFeatureAlert = true
                }
                BankTabItem(icon: "gearshape.fill", title: tr("Settings", "الإعدادات"), isSelected: selectedBankTab == 2) {
                    selectedBankTab = 2
                    showFeatureAlert = true
                }
                BankTabItem(icon: "person.circle.fill", title: tr("Account", "الحساب"), isSelected: selectedBankTab == 3) {
                    selectedBankTab = 3
                    showFeatureAlert = true
                }
                BankTabItem(icon: "magnifyingglass", title: tr("Search", "بحث"), isSelected: selectedBankTab == 4) {
                    selectedBankTab = 4
                    showFeatureAlert = true
                }
            }
            .padding(.vertical, 8)
            .liquidGlass(cornerRadius: 0, interactive: false)
        }
    }
}

// MARK: - Credit Card View

struct BankCreditCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Eyad Almiman")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)

            Text("Amazon Platinium")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            HStack(spacing: 8) {
                Text("4756")
                    .foregroundColor(.white)
                Text("\u{2022}\u{2022}\u{2022}\u{2022}")
                    .foregroundColor(.white)
                Text("\u{2022}\u{2022}\u{2022}\u{2022}")
                    .foregroundColor(.white)
                Text("9018")
                    .foregroundColor(.white)
            }
            .font(.body.monospaced())

            HStack {
                Text("24,345.92 SAR")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                Spacer()
                Text("VISA")
                    .font(.title2.weight(.bold).italic())
                    .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.20, green: 0.25, blue: 0.65),
                                Color(red: 0.35, green: 0.25, blue: 0.70),
                                Color(red: 0.20, green: 0.30, blue: 0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Red stripe at bottom
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.red.opacity(0.6))
                        .frame(height: 8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        )
    }
}

// MARK: - Action Tile

struct BankActionTile: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.12))
                    )

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
            )
        }
        .buttonStyle(PressableCardStyle())
    }
}

// MARK: - Bank Tab Item

struct BankTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .bankPurple : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}
