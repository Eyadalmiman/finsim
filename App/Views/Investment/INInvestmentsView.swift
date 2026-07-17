import SwiftUI

struct INInvestmentsView: View {
    let user: User
    let liveBalance: Double
    let buy: (Int, Int) -> Void
    var openCrypto: () -> Void = {}

    private enum BuyAmount: String, CaseIterable {
        case one, ten, max

        var label: String {
            switch self {
            case .one: return "×1"
            case .ten: return "×10"
            case .max: return "MAX"
            }
        }
    }

    @State private var buyAmount: BuyAmount = .one

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text(tr("Prices move with the market — buy on dips, sell from the Portfolio tab on surges. Every sale pays a 5% broker fee.",
                        "الأسعار تتحرك مع السوق — اشترِ عند الانخفاض وبع من تبويب المحفظة عند الارتفاع. كل عملية بيع عليها رسوم وساطة 5٪."))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Quantity selector
                HStack(spacing: 8) {
                    Text(tr("Buy amount", "كمية الشراء"))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    ForEach(BuyAmount.allCases, id: \.self) { amount in
                        Button {
                            withAnimation(.snappy) { buyAmount = amount }
                        } label: {
                            Text(amount.label)
                                .font(.footnote.weight(.bold))
                                .foregroundColor(buyAmount == amount ? .white : .finSimGreen)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule().fill(buyAmount == amount ? Color.finSimGreen : Color.finSimGreen.opacity(0.12))
                                )
                        }
                        .buttonStyle(PressableCardStyle())
                    }
                }
                .padding(.bottom, 2)

                ForEach(Investment.catalog) { inv in
                    storeRow(inv)
                }

                cryptoMarketCard
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
    }

    /// Gateway to the simulated coin exchange.
    private var cryptoMarketCard: some View {
        Button(action: openCrypto) {
            HStack(spacing: 14) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [.orange, Color(red: 0.85, green: 0.45, blue: 0.05)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(tr("Crypto Market", "سوق العملات الرقمية"))
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(tr("High risk", "مخاطرة عالية"))
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.dangerRed)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.dangerRed.opacity(0.14)))
                    }
                    Text(tr("Trade \(CryptoCoin.catalog.count) real coins — BTC, ETH, SOL and more. No income, pure price.",
                            "تداول \(CryptoCoin.catalog.count) عملات حقيقية — بيتكوين وإيثيريوم وسولانا وغيرها. بلا دخل، السعر فقط."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    if user.ownsAnyCrypto {
                        Text(tr("Holdings: \(formatMoney(user.cryptoValue))", "حيازاتك: \(formatMoney(user.cryptoValue))"))
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.finSimGreen)
                            .monospacedDigit()
                    }
                }

                Spacer()

                Image(systemName: appIsArabic ? "chevron.backward" : "chevron.forward")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.secondary)
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

    private func riskColor(_ risk: Double) -> Color {
        switch risk {
        case ..<0.05: return .green
        case ..<0.3:  return .teal
        case ..<0.55: return .orange
        default:      return .dangerRed
        }
    }

    /// Units the current selector buys for this asset (at least 1 so the
    /// button can show a price even when MAX affords none).
    private func quantity(for inv: Investment) -> Int {
        switch buyAmount {
        case .one: return 1
        case .ten: return 10
        case .max: return max(1, user.maxAffordable(of: inv.id, balance: liveBalance))
        }
    }

    /// Live-price chip: how far the asset trades from its fair price.
    @ViewBuilder
    private func trendChip(_ inv: Investment) -> some View {
        let offset = user.priceMultiplier(of: inv.id) - 1
        if inv.risk > 0, abs(offset) >= 0.02 {
            HStack(spacing: 2) {
                Image(systemName: offset > 0 ? "arrow.up.right" : "arrow.down.right")
                Text("\(offset > 0 ? "+" : "−")\(Int(abs(offset) * 100))%")
                    .monospacedDigit()
            }
            .font(.caption2.weight(.bold))
            .foregroundColor(offset > 0 ? .dangerRed : .green)   // high price = bad for buyers
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill((offset > 0 ? Color.dangerRed : Color.green).opacity(0.12)))
        }
    }

    private func storeRow(_ inv: Investment) -> some View {
        let count = user.investmentCount(inv.id)
        let units = quantity(for: inv)
        let price = user.cost(of: inv.id, quantity: units)
        let affordable = liveBalance >= price && units > 0

        return HStack(spacing: 14) {
            Image(systemName: inv.icon)
                .font(.title2)
                .foregroundColor(.finSimGreen)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.finSimGreen.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(inv.name)
                        .font(.headline)
                    Text(inv.riskLabel)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(riskColor(inv.risk))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(riskColor(inv.risk).opacity(0.14)))
                }
                HStack(spacing: 6) {
                    Text(tr("+\(formatMoney(inv.incomePerUnit))/s each", "+\(formatMoney(inv.incomePerUnit))/ث لكل وحدة"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    trendChip(inv)
                }
                Text(tr("Owned: \(count)", "تملك: \(count)"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                buy(inv.id, units)
            } label: {
                VStack(spacing: 1) {
                    if units > 1 {
                        Text("×\(units)")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    Text(formatMoney(price))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, units > 1 ? 6 : 10)
                .background(
                    Capsule().fill(affordable ? Color.ctaBlue : Color.gray.opacity(0.45))
                )
            }
            .buttonStyle(PressableCardStyle())
            .disabled(!affordable)
            .opacity(affordable ? 1 : 0.6)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        )
    }
}
