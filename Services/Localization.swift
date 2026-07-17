import Foundation

/// True when the app language setting is Arabic.
var appIsArabic: Bool {
    UserDefaults.standard.string(forKey: "selectedLanguage") == "العربية"
}

/// Picks the Arabic string when the app language is set to العربية.
/// Views re-render on language change because ContentView rebuilds the
/// whole tree (`.id(selectedLanguage)`), so reading UserDefaults here is safe.
func tr(_ english: String, _ arabic: String) -> String {
    appIsArabic ? arabic : english
}

/// Caches a value built from localized (tr) strings, rebuilding it only when
/// the app language changes. Use for static catalogs that would otherwise be
/// reconstructed on every access.
final class LocalizedCache<Value> {
    private var cached: (isArabic: Bool, value: Value)?
    private let lock = NSLock()
    private let build: () -> Value

    init(_ build: @escaping () -> Value) {
        self.build = build
    }

    var value: Value {
        let isArabic = appIsArabic
        lock.lock()
        defer { lock.unlock() }
        if let cached, cached.isArabic == isArabic { return cached.value }
        let value = build()
        cached = (isArabic, value)
        return value
    }
}
