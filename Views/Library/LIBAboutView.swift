import SwiftUI

struct LIBAboutView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            GreenPatternBackground()

            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                Text(tr("Welcome", "أهلاً بك"))
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)

                Text(tr("This is the library, here you can learn almost everything about money, how to invest (in real life). how to save up money and other things that are related to money",
                        "هذه هي المكتبة، هنا يمكنك تعلم كل شيء تقريباً عن المال، كيف تستثمر (في الحياة الواقعية)، كيف تدخر المال وأمور أخرى متعلقة بالمال"))
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)

                Spacer().frame(height: 40)

                DisclaimerBanner(text: tr("Note: If you there is something that is missing or is wrong please email our support (you can find the email from the settings page)",
                                      "ملاحظة: إذا كان هناك شيء ناقص أو خاطئ يرجى مراسلة الدعم عبر البريد الإلكتروني (تجد البريد في صفحة الإعدادات)"))
                    .padding(.horizontal, 30)

                Spacer()

                NavigationLink(destination: LIBTableOfContentsView()) {
                    Text(tr("Go into the library", "ادخل إلى المكتبة"))
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
