import SwiftUI

/// The 30-second story of the app: the problem, what FinSim does about it,
/// and why it matters. Shown once on first launch and any time from
/// Settings → About FinSim.
struct AboutFinSimView: View {
    var isFirstLaunch: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            GreenPatternBackground()

            ScrollView {
                VStack(spacing: 18) {
                    // Logo + title
                    VStack(spacing: 12) {
                        Image("AILogo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 84, height: 84)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: .black.opacity(0.3), radius: 10, y: 4)

                        Text("FinSim")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.white)

                        Text(tr("Learn money by living it — safely.",
                                "تعلّم المال بأن تعيشه — بأمان."))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.top, 30)

                    missionCard(
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .orange,
                        title: tr("The problem", "المشكلة"),
                        body: tr("Young people get their first bank account, first salary, and first scam SMS — all before anyone teaches them how money works. Fraudsters target exactly this gap, and lessons that are only read are quickly forgotten.",
                                 "يحصل الشباب على أول حساب بنكي وأول راتب وأول رسالة احتيال — قبل أن يعلّمهم أحد كيف يعمل المال. المحتالون يستهدفون هذه الفجوة بالذات، والدروس التي تُقرأ فقط سرعان ما تُنسى.")
                    )

                    missionCard(
                        icon: "gamecontroller.fill",
                        iconColor: .finSimLightGreen,
                        title: tr("What FinSim does", "ماذا يفعل FinSim"),
                        body: tr("You live the lessons instead of reading them: face real scam tactics inside a simulated bank, grow a portfolio in a market that surges and crashes like the real one, and back it all up with a full financial library and an AI coach — in English and Arabic.",
                                 "تعيش الدروس بدلاً من قراءتها: تواجه أساليب احتيال حقيقية داخل بنك محاكى، وتنمّي محفظة في سوق يرتفع وينهار مثل السوق الحقيقي، وتدعم ذلك كله بمكتبة مالية كاملة ومدرب ذكي — بالعربية والإنجليزية.")
                    )

                    missionCard(
                        icon: "checkmark.shield.fill",
                        iconColor: .ctaBlue,
                        title: tr("Why it matters", "لماذا يهم"),
                        body: tr("Financial literacy is a national goal under Saudi Vision 2030, and awareness is the only real defense against fraud. In FinSim every mistake is free: no real money, no real data — the place to fall for your first scam is here, not in your bank app.",
                                 "الثقافة المالية هدف وطني ضمن رؤية السعودية 2030، والوعي هو الدفاع الحقيقي الوحيد ضد الاحتيال. في FinSim كل خطأ مجاني: لا أموال حقيقية ولا بيانات حقيقية — المكان المناسب للوقوع في أول عملية احتيال هو هنا، وليس في تطبيق بنكك.")
                    )

                    Button {
                        dismiss()
                    } label: {
                        Text(isFirstLaunch ? tr("Let's start", "لنبدأ") : tr("Done", "تم"))
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private func missionCard(icon: String, iconColor: Color, title: String, body text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(iconColor)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(0.12)))
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }

            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .glassmorphic()
    }
}
