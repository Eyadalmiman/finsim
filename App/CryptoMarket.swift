import Foundation
import SwiftUI

// MARK: - Coin Catalog

/// A real-world coin tradable in the simulated crypto market.
struct CryptoCoin: Identifiable {
    let id: Int
    let ticker: String
    let name: String
    let color: Color
    /// Realistic starting price (USD).
    let basePrice: Double
    /// Idiosyncratic volatility per simulation tick (one tick ≈ a market hour).
    let tickVolatility: Double
    /// How strongly the coin follows Bitcoin — the market's gravity.
    let beta: Double

    static var catalog: [CryptoCoin] { catalogCache.value }
    private static let catalogCache = LocalizedCache { buildCatalog() }

    private static func buildCatalog() -> [CryptoCoin] {
        [
            CryptoCoin(id: 0, ticker: "BTC",  name: tr("Bitcoin", "بيتكوين"),        color: .orange,  basePrice: 103_000, tickVolatility: 0.006, beta: 1.0),
            CryptoCoin(id: 1, ticker: "ETH",  name: tr("Ethereum", "إيثيريوم"),      color: .indigo,  basePrice: 3_400,   tickVolatility: 0.009, beta: 1.15),
            CryptoCoin(id: 2, ticker: "SOL",  name: tr("Solana", "سولانا"),          color: .purple,  basePrice: 165,     tickVolatility: 0.013, beta: 1.25),
            CryptoCoin(id: 3, ticker: "BNB",  name: tr("BNB", "بينانس كوين"),        color: .yellow,  basePrice: 705,     tickVolatility: 0.009, beta: 0.9),
            CryptoCoin(id: 4, ticker: "XRP",  name: tr("XRP", "ريبل"),               color: .teal,    basePrice: 2.15,    tickVolatility: 0.012, beta: 1.1),
            CryptoCoin(id: 5, ticker: "ADA",  name: tr("Cardano", "كاردانو"),        color: .ctaBlue, basePrice: 0.68,    tickVolatility: 0.013, beta: 1.15),
            CryptoCoin(id: 6, ticker: "DOGE", name: tr("Dogecoin", "دوجكوين"),       color: .brown,   basePrice: 0.21,    tickVolatility: 0.019, beta: 1.3),
            CryptoCoin(id: 7, ticker: "LTC",  name: tr("Litecoin", "لايتكوين"),      color: .gray,    basePrice: 96,      tickVolatility: 0.010, beta: 1.0)
        ]
    }
}

// MARK: - Simulation Engine

/// Simulates coin prices the way real crypto behaves:
/// - a sticky market regime (bull / bear / sideways) gives multi-minute
///   trends instead of pure noise;
/// - every coin follows Bitcoin's move through its beta (real coins are
///   heavily correlated) plus its own idiosyncratic noise;
/// - volatility clusters: after a shock, the whole market stays turbulent
///   for a while before calming down;
/// - rare news jumps spike a single coin by several percent, skewed to the
///   downside — crypto crashes harder than it rallies.
///
/// Regime and turbulence state are session-local; prices persist on the
/// User so the market continues where it left off (with catch-up ticks for
/// the time the app was closed).
@MainActor
final class CryptoSim {
    static let shared = CryptoSim()

    enum Regime: CaseIterable {
        case bull, bear, sideways

        var drift: Double {
            switch self {
            case .bull: return 0.0012
            case .bear: return -0.0012
            case .sideways: return 0
            }
        }
    }

    private(set) var regime: Regime = .sideways
    /// Market-wide turbulence multiplier (1 = calm), decaying toward calm.
    private(set) var turbulence: Double = 1
    /// Rolling price history per coin, for the charts (newest last).
    private(set) var histories: [[Double]] = []

    private let historyCap = 240
    /// Ignore single ticks that arrive faster than this — several screens
    /// tick the engine and must not accelerate the market.
    private let minTickGap: TimeInterval = 1.5

