import SwiftUI
import SwiftData

// MARK: - Crypto Market

/// The simulated coin exchange: live prices for real coins, charts, and
/// dollar-amount buying and selling. The simulation ticks while the screen
/// is open; the engine itself rate-limits so nothing double-advances it.
struct CryptoMarketView: View {
    let user: User
    /// Banks idle income so the cash shown/spent is current.
    var bank: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedCoin: CryptoCoin?
    /// Bumped every tick so the charts (engine memory) re-render.
    @State private var beat = 0

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 12) {
                    Text(tr("Prices are simulated but behave like the real market — trends, crashes, and all. Coins pay no income; the only profit is selling higher than you bought. Sales pay a 0.5% trading fee.",
                            "الأسعار محاكاة لكنها تتصرف مثل السوق الحقيقي — اتجاهات وانهيارات وكل شيء. العملات لا تدفع دخلاً؛ الربح الوحيد هو البيع بأعلى من سعر الشراء. على كل بيع رسوم تداول 0.5٪."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(CryptoCoin.catalog) { coin in
                        coinRow(coin)
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
        }
        .task {
            CryptoSim.shared.catchUp(for: user)
            try? modelContext.save()
            beat += 1
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                CryptoSim.shared.tick(for: user)
                try? modelContext.save()
                beat += 1
            }
        }
        .sheet(item: $selectedCoin) { coin in
            CoinDetailView(coin: coin, user: user, bank: bank, beat: $beat)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.15)))
            }
            .accessibilityLabel("Close")

            Spacer()

            VStack(spacing: 1) {
                Text(tr("Crypto Market", "سوق العملات الرقمية"))
                    .font(.headline)
                    .foregroundColor(.white)
                Text(tr("Cash \(formatMoney(user.investmentBalance))  •  Holdings \(formatMoney(user.cryptoValue))",
                        "النقد \(formatMoney(user.investmentBalance))  •  الحيازات \(formatMoney(user.cryptoValue))"))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .monospacedDigit()
            }

            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.finSimGreen)
    }

    private func coinRow(_ coin: CryptoCoin) -> some View {
        let price = user.cryptoPrice(of: coin.id)
        let change = CryptoSim.shared.windowChange(of: coin.id)
        let held = user.cryptoUnits(of: coin.id)

        return Button {
            selectedCoin = coin
        } label: {
            HStack(spacing: 12) {
                coinBadge(coin)

                VStack(alignment: .leading, spacing: 2) {
                    Text(coin.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    HStack(spacing: 5) {
                        Text(coin.ticker)
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.secondary)
                        if held > 0 {
                            Text(tr("Owned", "تملكها"))
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.finSimGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(Color.finSimGreen.opacity(0.12)))
                        }
                    }
                }

                Spacer()

                CoinChartView(samples: chartSamples(coin), color: change >= 0 ? .green : .dangerRed, filled: false)
                    .frame(width: 64, height: 26)
                    .id(beat)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatCoinPrice(price))
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                    changeChip(change)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
            )
        }
        .buttonStyle(PressableCardStyle())
    }

    private func chartSamples(_ coin: CryptoCoin) -> [Double] {
        guard coin.id < CryptoSim.shared.histories.count else { return [] }
        return Array(CryptoSim.shared.histories[coin.id].suffix(60))
    }
}

// MARK: - Shared pieces

func coinBadge(_ coin: CryptoCoin, size: CGFloat = 40) -> some View {
    Text(coin.ticker)
        .font(.system(size: size * 0.28, weight: .heavy))
        .foregroundColor(.white)
        .frame(width: size, height: size)
        .background(Circle().fill(coin.color.gradient))
}

@ViewBuilder
func changeChip(_ change: Double) -> some View {
    HStack(spacing: 2) {
        Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
        Text("\(change >= 0 ? "+" : "−")\(String(format: "%.1f", abs(change) * 100))%")
            .monospacedDigit()
    }
    .font(.caption2.weight(.bold))
    .foregroundColor(change >= 0 ? .green : .dangerRed)
}

// MARK: - Coin Detail

struct CoinDetailView: View {
    let coin: CryptoCoin
    let user: User
    var bank: () -> Void = {}
    @Binding var beat: Int

    @Environment(\.modelContext) private var modelContext

    private var price: Double { user.cryptoPrice(of: coin.id) }
    private var held: Double { user.cryptoUnits(of: coin.id) }
    private var change: Double { CryptoSim.shared.windowChange(of: coin.id) }

    private var samples: [Double] {
        guard coin.id < CryptoSim.shared.histories.count else { return [] }
        return Array(CryptoSim.shared.histories[coin.id].suffix(120))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Price header
                VStack(spacing: 6) {
                    coinBadge(coin, size: 52)
                    Text(coin.name)
                        .font(.title3.weight(.bold))
                    Text(formatCoinPrice(price))
                        .font(.system(size: 34, weight: .bold))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.default, value: formatCoinPrice(price))
                    changeChip(change)
                }
                .padding(.top, 18)

