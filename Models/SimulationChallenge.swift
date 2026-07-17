import Foundation

/// The fraud challenges of the Banking License training, in play order.
/// See the scoring extension below for how a run turns into a percentage.
enum SimulationChallenge: Int, CaseIterable, Identifiable {
    case otpPhishing
    case deliveryScam
    case vishingCall
    case socialMediaAd

    var id: Int { rawValue }

    /// The challenge that follows this one, nil after the last.
    var next: SimulationChallenge? { SimulationChallenge(rawValue: rawValue + 1) }

    var title: String {
        switch self {
        case .otpPhishing:   return tr("OTP Phishing Trap", "فخ التصيد برمز التحقق")
        case .deliveryScam:  return tr("Delivery Fee Scam", "احتيال رسوم التوصيل")
        case .vishingCall:   return tr("Vishing Call", "المكالمة الاحتيالية")
        case .socialMediaAd: return tr("Investment Ad Scam", "الإعلان الاستثماري الاحتيالي")
        }
    }

    var icon: String {
        switch self {
        case .otpPhishing:   return "lock.shield.fill"
        case .deliveryScam:  return "shippingbox.fill"
        case .vishingCall:   return "phone.fill"
        case .socialMediaAd: return "megaphone.fill"
        }
    }

    /// One-line review shown on the results dashboard for this run.
    func reviewLine(mistakes: Int) -> String {
        let times = mistakes == 1
            ? tr("once", "مرة واحدة")
            : tr("\(mistakes) times", "\(mistakes) مرات")

        switch self {
        case .otpPhishing:
            return mistakes == 0
                ? tr("You ignored the fake bank message and reported it on the first try. That's exactly how to handle it.",
                     "تجاهلت رسالة البنك المزيفة وأبلغت عنها من المحاولة الأولى. هذا هو التصرف الصحيح تماماً.")
                : tr("You entered the OTP from an unsolicited message \(times) before reporting it.",
                     "أدخلت رمز التحقق من رسالة مجهولة \(times) قبل الإبلاغ عنها.")
        case .deliveryScam:
            return mistakes == 0
                ? tr("You closed the fake payment page and verified on the official app instead. Perfect instinct.",
                     "أغلقت صفحة الدفع المزيفة وتحققت من التطبيق الرسمي بدلاً منها. حدس ممتاز.")
                : tr("You tried to enter card details on a fake delivery site \(times).",
                     "حاولت إدخال بيانات بطاقتك في موقع توصيل مزيف \(times).")
        case .vishingCall:
            return mistakes == 0
                ? tr("You hung up and called the bank directly instead of trusting the caller. Well done.",
                     "أغلقت الخط واتصلت بالبنك مباشرة بدلاً من الوثوق بالمتصل. أحسنت.")
                : tr("You read your verification code aloud to a fake bank agent \(times).",
                     "قرأت رمز التحقق بصوت عالٍ لموظف بنك مزيف \(times).")
        case .socialMediaAd:
            return mistakes == 0
                ? tr("You reported the too-good-to-be-true ad instead of linking your account. Exactly right.",
                     "أبلغت عن الإعلان الخيالي بدلاً من ربط حسابك. تصرف صحيح تماماً.")
                : tr("You tried to link your bank account to a scam investment ad \(times).",
                     "حاولت ربط حسابك البنكي بإعلان استثماري احتيالي \(times).")
        }
    }
}

// MARK: - Scoring

extension SimulationChallenge {
    /// Every wrong choice, on any challenge, costs this share of the final
    /// score. Falling for a scam twice in one run fails the whole license.
    static let mistakePenalty = 0.25

    /// Minimum score needed to earn the license (at most one mistake).
    static let passThreshold = 0.6

    /// Score for a run: the fraction of challenges completed minus the
    /// penalty for every mistake made so far, floored at zero. The single
    /// source of truth for mid-flow progress and the final result alike.
    static func score(completed: Int = allCases.count, totalMistakes: Int) -> Double {
        max(0, Double(completed) / Double(allCases.count) - mistakePenalty * Double(totalMistakes))
    }
}
