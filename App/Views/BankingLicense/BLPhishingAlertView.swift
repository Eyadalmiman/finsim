import SwiftUI

/// The OTP phishing trap: a fake "bank" SMS banner drops from the top while a
/// frosted-glass prompt in the center pressures the user to hand over the OTP.
/// Overlaid on the bank dashboard, which stays dimmed underneath.
struct BLPhishingAlertView: View {
    /// Called every time the user falls for the trap (enters the OTP).
    var onMistake: () -> Void = {}
    /// Called once the user makes the correct choice and taps Continue.
    var onPassed: () -> Void = {}

    @State private var showBanner = false
    @State private var showModal = false
    @State private var showResultAlert = false
    @State private var isCorrectChoice = false

    var body: some View {
        ZStack {
            // Dim the dashboard underneath
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            // Fake SMS push-notification banner
            VStack {
                if showBanner {
                    smsBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }

            // Glassmorphism action modal
            if showModal {
                actionModal
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.55, bounce: 0.25)) {
                showBanner = true
            }
            Task {
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                    showModal = true
                }
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
                ? tr("Exactly right. Banks and SAMA never ask for your OTP — ignoring and reporting is what keeps your money safe.",
                     "صحيح تماماً. البنوك وساما لا يطلبون رمز التحقق أبداً — التجاهل والإبلاغ هو ما يحمي أموالك.")
                : tr("You just gave a scammer full access to your account. A real bank or SAMA will NEVER ask for your OTP — that message was social engineering. Try again.",
                     "لقد منحت المحتال للتو وصولاً كاملاً إلى حسابك. البنك الحقيقي أو ساما لن يطلبا رمز التحقق أبداً — كانت تلك الرسالة هندسة اجتماعية. حاول مرة أخرى.")
            )
        }
    }

    // MARK: - Fake SMS banner

    private var smsBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.orange)
                )

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Bank_Alert")
                        .font(.footnote.weight(.semibold))
                    Spacer()
                    Text(tr("now", "الآن"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Text(tr("URGENT: Your account has been temporarily frozen due to unverified Nafath data. To avoid suspension, verify your OTP immediately: 8492. Do not share this code.",
                        "عاجل: تم تجميد حسابك مؤقتاً بسبب بيانات نفاذ غير موثقة. لتجنب الإيقاف، أكد رمز التحقق فوراً: 8492. لا تشارك هذا الرمز."))
                    .font(.footnote)
                    .foregroundColor(.primary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.25), radius: 14, y: 6)
        .padding(.horizontal, 10)
        .padding(.top, 6)
    }

    // MARK: - Glass action modal

    private var actionModal: some View {
        VStack(spacing: 18) {
            Text(tr("Incoming Request", "طلب وارد"))
                .font(.headline)
                .foregroundColor(.primary)

            Text(tr("A system prompt is asking for the OTP you just received. How do you proceed?",
                    "نافذة نظام تطلب رمز التحقق الذي استلمته للتو. كيف ستتصرف؟"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                // The bait: styled as the obvious primary action
                Button {
                    isCorrectChoice = false
                    onMistake()
                    showResultAlert = true
                } label: {
                    Text(tr("Enter OTP (8492)", "أدخل الرمز (8492)"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.ctaBlue)
                        )
                }

                // The safe choice, deliberately understated
                Button {
                    isCorrectChoice = true
                    showResultAlert = true
                } label: {
                    Text(tr("Ignore & Report scam", "تجاهل وبلّغ عن احتيال"))
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
