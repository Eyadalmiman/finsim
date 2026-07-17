import SwiftUI
import SwiftData

struct INTabContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @AppStorage("currentUserEmail") private var currentUserEmail = ""
    @State private var selectedTab = 1

    // Timestamp of the last time accrued income was banked into the stored
    // balance. The live balance is derived from this instead of a background
    // loop, so the rate is exactly incomePerSecond regardless of re-renders.
    @State private var lastCommit = Date()

    // Market risk engine: recent swings (newest first) and the toast on screen.
    @State private var marketEvents: [MarketEvent] = []
    @State private var toastEvent: MarketEvent?

    // Offline earnings paid out on entry, shown as a welcome-back toast.
    @State private var offlinePayout: Double?

    // Rolling net-worth samples (one per second) behind the dashboard chart.
    @State private var netWorthSamples: [Double] = []

    // The simulated coin exchange, opened from Invest or Portfolio.
    @State private var showCryptoMarket = false

    private var user: User? {
        users.current(email: currentUserEmail)
    }

    /// Stored balance plus income earned since the last commit.
    private func liveBalance(_ user: User, at date: Date) -> Double {
        user.investmentBalance + user.incomePerSecond * max(0, date.timeIntervalSince(lastCommit))
    }

    /// Banks accrued income into the stored balance and resets the clock.
    private func commitAccruedIncome() {
        guard let user else { return }
        user.investmentBalance += user.incomePerSecond * max(0, Date().timeIntervalSince(lastCommit))
        lastCommit = Date()
        user.investingLastSeen = Date()
        try? modelContext.save()
    }

    /// Pays out income earned since the last visit, capped so a long absence
    /// doesn't print unlimited money.
    private func payOfflineEarnings() {
        guard let user, let away = user.investingLastSeen else { return }
        let seconds = min(Date().timeIntervalSince(away), User.offlineEarningsCap)
        let earned = user.incomePerSecond * max(0, seconds)
        guard earned >= 0.01 else { return }

        user.investmentBalance += earned
        try? modelContext.save()

        withAnimation(.snappy) { offlinePayout = earned }
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            withAnimation(.easeOut) { offlinePayout = nil }
        }
    }

    private func buy(_ index: Int, quantity: Int) {
        guard let user else { return }
        commitAccruedIncome()      // bank income first so the balance is current
        withAnimation(.snappy) {
            if user.buyInvestment(index, quantity: quantity) {
                try? modelContext.save()
            }
        }
    }

    private func sell(_ index: Int, quantity: Int) {
        guard let user else { return }
        commitAccruedIncome()
        withAnimation(.snappy) {
            if user.sellInvestment(index, quantity: quantity) != nil {
                try? modelContext.save()
            }
        }
    }

    /// Rolls the market every few seconds while the game is open, so prices
    /// keep drifting in the store even before the player owns anything.
    private func runMarketLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 12_000_000_000)
            guard let user else { continue }

            commitAccruedIncome()
            let events = user.rollMarket()
            CryptoSim.shared.tick(for: user)   // coins keep moving too
            try? modelContext.save()
            guard !events.isEmpty else { continue }

            withAnimation(.snappy) {
                marketEvents.insert(contentsOf: events, at: 0)
                marketEvents = Array(marketEvents.prefix(8))
                toastEvent = events.first
            }

            try? await Task.sleep(nanoseconds: 3_500_000_000)
            withAnimation(.easeOut) { toastEvent = nil }
        }
    }

    /// Samples net worth once a second for the dashboard chart.
    private func runNetWorthSampler() async {
        while !Task.isCancelled {
            guard let user else {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                continue
            }
            let sample = liveBalance(user, at: Date()) + user.portfolioValue + user.cryptoValue
            netWorthSamples.append(sample)
            if netWorthSamples.count > 90 {
                netWorthSamples.removeFirst(netWorthSamples.count - 90)
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let live = user.map { liveBalance($0, at: context.date) } ?? 0

            VStack(spacing: 0) {
                Group {
                    if let user {
                        switch selectedTab {
                        case 0:
                            INInvestmentsView(user: user, liveBalance: live, buy: buy, openCrypto: { showCryptoMarket = true })
                        case 2:
                            INAssetsView(user: user, sell: sell, openCrypto: { showCryptoMarket = true })
                        default:
                            INHomeDashboardView(
                                user: user,
                                liveBalance: live,
                                marketEvents: marketEvents,
                                netWorthSamples: netWorthSamples
                            )
                        }
                    } else {
                        Text(tr("No account found.", "لم يتم العثور على حساب."))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Custom Tab Bar
                HStack {
                    INTabItem(icon: "chart.line.uptrend.xyaxis", title: tr("Invest", "استثمر"), isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    INTabItem(icon: "house.fill", title: tr("Home", "الرئيسية"), isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    INTabItem(icon: "briefcase.fill", title: tr("Portfolio", "المحفظة"), isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack {
                    ExperienceExitButton()
                    Spacer()
                    VStack(spacing: 0) {
                        Text(tr("Cash", "النقد"))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        Text(formatMoney(live))
                            .font(.headline)
                            .foregroundColor(.white)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.default, value: formatMoney(live))
                    }
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.finSimGreen)
            }
        }
        .overlay(alignment: .top) {
            // One toast slot: offline payout first, then market swings.
            if let payout = offlinePayout {
                gameToast(
                    icon: "moon.zzz.fill",
                    iconColor: .ctaBlue,
                    title: tr("While you were away", "أثناء غيابك"),
                    detail: "+\(formatMoney(payout))",
                    detailColor: .green
                )
            } else if let event = toastEvent {
                gameToast(
                    icon: event.isGain ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis",
                    iconColor: event.isGain ? .green : .dangerRed,
                    title: event.isGain
                        ? tr("\(event.investmentName) surged!", "ارتفعت \(event.investmentName)!")
                        : tr("\(event.investmentName) dipped!", "انخفضت \(event.investmentName)!"),
                    detail: "\(event.isGain ? "+" : "−")\(formatMoney(abs(event.amount)))  (\(event.percent >= 0 ? "+" : "−")\(Int(abs(event.percent) * 100))%)",
                    detailColor: event.isGain ? .green : .dangerRed
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showCryptoMarket) {
            if let user {
                CryptoMarketView(user: user, bank: commitAccruedIncome)
            }
        }
        .onAppear {
            lastCommit = Date()
            payOfflineEarnings()
            if let user {
                CryptoSim.shared.catchUp(for: user)   // coins moved while away
                try? modelContext.save()
            }
        }
        .onDisappear { commitAccruedIncome() }     // bank income on the way out
        .task { await runMarketLoop() }            // price engine, cancelled on exit
        .task { await runNetWorthSampler() }       // chart data, cancelled on exit
    }

    /// iOS-notification-style toast shared by market swings and offline pay.
    private func gameToast(icon: String, iconColor: Color, title: String, detail: String, detailColor: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(Circle().fill(iconColor))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundColor(detailColor)
                    .monospacedDigit()
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, y: 4)
        .padding(.horizontal, 14)
        .padding(.top, 4)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Tab Item

struct INTabItem: View {
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
            .foregroundColor(isSelected ? .finSimGreen : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}
