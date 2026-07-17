import Foundation

// MARK: - Investment Catalog

/// A purchasable investment. Each unit owned generates `incomePerUnit` dollars
/// every second; each additional unit costs `costGrowth`× more than the last.
/// `risk` (0…1) drives the market engine: riskier assets swing more often and
/// harder in both directions — safe assets never lose value but earn less
/// relative to their price.
struct Investment: Identifiable {
    let id: Int
    let name: String
    let icon: String
    let baseCost: Double
    let incomePerUnit: Double
    let risk: Double
    var costGrowth: Double = 1.15

    // Rebuilt only on language change so the names re-localize without the
    // catalog being reconstructed on every access (income ticks, store rows).
    private static let catalogCache = LocalizedCache { buildCatalog() }

    static var catalog: [Investment] { catalogCache.value }

    // Crypto is not an idle asset here — it trades as real coins in the
    // simulated crypto market (see CryptoMarket.swift).
    private static func buildCatalog() -> [Investment] {
        [
            Investment(id: 0, name: tr("Savings Account", "حساب توفير"),    icon: "banknote.fill",             baseCost: 100,        incomePerUnit: 0.5,   risk: 0.0),
            Investment(id: 1, name: tr("Government Bonds", "سندات حكومية"), icon: "doc.text.fill",             baseCost: 1_000,      incomePerUnit: 5,     risk: 0.1),
            Investment(id: 2, name: tr("Stocks", "أسهم"),                   icon: "chart.line.uptrend.xyaxis", baseCost: 10_000,     incomePerUnit: 40,    risk: 0.4),
            Investment(id: 3, name: tr("Real Estate", "عقارات"),            icon: "house.fill",                baseCost: 75_000,     incomePerUnit: 250,   risk: 0.25),
            Investment(id: 4, name: tr("Startup", "شركة ناشئة"),            icon: "lightbulb.fill",            baseCost: 500_000,    incomePerUnit: 1_500, risk: 0.65)
        ]
    }

    /// Human-readable risk tier for the store UI.
    var riskLabel: String {
        switch risk {
        case ..<0.05:  return tr("No risk", "بدون مخاطرة")
        case ..<0.3:   return tr("Low risk", "مخاطرة منخفضة")
        case ..<0.55:  return tr("Medium risk", "مخاطرة متوسطة")
        default:       return tr("High risk", "مخاطرة عالية")
        }
    }
}

// MARK: - Market Events

/// A one-off market swing applied to an owned asset: a surge (gain) or a
/// dip (loss) proportional to the money invested in that asset and its risk.
struct MarketEvent: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let investmentName: String
    let investmentIcon: String
    /// Signed amount added to (or removed from) the balance.
    let amount: Double
    /// The percentage swing that produced the amount, e.g. -0.18.
    let percent: Double

    var isGain: Bool { amount >= 0 }
}

// MARK: - Money Formatting

/// Formats a dollar amount, abbreviating large values (K / M / B / T).
func formatMoney(_ value: Double) -> String {
    let v = abs(value)
    switch v {
    case 1_000_000_000_000...: return String(format: "$%.2fT", value / 1_000_000_000_000)
    case 1_000_000_000...:     return String(format: "$%.2fB", value / 1_000_000_000)
    case 1_000_000...:         return String(format: "$%.2fM", value / 1_000_000)
    case 10_000...:            return String(format: "$%.1fK", value / 1_000)
    default:                   return String(format: "$%.2f", value)
    }
}

// MARK: - Game Logic
//
// The market model: every asset has a live price multiplier (1.0 = fair
// price) that the market loop nudges over time. Buying costs the base price
// scaled by the multiplier, holdings are worth their base value scaled by
// the multiplier, and selling pays that value minus a 5% broker fee — so
// dips are buying opportunities and surges are selling opportunities.

extension User {
    /// Fraction of a sale kept after the broker fee.
    static let sellFeeKeep = 0.95
    /// Live multipliers stay within this band so prices never run away.
    static let multiplierRange = 0.35...4.0
    /// Offline earnings accrue for at most this long between visits.
    static let offlineEarningsCap: TimeInterval = 8 * 3600

    /// Owned count for a catalog index, tolerant of an unsized/empty array.
    func investmentCount(_ index: Int) -> Int {
        guard index >= 0, index < investmentCounts.count else { return 0 }
        return investmentCounts[index]
    }

    var ownsAnyInvestment: Bool {
        Investment.catalog.contains { investmentCount($0.id) > 0 } || ownsAnyCrypto
    }

    /// Total passive income per second across every owned investment.
    var incomePerSecond: Double {
        Investment.catalog.reduce(0) { $0 + Double(investmentCount($1.id)) * $1.incomePerUnit }
    }

    /// Live market multiplier for an asset (1.0 until the market first moves it).
    func priceMultiplier(of index: Int) -> Double {
        guard index >= 0, index < assetPriceMultipliers.count else { return 1 }
        let stored = assetPriceMultipliers[index]
        return stored > 0 ? stored : 1
    }

    /// Sum of the base prices of `quantity` units bought on top of `owned`
    /// (the geometric series behind escalating unit costs).
    private func baseSeries(_ inv: Investment, owned: Int, quantity: Int) -> Double {
        guard quantity > 0 else { return 0 }
        let g = inv.costGrowth
        return inv.baseCost * pow(g, Double(owned)) * (pow(g, Double(quantity)) - 1) / (g - 1)
    }

    /// Live price of the next `quantity` units of an asset.
    func cost(of index: Int, quantity: Int = 1) -> Double {
        let inv = Investment.catalog[index]
        return baseSeries(inv, owned: investmentCount(index), quantity: quantity) * priceMultiplier(of: index)
    }

