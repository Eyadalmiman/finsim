import SwiftUI

struct LearningOptionsView: View {
    @State private var activeExperience: LearningExperience?

    var body: some View {
        ZStack {
            GreenPatternBackground()

            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text(tr("Welcome back", "أهلاً بعودتك"))
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.75))

                    Text(tr("What do you want to learn today?", "ماذا تريد أن تتعلم اليوم؟"))
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                .padding(.bottom, 28)
                .padding(.horizontal, 20)

                VStack(spacing: 16) {
                    Button {
                        activeExperience = .bankingLicense
                    } label: {
                        LearningOptionCard(
                            title: tr("Banking License", "الرخصة البنكية"),
                            iconName: "building.columns.fill",
                            gradientColors: [
                                Color(red: 0.2, green: 0.3, blue: 0.5),
                                Color(red: 0.3, green: 0.4, blue: 0.6)
                            ]
                        )
                    }

                    Button {
                        activeExperience = .investment
                    } label: {
                        LearningOptionCard(
                            title: tr("Investment", "الاستثمار"),
                            iconName: "chart.line.uptrend.xyaxis",
                            gradientColors: [
                                Color(red: 0.4, green: 0.2, blue: 0.5),
                                Color(red: 0.3, green: 0.3, blue: 0.6)
                            ]
                        )
                    }

                    Button {
                        activeExperience = .library
                    } label: {
                        LearningOptionCard(
                            title: tr("The library", "المكتبة"),
                            iconName: "books.vertical.fill",
                            gradientColors: [
                                Color(red: 0.5, green: 0.3, blue: 0.2),
                                Color(red: 0.4, green: 0.25, blue: 0.15)
                            ]
                        )
                    }
                }
                .buttonStyle(PressableCardStyle())
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(item: $activeExperience) { experience in
            ExperienceContainerView(experience: experience) {
                activeExperience = nil
            }
        }
    }
}

// MARK: - Learning Option Card

struct LearningOptionCard: View {
    let title: String
    let iconName: String
    let gradientColors: [Color]

    var body: some View {
        HStack(spacing: 0) {
            // Left: Image area
            ZStack {
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.55)

                Image(systemName: iconName)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(Color.white.opacity(0.14)))
            }
            .frame(width: 130)

            // Right: Title area
            HStack(spacing: 12) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.forward")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.55))
            }
            .padding(.horizontal, 18)
        }
        .frame(height: 100)
        .liquidGlass(cornerRadius: 14, tint: gradientColors.last)
        .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
    }
}
