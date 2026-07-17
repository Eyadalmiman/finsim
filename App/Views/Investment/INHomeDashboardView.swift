import SwiftUI

struct INHomeDashboardView: View {
    let user: User
    let liveBalance: Double
    var marketEvents: [MarketEvent] = []
    var netWorthSamples: [Double] = []

    private var netWorth: Double { liveBalance + user.portfolioValue + user.cryptoValue }

    var body: some View {
        VStack(spacing: 0) {
            // Net worth hero
            VStack(alignment: .leading, spacing: 6) {
                Text(tr("Net Worth", "صافي الثروة"))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                Text(formatMoney(netWorth))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.default, value: formatMoney(netWorth))

                HStack(spacing: 14) {
                    HStack(spacing: 5) {
                        Image(systemName: "banknote")
                        Text(formatMoney(liveBalance))
                            .monospacedDigit()
                    }
                    HStack(spacing: 5) {
                        Image(systemName: "briefcase.fill")
                        Text(formatMoney(user.portfolioValue))
                            .monospacedDigit()
                    }
                    if user.cryptoValue > 0 {
                        HStack(spacing: 5) {
                            Image(systemName: "bitcoinsign.circle")
                            Text(formatMoney(user.cryptoValue))
                                .monospacedDigit()
                        }
                    }
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up.right")
                        Text("\(formatMoney(user.incomePerSecond))/s")
                            .monospacedDigit()
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.9))

                if netWorthSamples.count >= 2 {
                    SparklineView(samples: netWorthSamples)
                        .frame(height: 44)
                        .padding(.top, 6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.finSimGreen)

            ScrollView {
                // Goals — small wins that teach the habits
                goalsCard
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                // Income breakdown
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(tr("Income", "الدخل"))
                            .font(.title3.weight(.bold))
                        Spacer()
                        Text("\(formatMoney(user.incomePerSecond))/s")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.green)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    Divider()

                    if user.ownsAnyInvestment {
                        ForEach(Investment.catalog) { inv in
                            let count = user.investmentCount(inv.id)
                            if count > 0 {
                                HStack {
                                    Image(systemName: inv.icon)
                                        .foregroundColor(.finSimGreen)
                                        .frame(width: 40)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(inv.name)
                                            .font(.body)
                                        Text("×\(count)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("+\(formatMoney(Double(count) * inv.incomePerUnit))/s")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)

                                Divider()
                            }
                        }
                    } else {
                        Text(tr("You don't own any investments yet.\nHead to the Invest tab to buy your first one.", "لا تملك أي استثمارات بعد.\nتوجه إلى تبويب استثمر لشراء أول استثمار لك."))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(24)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                )
                .padding(16)

                // Market news — recent surges and dips on owned assets
                if !marketEvents.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text(tr("Market News", "أخبار السوق"))
                                .font(.title3.weight(.bold))
                            Spacer()
                            Image(systemName: "waveform.path.ecg")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        Divider()

                        ForEach(marketEvents) { event in
                            HStack {
                                Image(systemName: event.investmentIcon)
                                    .foregroundColor(event.isGain ? .green : .dangerRed)
                                    .frame(width: 40)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.isGain
                                         ? tr("\(event.investmentName) surged", "ارتفعت \(event.investmentName)")
                                         : tr("\(event.investmentName) dipped", "انخفضت \(event.investmentName)"))
                                        .font(.body)
                                    Text(event.date.formatted(date: .omitted, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text("\(event.isGain ? "+" : "−")\(formatMoney(abs(event.amount)))")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(event.isGain ? .green : .dangerRed)
                                    .monospacedDigit()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)

                            Divider()
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Goals

    private struct Goal: Identifiable {
        let id: Int
        let title: String
        let done: Bool
    }

    private var goals: [Goal] {
        // Crypto counts as one asset type toward diversification.
        let ownedTypes = Investment.catalog.filter { user.investmentCount($0.id) > 0 }.count
            + (user.ownsAnyCrypto ? 1 : 0)
        return [
            Goal(id: 0,
                 title: tr("Buy your first investment", "اشترِ أول استثمار لك"),
                 done: user.ownsAnyInvestment),
            Goal(id: 1,
                 title: tr("Reach $100/s of income", "اوصل إلى دخل 100$/ث"),
                 done: user.incomePerSecond >= 100),
            Goal(id: 2,
                 title: tr("Diversify: own 4 asset types", "نوّع: امتلك 4 أنواع أصول"),
                 done: ownedTypes >= 4),
            Goal(id: 3,
                 title: tr("Reach $1M net worth", "اوصل إلى صافي ثروة مليون دولار"),
                 done: netWorth >= 1_000_000),
            Goal(id: 4,
                 title: tr("Reach $100M net worth", "اوصل إلى صافي ثروة 100 مليون دولار"),
                 done: netWorth >= 100_000_000)
        ]
    }

    private var goalsCard: some View {
        let items = goals
        let doneCount = items.filter(\.done).count

        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(tr("Goals", "الأهداف"))
                    .font(.title3.weight(.bold))
                Spacer()
                Text("\(doneCount)/\(items.count)")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.finSimGreen)
                    .monospacedDigit()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()

            ForEach(items) { goal in
                HStack(spacing: 12) {
                    Image(systemName: goal.done ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(goal.done ? .green : .secondary.opacity(0.5))
                    Text(goal.title)
                        .font(.subheadline)
                        .foregroundColor(goal.done ? .secondary : .primary)
                        .strikethrough(goal.done, color: .secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .padding(.bottom, 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
    }
}

// MARK: - Sparkline

/// Lightweight net-worth line chart drawn with Canvas (no dependencies).
struct SparklineView: View {
    let samples: [Double]

    var body: some View {
        Canvas { context, size in
            guard samples.count >= 2,
                  let minValue = samples.min(),
                  let maxValue = samples.max() else { return }

            let span = max(maxValue - minValue, max(abs(maxValue) * 0.001, 0.01))
            let stepX = size.width / CGFloat(samples.count - 1)

            func point(_ index: Int) -> CGPoint {
                CGPoint(
                    x: CGFloat(index) * stepX,
                    // 10% vertical padding so the line never kisses the edges.
                    y: size.height * (0.9 - 0.8 * CGFloat((samples[index] - minValue) / span))
                )
            }

            var line = Path()
            line.move(to: point(0))
            for index in 1..<samples.count {
                line.addLine(to: point(index))
            }

            // Soft fill under the line, then the line itself.
            var fill = line
            fill.addLine(to: CGPoint(x: size.width, y: size.height))
            fill.addLine(to: CGPoint(x: 0, y: size.height))
            fill.closeSubpath()

            context.fill(fill, with: .linearGradient(
                Gradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.02)]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            ))
            context.stroke(line, with: .color(Color.white.opacity(0.9)), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}