                // Chart
                CoinChartView(samples: samples, color: change >= 0 ? .green : .dangerRed, filled: true)
                    .frame(height: 170)
                    .id(beat)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                    )

                // Holdings
                if held > 0 {
                    let value = user.cryptoValue(of: coin.id)
                    let profit = user.cryptoProfit(of: coin.id)
                    let basis = user.cryptoCostBasis(of: coin.id)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tr("You own", "تملك"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(formatCoinUnits(held)) \(coin.ticker)")
                                .font(.subheadline.weight(.bold))
                                .monospacedDigit()
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatMoney(value))
                                .font(.subheadline.weight(.bold))
                                .monospacedDigit()
                            HStack(spacing: 2) {
                                Image(systemName: profit >= 0 ? "arrow.up.right" : "arrow.down.right")
                                Text("\(profit >= 0 ? "+" : "−")\(formatMoney(abs(profit))) (\(basis > 0 ? Int(abs(profit) / basis * 100) : 0)%)")
                                    .monospacedDigit()
                            }
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(profit >= 0 ? .green : .dangerRed)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                    )
                }

                // Buy
                VStack(alignment: .leading, spacing: 10) {
                    Text(tr("Buy", "شراء"))
                        .font(.headline)
                    HStack(spacing: 8) {
                        buyChip(100)
                        buyChip(1_000)
                        buyChip(10_000)
                        maxBuyChip
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                )

                // Sell
                if held > 0 {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(tr("Sell", "بيع"))
                            .font(.headline)
                        HStack(spacing: 8) {
                            sellChip(fraction: 0.25, label: "25%")
                            sellChip(fraction: 0.5, label: "50%")
                            sellChip(fraction: 1, label: tr("All", "الكل"))
                        }
                        Text(tr("Selling everything pays about \(formatMoney(held * price * User.cryptoFeeKeep)) after the 0.5% fee.",
                                "بيع الكل يدفع نحو \(formatMoney(held * price * User.cryptoFeeKeep)) بعد رسوم 0.5٪."))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                    )
                }

                Text(tr("Cash: \(formatMoney(user.investmentBalance))", "النقد: \(formatMoney(user.investmentBalance))"))
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func buyChip(_ dollars: Double) -> some View {
        let affordable = user.investmentBalance >= dollars
        return Button {
            bank()
            withAnimation(.snappy) {
                if user.buyCrypto(coin.id, dollars: dollars) {
                    try? modelContext.save()
                    beat += 1
                }
            }
        } label: {
            Text(formatMoney(dollars))
                .font(.footnote.weight(.bold))
                .foregroundColor(.white)
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Capsule().fill(affordable ? Color.ctaBlue : Color.gray.opacity(0.45)))
        }
        .buttonStyle(PressableCardStyle())
        .disabled(!affordable)
    }

    private var maxBuyChip: some View {
        Button {
            bank()
            withAnimation(.snappy) {
                if user.buyCrypto(coin.id, dollars: user.investmentBalance) {
                    try? modelContext.save()
                    beat += 1
                }
            }
        } label: {
            Text("MAX")
                .font(.footnote.weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Capsule().fill(user.investmentBalance > 0 ? Color.finSimGreen : Color.gray.opacity(0.45)))
        }
        .buttonStyle(PressableCardStyle())
        .disabled(user.investmentBalance <= 0)
    }

    private func sellChip(fraction: Double, label: String) -> some View {
        Button {
            withAnimation(.snappy) {
                if user.sellCrypto(coin.id, quantity: held * fraction) != nil {
                    try? modelContext.save()
                    beat += 1
                }
            }
        } label: {
            Text(label)
                .font(.footnote.weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.dangerRed.opacity(0.9)))
        }
        .buttonStyle(PressableCardStyle())
    }
}

// MARK: - Coin Chart

/// Line chart for coin history, tinted by trend direction.
struct CoinChartView: View {
    let samples: [Double]
    let color: Color
    var filled: Bool = true

    var body: some View {
        Canvas { context, size in
            guard samples.count >= 2,
                  let minValue = samples.min(),
                  let maxValue = samples.max() else { return }

            let span = max(maxValue - minValue, max(abs(maxValue) * 0.001, 1e-9))
            let stepX = size.width / CGFloat(samples.count - 1)

            func point(_ index: Int) -> CGPoint {
                CGPoint(
                    x: CGFloat(index) * stepX,
                    y: size.height * (0.94 - 0.88 * CGFloat((samples[index] - minValue) / span))
                )
            }

            var line = Path()
            line.move(to: point(0))
            for index in 1..<samples.count {
                line.addLine(to: point(index))
            }

            if filled {
                var fill = line
                fill.addLine(to: CGPoint(x: size.width, y: size.height))
                fill.addLine(to: CGPoint(x: 0, y: size.height))
                fill.closeSubpath()
                context.fill(fill, with: .linearGradient(
                    Gradient(colors: [color.opacity(0.25), color.opacity(0.02)]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: 0, y: size.height)
                ))
            }

            context.stroke(
                line,
                with: .color(color),
                style: StrokeStyle(lineWidth: filled ? 2 : 1.5, lineCap: .round, lineJoin: .round)
            )
        }
    }
}