    private init() {}

    /// Grows an array to the coin catalog size.
    private func padded<T>(_ array: [T], with filler: T) -> [T] {
        array.count >= CryptoCoin.catalog.count
            ? array
            : array + Array(repeating: filler, count: CryptoCoin.catalog.count - array.count)
    }

    private func gaussian() -> Double {
        // Box–Muller transform.
        let u1 = Double.random(in: 1e-9...1)
        let u2 = Double.random(in: 0...1)
        return sqrt(-2 * log(u1)) * cos(2 * .pi * u2)
    }

    /// Makes sure prices and histories exist, seeding history with a warmup
    /// run so charts have a past on first open.
    func prepare(for user: User) {
        var prices = padded(user.cryptoPrices, with: 0)
        for coin in CryptoCoin.catalog where prices[coin.id] <= 0 {
            prices[coin.id] = coin.basePrice
        }
        user.cryptoPrices = prices

        if histories.count != CryptoCoin.catalog.count {
            histories = CryptoCoin.catalog.map { [user.cryptoPrices[$0.id]] }
            advance(user: user, steps: 120)      // build a believable past
        }
    }

    /// Advances the market since the last visit (capped), so prices moved
    /// while the app was closed.
    func catchUp(for user: User) {
        prepare(for: user)
        if let last = user.cryptoLastTick {
            let steps = min(Int(Date().timeIntervalSince(last) / 12), 240)
            if steps > 0 { advance(user: user, steps: steps) }
        }
        user.cryptoLastTick = Date()
    }

    /// One live tick, rate-limited so overlapping screens can all call it.
    func tick(for user: User) {
        prepare(for: user)
        if let last = user.cryptoLastTick, Date().timeIntervalSince(last) < minTickGap { return }
        advance(user: user, steps: 1)
        user.cryptoLastTick = Date()
    }

    private func advance(user: User, steps: Int) {
        var prices = padded(user.cryptoPrices, with: 0)

        for _ in 0..<steps {
            // Regime shifts are rare, so trends persist long enough to see.
            if Double.random(in: 0...1) < 0.015 {
                regime = Regime.allCases.randomElement() ?? .sideways
            }

            // Turbulence decays toward calm, with occasional flare-ups.
            turbulence = max(1, turbulence * 0.97)
            if Double.random(in: 0...1) < 0.01 { turbulence = 2.2 }

            // Bitcoin's move is the market factor every coin leans on.
            let marketMove = regime.drift + gaussian() * 0.005 * turbulence

            for coin in CryptoCoin.catalog {
                var change = coin.beta * marketMove
                    + gaussian() * coin.tickVolatility * turbulence

                // Rare single-coin news jump, skewed to the downside.
                if Double.random(in: 0...1) < 0.004 {
                    let jump = Double.random(in: 0.03...0.12)
                    change += Bool.random() ? jump : -jump * 1.2
                    turbulence = max(turbulence, 1.8)
                }

                let updated = prices[coin.id] * (1 + change)
                // Keep prices in a sane band around their base.
                prices[coin.id] = min(coin.basePrice * 50, max(coin.basePrice * 0.05, updated))

                histories[coin.id].append(prices[coin.id])
                if histories[coin.id].count > historyCap {
                    histories[coin.id].removeFirst(histories[coin.id].count - historyCap)
                }
            }
        }

        user.cryptoPrices = prices
    }

    /// Percent change across the visible chart window for a coin.
    func windowChange(of index: Int) -> Double {
        guard index < histories.count else { return 0 }
        let window = histories[index].suffix(120)
        guard let first = window.first, first > 0, let last = window.last else { return 0 }
        return (last - first) / first
    }
}

// MARK: - Player Holdings

extension User {
    /// Trading fee kept by the exchange on every sale.
    static let cryptoFeeKeep = 0.995

    private func paddedCrypto(_ array: [Double]) -> [Double] {
        array.count >= CryptoCoin.catalog.count
            ? array
            : array + Array(repeating: 0, count: CryptoCoin.catalog.count - array.count)
    }

