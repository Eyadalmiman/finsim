import SwiftUI

struct INAssetsView: View {
    let user: User
    let sell: (Int, Int) -> Void
    var openCrypto: () -> Void = {}

    /// Fixed accent per catalog slot for the allocation bar.
    private static let allocationColors: [Color] = [.green, .teal, .ctaBlue, .orange, .purple, .dangerRed]

    private var totalValue: Double { user.portfolioValue + user.cryptoValue }

    private var totalProfit: Double {
        let idle = Investment.catalog.reduce(0.0) { $0 + (user.investmentCount($1.id) > 0 ? user.unrealizedProfit(of: $1.id) : 0) }
        let crypto = CryptoCoin.catalog.reduce(0.0) { $0 + (user.cryptoUnits(of: $1.id) > 0 ? user.cryptoProfit(of: $1.id) : 0) }
        return idle + crypto
    }

    var body: some View {
        VStack(spacing: 0) {
            // Portfolio summary header
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 14) {
                    Image(systemName: "briefcase.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.15)))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tr("Portfolio value", "قيمة المحفظة"))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text(formatMoney(totalValue))
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.default, value: formatMoney(totalValue))
                    }

                    Spacer()

                    if user.ownsAnyInvestment {
                        HStack(spacing: 3) {
                            Image(systemName: totalProfit >= 0 ? "arrow.up.right" : "arrow.down.right")
                            Text("\(totalProfit >= 0 ? "+" : "−")\(formatMoney(abs(totalProfit)))")
                                .monospacedDigit()
                        }
                        .font(.footnote.weight(.bold))
                        .foregroundColor(totalProfit >= 0 ? Color(red: 0.65, green: 1.0, blue: 0.75) : Color(red: 1.0, green: 0.7, blue: 0.7))
                    }
                }

                if user.ownsAnyInvestment {
                    allocationBar
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.finSimGreen)
            )
            .padding(.horizontal, 16)
            .padding(.top, 10)

            // Owned investments
            ScrollView {
                if user.ownsAnyInvestment {
                    VStack(spacing: 12) {
                        ForEach(Investment.catalog) { inv in
                            if user.investmentCount(inv.id) > 0 {
                                assetRow(inv)
                            }
                        }

                        // Coins, tradable in the crypto market
                        ForEach(CryptoCoin.catalog) { coin in
                            if user.cryptoUnits(of: coin.id) > 0 {
                                cryptoRow(coin)
                            }
                        }

                        Text(tr("Selling pays the live market price minus a 5% broker fee (0.5% for coins).",
                                "البيع يدفع سعر السوق الحالي مطروحاً منه رسوم وساطة 5٪ (و0.5٪ للعملات الرقمية)."))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text(tr("You dont have any assets", "ليس لديك أي أصول"))
                            .font(.title3)
                            .foregroundColor(.primary)
                        Text(tr("Buy investments from the Invest tab to build your portfolio.", "اشترِ استثمارات من تبويب استثمر لبناء محفظتك."))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    .padding(.horizontal, 24)
                }
            }

            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }

    /// One capsule split by each asset's share of the portfolio — a picture
    /// of how diversified (or concentrated) the player is. Coins show as a
    /// single combined crypto segment.
    private var allocationBar: some View {
        GeometryReader { geo in
            HStack(spacing: 2) {
                ForEach(Investment.catalog) { inv in
                    let value = user.holdingsValue(of: inv.id)
                    if value > 0, totalValue > 0 {
                        Self.allocationColors[inv.id % Self.allocationColors.count]
                            .frame(width: max(3, geo.size.width * value / totalValue))
                    }
                }
                if user.cryptoValue > 0, totalValue > 0 {
                    Color.orange
                        .frame(width: max(3, geo.size.width * user.cryptoValue / totalValue))
                }
            }
            .clipShape(Capsule())
        }
        .frame(height: 8)
    }

    private func assetRow(_ inv: Investment) -> some View {
        let count = user.investmentCount(inv.id)
        let value = user.holdingsValue(of: inv.id)
        let profit = user.unrealizedProfit(of: inv.id)
        let basis = user.costBasis(of: inv.id)
        let profitPercent = basis > 0 ? Int(abs(profit) / basis * 100) : 0

        return VStack(spacing: 10) {
            HStack(spacing: 14) {
                Image(systemName: inv.icon)
                    .font(.title3)
                    .foregroundColor(Self.allocationColors[inv.id % Self.allocationColors.count])
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Self.allocationColors[inv.id % Self.allocationColors.count].opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(inv.name)
                        .font(.headline)
                    Text("×\(count)  •  +\(formatMoney(Double(count) * inv.incomePerUnit))/s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatMoney(value))
                        .font(.subheadline.weight(.bold))
                        .monospacedDigit()
                    HStack(spacing: 2) {
                        Image(systemName: profit >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(profit >= 0 ? "+" : "−")\(formatMoney(abs(profit))) (\(profitPercent)%)")
                            .monospacedDigit()
                    }
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(profit >= 0 ? .green : .dangerRed)
                }
            }

            HStack(spacing: 8) {
                Text(tr("Sell for \(formatMoney(user.sellRefund(of: inv.id)))", "بِع مقابل \(formatMoney(user.sellRefund(of: inv.id)))"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()

                Spacer()

                sellButton(tr("Sell 1", "بِع 1")) { sell(inv.id, 1) }
                if count > 1 {
                    sellButton(tr("Sell all", "بِع الكل")) { sell(inv.id, count) }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        )
    }

    /// A coin holding; trading happens in the crypto market, so the row
    /// shows value and profit and opens the market on tap.
    private func cryptoRow(_ coin: CryptoCoin) -> some View {
        let held = user.cryptoUnits(of: coin.id)
        let value = user.cryptoValue(of: coin.id)
        let profit = user.cryptoProfit(of: coin.id)
        let basis = user.cryptoCostBasis(of: coin.id)

        return Button(action: openCrypto) {
            HStack(spacing: 14) {
                coinBadge(coin)

                VStack(alignment: .leading, spacing: 2) {
                    Text(coin.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("\(formatCoinUnits(held)) \(coin.ticker)  •  \(formatCoinPrice(user.cryptoPrice(of: coin.id)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatMoney(value))
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                    HStack(spacing: 2) {
                        Image(systemName: profit >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(profit >= 0 ? "+" : "−")\(formatMoney(abs(profit))) (\(basis > 0 ? Int(abs(profit) / basis * 100) : 0)%)")
                            .monospacedDigit()
                    }
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(profit >= 0 ? .green : .dangerRed)
                    Text(tr("Trade", "تداول"))
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.ctaBlue)
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

    private func sellButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().fill(Color.dangerRed.opacity(0.9)))
        }
        .buttonStyle(PressableCardStyle())
    }
}
