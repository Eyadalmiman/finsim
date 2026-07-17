import SwiftUI

/// Challenge D: a mock social feed with a "guaranteed returns" sponsored ad
/// slipped between normal posts. Tapping it opens a glass modal where the
/// user chooses between linking their bank account or reporting the ad.
struct InvestmentAdView: View {
    var onMistake: () -> Void = {}
    var onPassed: () -> Void = {}

    @State private var showModal = false
    @State private var showResultAlert = false
    @State private var isCorrectChoice = false

    var body: some View {
        ZStack {
            feed

            // Glassmorphism decision overlay
            if showModal {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .transition(.opacity)

                decisionModal
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .alert(
            isCorrectChoice
                ? tr("Correct Choice!", "اختيار صحيح!")
                : tr("Incorrect Choice!", "اختيار خاطئ!"),
            isPresented: $showResultAlert
        ) {
            if isCorrectChoice {
                Button(tr("Continue", "متابعة")) {
                    onPassed()
                }
            } else {
                Button(tr("Redo", "إعادة"), role: .cancel) { }
            }
        } message: {
            Text(
                isCorrectChoice
                ? tr("Exactly right. \u{201C}Guaranteed\u{201D} and \u{201C}risk-free\u{201D} returns don't exist — every real investment carries risk, and licensed firms never advertise like this. Reporting protects others too.",
                     "صحيح تماماً. العوائد \u{201C}المضمونة\u{201D} و\u{201C}بدون مخاطرة\u{201D} غير موجودة — كل استثمار حقيقي فيه مخاطرة، والشركات المرخصة لا تعلن بهذه الطريقة. الإبلاغ يحمي الآخرين أيضاً.")
                : tr("You almost handed your bank account to fraudsters. No one can guarantee 20,000 SAR in 48 hours — that promise is the scam itself. Try again.",
                     "كدت تسلّم حسابك البنكي للمحتالين. لا أحد يستطيع ضمان 20,000 ريال خلال 48 ساعة — ذلك الوعد هو الاحتيال بعينه. حاول مرة أخرى.")
            )
        }
    }

    // MARK: - Mock social feed

    private var feed: some View {
        VStack(spacing: 0) {
            // App bar
            HStack {
                Text("Snapgram")
                    .font(.title2.weight(.bold))
                    .italic()
                Spacer()
                Image(systemName: "heart")
                Image(systemName: "paperplane")
                    .padding(.leading, 14)
            }
            .font(.title3)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.bar)

            ScrollView {
                VStack(spacing: 18) {
                    feedPost(name: tr("Faisal", "فيصل"),
                             caption: tr("Golden hour at the corniche 🌅", "الغروب على الكورنيش 🌅"),
                             colors: [.orange, .pink],
                             icon: "sun.horizon.fill",
                             likes: "1,204")

                    sponsoredAd

                    feedPost(name: tr("Noura", "نورة"),
                             caption: tr("Best kabsa I've ever made 🍛", "أفضل كبسة سويتها 🍛"),
                             colors: [.teal, .blue],
                             icon: "fork.knife",
                             likes: "873")
                }
                .padding(.vertical, 14)
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private func feedPost(name: String, caption: String, colors: [Color], icon: String, likes: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Circle()
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 34, height: 34)
                Text(name)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            // Placeholder "photo"
            LinearGradient(colors: colors.map { $0.opacity(0.55) },
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 190)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 44))
                        .foregroundColor(.white.opacity(0.8))
                )

            HStack(spacing: 14) {
                Image(systemName: "heart")
                Image(systemName: "bubble.right")
                Image(systemName: "paperplane")
                Spacer()
            }
            .font(.title3)
            .padding(.horizontal, 14)
            .padding(.top, 10)

            Text(tr("\(likes) likes", "\(likes) إعجاب"))
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.top, 6)

            Text(caption)
                .font(.footnote)
                .padding(.horizontal, 14)
                .padding(.top, 2)
                .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
    }

    private var sponsoredAd: some View {
        Button {
            withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                showModal = true
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(LinearGradient(colors: [.yellow, .green],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 34, height: 34)
                        .overlay(
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                    VStack(alignment: .leading, spacing: 1) {
                        Text(verbatim: "GulfWealth_Official")
                            .font(.subheadline.weight(.semibold))
                        Text(tr("Sponsored", "إعلان ممول"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

                // Flashy ad body
                VStack(spacing: 8) {
                    Text("💰💰💰")
                        .font(.title)
                    Text(tr("Guaranteed 20,000 SAR returns in 48 hours!", "عوائد مضمونة 20,000 ريال خلال 48 ساعة!"))
                        .font(.headline.weight(.black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text(tr("100% risk-free. Register your bank account now.", "بدون أي مخاطرة 100٪. سجّل حسابك البنكي الآن."))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)

                    Text(tr("REGISTER NOW", "سجّل الآن"))
                        .font(.footnote.weight(.bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(Color.white))
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 26)
                .padding(.horizontal, 16)
                .background(
                    LinearGradient(colors: [Color.green, Color(red: 0.05, green: 0.45, blue: 0.25)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )

                Text(tr("Learn more", "اعرف المزيد"))
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
            }
            .background(Color(.systemBackground))
        }
        .buttonStyle(PressableCardStyle())
    }

    // MARK: - Decision modal

    private var decisionModal: some View {
        VStack(spacing: 18) {
            Text(tr("Exclusive Opportunity", "فرصة حصرية"))
                .font(.headline)

            Text(tr("GulfWealth wants to link your bank account to start your \u{201C}guaranteed\u{201D} 48-hour investment. What do you do?",
                    "تريد GulfWealth ربط حسابك البنكي لبدء استثمارك \u{201C}المضمون\u{201D} خلال 48 ساعة. ماذا ستفعل؟"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                // The bait
                Button {
                    isCorrectChoice = false
                    onMistake()
                    showResultAlert = true
                } label: {
                    Text(tr("Link Bank Account", "ربط الحساب البنكي"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.green)
                        )
                }

                // The safe move
                Button {
                    isCorrectChoice = true
                    showResultAlert = true
                } label: {
                    Text(tr("Report as Fake Advertisement", "الإبلاغ عن إعلان مزيف"))
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.secondary.opacity(0.45), lineWidth: 1)
                        )
                }
            }
        }
        .padding(24)
        .frame(maxWidth: 330)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 22, y: 10)
        .padding(.horizontal, 24)
    }
}
