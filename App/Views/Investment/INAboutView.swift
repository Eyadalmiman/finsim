import SwiftUI

struct INAboutView: View {
    @State private var navigateToGame = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            GreenPatternBackground()

            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                Text(tr("Welcome", "أهلاً بك"))
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)

                Text(tr("In this simulation you will be in a game, the game is about investing and making the right choices to make more money. Your money will be saved the next time you come in this game again",
                        "في هذه المحاكاة ستدخل لعبة عن الاستثمار واتخاذ القرارات الصحيحة لكسب المزيد من المال. سيتم حفظ أموالك عند عودتك إلى اللعبة في المرة القادمة"))
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)

                Spacer().frame(height: 40)

                DisclaimerBanner(text: tr("Note: No real money or data is at risk during this game",
                                          "ملاحظة: لا توجد أموال أو بيانات حقيقية معرضة للخطر خلال هذه اللعبة"))
                    .padding(.horizontal, 30)

                Spacer()

                NavigationLink(destination: INTabContainerView()) {
                    Text(tr("Start game", "ابدأ اللعبة"))
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