    /// Live simulated price for a coin (base price until the sim first runs).
    func cryptoPrice(of index: Int) -> Double {
        if index < cryptoPrices.count, cryptoPrices[index] > 0 { return cryptoPrices[index] }
        return CryptoCoin.catalog[index].basePrice
    }

    func cryptoUnits(of index: Int) -> Double {
        guard index >= 0, index < cryptoUnits.count else { return 0 }
        return cryptoUnits[index]
    }

    var ownsAnyCrypto: Bool {
        CryptoCoin.catalog.contains { cryptoUnits(of: $0.id) > 0 }
    }

    /// Live dollar value of one coin's holding.
    func cryptoValue(of index: Int) -> Double {
        cryptoUnits(of: index) * cryptoPrice(of: index)
    }

    /// Live dollar value of all coins held.
    var cryptoValue: Double {
        CryptoCoin.catalog.reduce(0) { $0 + cryptoValue(of: $1.id) }
    }

    func cryptoCostBasis(of index: Int) -> Double {
        guard index >= 0, index < cryptoCostBasis.count else { return 0 }
        return cryptoCostBasis[index]
    }

    /// Unrealized profit (or loss) on a coin.
    func cryptoProfit(of index: Int) -> Double {
        cryptoValue(of: index) - cryptoCostBasis(of: index)
    }

    /// Buys `dollars` worth of a coin at the live price.
    @discardableResult
    func buyCrypto(_ index: Int, dollars: Double) -> Bool {
        let price = cryptoPrice(of: index)
        guard dollars > 0, price > 0, investmentBalance >= dollars else { return false }

        var units = paddedCrypto(cryptoUnits)
        var basis = paddedCrypto(cryptoCostBasis)
        units[index] += dollars / price
        basis[index] += dollars

        cryptoUnits = units
        cryptoCostBasis = basis
        investmentBalance -= dollars
        return true
    }

    /// Sells `quantity` units of a coin at the live price minus the trading
    /// fee. Returns the cash received, or nil if there was nothing to sell.
    @discardableResult
    func sellCrypto(_ index: Int, quantity: Double) -> Double? {
        let held = cryptoUnits(of: index)
        let q = min(quantity, held)
        guard q > 0 else { return nil }

        let proceeds = q * cryptoPrice(of: index) * User.cryptoFeeKeep

        var units = paddedCrypto(cryptoUnits)
        var basis = paddedCrypto(cryptoCostBasis)
        let basisBefore = basis[index]
        basis[index] = max(0, basisBefore - basisBefore * q / held)
        units[index] = held - q
        // Dust from floating-point math counts as fully sold.
        if units[index] < 1e-9 { units[index] = 0; basis[index] = 0 }

        cryptoUnits = units
        cryptoCostBasis = basis
        investmentBalance += proceeds
        return proceeds
    }
}

// MARK: - Formatting

private let coinPriceFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = ","
    return formatter
}()

/// Exact coin price, with decimals that fit the magnitude:
/// $103,482 · $3,412.55 · $0.2134
func formatCoinPrice(_ value: Double) -> String {
    let digits: Int
    switch abs(value) {
    case ..<1:      digits = 4
    case ..<1_000:  digits = 2
    default:        digits = 0
    }
    coinPriceFormatter.minimumFractionDigits = digits
    coinPriceFormatter.maximumFractionDigits = digits
    let number = coinPriceFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    return "$\(number)"
}

/// Coin quantity, trimmed of trailing zeros: 0.0042 · 1.5 · 320
func formatCoinUnits(_ value: Double) -> String {
    let digits = abs(value) >= 100 ? 2 : 5
    var text = String(format: "%.\(digits)f", value)
    while text.contains("."), text.hasSuffix("0") { text.removeLast() }
    if text.hasSuffix(".") { text.removeLast() }
    return text
}
