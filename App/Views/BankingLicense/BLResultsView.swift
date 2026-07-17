import SwiftUI

/// End-of-training dashboard: score ring, a review of every challenge with the
/// mistakes made, and the verdict. A flawless run earns the "License Granted"
/// screen. The score here is what the Account page shows as completion.
struct BLResultsView: View {
    /// Mistakes per challenge for this run.
    let mistakes: [SimulationChallenge: Int]

    var totalMistakes: Int { mistakes.values.reduce(0, +) }

    var correctPercentage: Double {
        SimulationChallenge.score(totalMistakes: totalMistakes)
    }

    var passed: Bool { correctPercentage >= SimulationChallenge.passThreshold }
    var flawless: Bool { correctPercentage >= 0.999 }

    @Environment(\.exitExperience) private var exitExperience

    var body: some View {
        ZStack {
            GreenPatternBackground()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 30)

                    // License Granted hero — only for a flawless run
                    if flawless {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(.white, .green)
                                .shadow(color: .green.opacity(0.5), radius: 14)

                            Text(tr("License Granted!", "!تم منح الرخصة"))
                                .font(.title.weight(.bold))
                                .foregroundColor(.white)

                            Text(tr("100% completion — you spotted every scam. Your virtual banking license is on its way.",
                                    "إنجاز 100٪ — كشفت كل عمليات الاحتيال. رخصتك البنكية الافتراضية في الطريق إليك."))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .glassmorphic()
                    }

                    // Score Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text(tr("Percent of completion", "نسبة الإنجاز"))
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 8)
                                    .frame(width: 80, height: 80)

                                Circle()
                                    .trim(from: 0, to: correctPercentage)
                                    .stroke(
                                        passed ? Color.ctaBlue : Color.dangerRed,
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))

                                Text("\(Int(correctPercentage * 100))%")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(.white)
                                    .monospacedDigit()
                            }

                            HStack(spacing: 6) {
                                Circle()
                                    .fill(passed ? Color.ctaBlue : Color.dangerRed)
                                    .frame(width: 10, height: 10)
                                Text(passed ? tr("Passed", "ناجح") : tr("Needs work", "يحتاج تحسيناً"))
                                    .foregroundColor(.white)
                                    .font(.body.weight(.medium))
                            }

                            Spacer()
                        }
                    }
                    .padding(20)
                    .glassmorphic()

                    // Challenge Review — what went right and wrong
                    VStack(alignment: .leading, spacing: 16) {
                        Text(tr("Challenge Review", "مراجعة التحديات"))
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(SimulationChallenge.allCases) { challenge in
                            let count = mistakes[challenge] ?? 0

                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: challenge.icon)
                                    .font(.body)
                                    .foregroundColor(count == 0 ? .green : .orange)
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(Color.white.opacity(0.12)))

                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 6) {
                                        Text(challenge.title)
                                            .font(.body.weight(.semibold))
                                            .foregroundColor(.white)
                                        Image(systemName: count == 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(count == 0 ? .green : .orange)
                                    }

                                    Text(challenge.reviewLine(mistakes: count))
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }

                        if totalMistakes > 0 {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                    .padding(.top, 2)
                                Text(tr("Golden rule: no real bank, courier, or investment firm asks for OTPs, card details, or account access out of the blue. When pressured to act fast — stop.",
                                        "القاعدة الذهبية: لا يطلب أي بنك أو شركة شحن أو شركة استثمار حقيقية رموز التحقق أو بيانات البطاقة أو الوصول لحسابك فجأة. عندما يضغط عليك أحد للتصرف بسرعة — توقف."))
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .glassmorphic()

                    // Verdict Card (the flawless run already has its hero)
                    if !flawless {
                        VStack(spacing: 12) {
                            Text(passed ? tr("Well Done !", "!أحسنت") : tr("Uh Oh!", "!للأسف"))
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)

                            Text(
                                passed
                                ? tr("You passed! Review the mistakes above — a flawless run earns the license with 100%. You can retake the simulation anytime.",
                                     "لقد نجحت! راجع الأخطاء أعلاه — الجولة الخالية من الأخطاء تمنحك الرخصة بنسبة 100٪. يمكنك إعادة المحاكاة في أي وقت.")
                                : tr("You made it through, but falling for the scams cost you. Review your mistakes above and run the simulation again to raise your score.",
                                     "لقد أكملت التدريب، لكن الوقوع في الفخاخ كلفك الكثير. راجع أخطاءك أعلاه وأعد المحاكاة لرفع نتيجتك.")
                            )
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                        }
                        .padding(24)
                        .glassmorphic()
                    }

                    // Finish Button
                    Button {
                        exitExperience()
                    } label: {
                        Text(tr("Finish", "إنهاء"))
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 24)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