    /// The most units of an asset the given balance can buy right now.
    func maxAffordable(of index: Int, balance: Double) -> Int {
        var quantity = 0
        while quantity < 500, cost(of: index, quantity: quantity + 1) <= balance {
            quantity += 1
        }
        return quantity
    }

    /// What the current holding of an asset would fetch at the live price
    /// (before the broker fee).
    func holdingsValue(of index: Int) -> Double {
        let inv = Investment.catalog[index]
        return baseSeries(inv, owned: 0, quantity: investmentCount(index)) * priceMultiplier(of: index)
    }

    /// Live value of the whole portfolio.
    var portfolioValue: Double {
        Investment.catalog.reduce(0) { $0 + holdingsValue(of: $1.id) }
    }

    /// Money actually paid for the current holding of an asset. Holdings from
    /// before basis tracking fall back to their base (fair-price) value.
    func costBasis(of index: Int) -> Double {
        if index < assetCostBasis.count, assetCostBasis[index] > 0 {
            return assetCostBasis[index]
        }
        let inv = Investment.catalog[index]
        return baseSeries(inv, owned: 0, quantity: investmentCount(index))
    }

    /// Unrealized profit (or loss, negative) on an asset.
    func unrealizedProfit(of index: Int) -> Double {
        holdingsValue(of: index) - costBasis(of: index)
    }

    /// Cash a sale of `quantity` units would pay right now, after the fee.
    func sellRefund(of index: Int, quantity: Int = 1) -> Double {
        let count = investmentCount(index)
        let q = min(quantity, count)
        guard q > 0 else { return 0 }
        let inv = Investment.catalog[index]
        return baseSeries(inv, owned: count - q, quantity: q) * priceMultiplier(of: index) * User.sellFeeKeep
    }

    /// Grows an array to the catalog size so an index can be written safely.
    private func padded<T>(_ array: [T], with filler: T) -> [T] {
        array.count >= Investment.catalog.count
            ? array
            : array + Array(repeating: filler, count: Investment.catalog.count - array.count)
    }

    /// Rolls the market once: every risky asset's price drifts gently back
    /// toward fair value, and sometimes surges or dips hard. Returns events
    /// for owned assets whose value visibly moved (nothing touches cash —
    /// gains and losses stay on paper until the player sells).
    func rollMarket() -> [MarketEvent] {
        var events: [MarketEvent] = []
        var multipliers = padded(assetPriceMultipliers, with: 1.0)

        for inv in Investment.catalog where inv.risk > 0 {
            let old = multipliers[inv.id] > 0 ? multipliers[inv.id] : 1

            // Gentle pull back toward fair price…
            var updated = old + (1 - old) * 0.02
            var eventPercent: Double?

            // …with a risk-scaled chance of a real swing. Losses skew
            // slightly larger than gains, so risk is a genuine trade-off.
            if Double.random(in: 0...1) < inv.risk * 0.45 {
                let magnitude = Double.random(in: 0.05...0.35) * inv.risk
                let percent = Bool.random() ? magnitude : -magnitude * 1.15
                updated *= (1 + percent)
                eventPercent = percent
            }

            updated = min(User.multiplierRange.upperBound, max(User.multiplierRange.lowerBound, updated))
            multipliers[inv.id] = updated

            if let percent = eventPercent, investmentCount(inv.id) > 0 {
                let baseValue = baseSeries(inv, owned: 0, quantity: investmentCount(inv.id))
                let amount = baseValue * (updated - old)
                if abs(amount) >= 0.01 {
                    events.append(MarketEvent(
                        date: Date(),
                        investmentName: inv.name,
                        investmentIcon: inv.icon,
                        amount: amount,
                        percent: percent
                    ))
                }
            }
        }

        assetPriceMultipliers = multipliers
        return events
    }

    /// Attempts to buy `quantity` units at the live price. Returns false if
    /// unaffordable.
    @discardableResult
    func buyInvestment(_ index: Int, quantity: Int = 1) -> Bool {
        guard quantity > 0 else { return false }
        let price = cost(of: index, quantity: quantity)
        guard investmentBalance >= price else { return false }

        // Fold any legacy holding into the stored basis before adding to it.
        var basis = padded(assetCostBasis, with: 0.0)
        basis[index] = costBasis(of: index) + price

        // Reassign whole arrays so SwiftData records the changes.
        var counts = padded(investmentCounts, with: 0)
        counts[index] += quantity

        investmentCounts = counts
        assetCostBasis = basis
        investmentBalance -= price
        investmentIncomePerSecond = incomePerSecond
        return true
    }

    /// Sells `quantity` units at the live price minus the broker fee and
    /// returns the cash received, or nil if there is nothing to sell.
    @discardableResult
    func sellInvestment(_ index: Int, quantity: Int = 1) -> Double? {
        let count = investmentCount(index)
        let q = min(quantity, count)
        guard q > 0 else { return nil }

        let refund = sellRefund(of: index, quantity: q)

        // Release a proportional share of the cost basis with the units.
        let basisBefore = costBasis(of: index)
        var basis = padded(assetCostBasis, with: 0.0)
        basis[index] = max(0, basisBefore - basisBefore * Double(q) / Double(count))

        var counts = padded(investmentCounts, with: 0)
        counts[index] = count - q

        investmentCounts = counts
        assetCostBasis = basis
        investmentBalance += refund
        investmentIncomePerSecond = incomePerSecond
        return refund
    }
}
