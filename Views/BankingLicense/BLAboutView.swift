import SwiftUI

struct BLAboutView: View {
    @State private var navigateToSim = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            GreenPatternBackground()

            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                Text(tr("Welcome", "أهلاً بك"))
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 30)

                Text(tr("Before you open your real bank account, you must prove you can protect it. You are about to enter a simulated banking environment where you will face real-world financial threats.\nYour mission is simple: make the right decisions, spot the scams, and keep your virtual funds safe.",
                        "قبل أن تفتح حسابك البنكي الحقيقي، عليك أن تثبت قدرتك على حمايته. أنت على وشك دخول بيئة بنكية محاكاة ستواجه فيها تهديدات مالية واقعية.\nمهمتك بسيطة: اتخذ القرارات الصحيحة، اكشف عمليات الاحتيال، وحافظ على أموالك الافتراضية آمنة."))
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)

                Spacer().frame(height: 40)

                DisclaimerBanner(text: tr("Note: No real money or data is at risk during this training", "ملاحظة: لا توجد أموال أو بيانات حقيقية معرضة للخطر خلال هذا التدريب"))
                    .padding(.horizontal, 30)

                Spacer()

                NavigationLink(destination: BLBankDashboardView()) {
                    Text(tr("Start Simulation", "ابدأ المحاكاة"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.ctaBlue)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }

            ExperienceExitButton()
                .padding(.horizontal, 16)
                .padding(.top, 8)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
