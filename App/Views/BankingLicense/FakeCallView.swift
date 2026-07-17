import SwiftUI

/// Challenge C: a fake incoming call from "Bank Customer Service" that mimics
/// the native iOS call screen. Accepting plays a social-engineering script;
/// the safe moves are declining, or hanging up and calling the bank yourself.
struct FakeCallView: View {
    var onMistake: () -> Void = {}
    var onPassed: () -> Void = {}

    @State private var accepted = false
    @State private var acceptedAt = Date()
    @State private var pulsing = false
    @State private var showResultAlert = false
    @State private var isCorrectChoice = false

    var body: some View {
        ZStack {
            // Dark call-screen backdrop
            LinearGradient(
                colors: [Color(red: 0.09, green: 0.10, blue: 0.14), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if accepted {
                activeCall
            } else {
                incomingCall
            }
        }
        .onAppear { pulsing = true }
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
                ? tr("Exactly right. Banks never call asking for codes. If a call feels off, hang up and dial the number on the back of your card yourself.",
                     "صحيح تماماً. البنوك لا تتصل لطلب الرموز أبداً. إذا بدت المكالمة مريبة، أغلق الخط واتصل بنفسك بالرقم المدوّن خلف بطاقتك.")
                : tr("You just read your code to a scammer — that code was the last step they needed to take over your account. A real bank agent will NEVER ask for it. Try again.",
                     "لقد قرأت رمزك للتو لمحتال — كان ذلك الرمز آخر ما يحتاجه للسيطرة على حسابك. موظف البنك الحقيقي لن يطلبه أبداً. حاول مرة أخرى.")
            )
        }
    }

    // MARK: - Incoming call screen

    private var incomingCall: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 70)

            Text("Bank Customer Service")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Text(tr("mobile", "الجوال"))
                .font(.title3)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 4)

            Spacer()

            HStack {
                // Decline — also a safe move
                VStack(spacing: 10) {
                    Button {
                        isCorrectChoice = true
                        showResultAlert = true
                    } label: {
                        Image(systemName: "phone.down.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 74, height: 74)
                            .background(Circle().fill(Color.red))
                    }
                    Text(tr("Decline", "رفض"))
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)

                // Accept — pulses like the real thing
                VStack(spacing: 10) {
                    Button {
                        acceptedAt = Date()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            accepted = true
                        }
                    } label: {
                        Image(systemName: "phone.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 74, height: 74)
                            .background(Circle().fill(Color.green))
                            .scaleEffect(pulsing ? 1.1 : 0.95)
                            .animation(
                                .easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                                value: pulsing
                            )
                    }
                    Text(tr("Accept", "قبول"))
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }

    // MARK: - Active call screen

    private var activeCall: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 50)

            Text("Bank Customer Service")
                .font(.title.weight(.semibold))
                .foregroundColor(.white)

            // Live call timer
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let seconds = max(0, Int(context.date.timeIntervalSince(acceptedAt)))
                Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.6))
                    .monospacedDigit()
                    .padding(.top, 4)
            }

            // "Audio" transcript
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "waveform")
                        .foregroundColor(.green)
                    Text(tr("Caller is speaking…", "المتصل يتحدث…"))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                Text(tr("\u{201C}To reactivate your frozen card, please read aloud the 4-digit code sent to your phone right now.\u{201D}",
                        "\u{201C}لإعادة تفعيل بطاقتك المجمدة، يرجى قراءة الرمز المكون من 4 أرقام الذي وصل إلى جوالك الآن بصوت عالٍ.\u{201D}"))
                    .font(.body)
                    .foregroundColor(.white)
                    .lineSpacing(4)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassmorphic()
            .padding(.horizontal, 24)
            .padding(.top, 30)

            // Decorative call controls
            HStack(spacing: 34) {
                callControl("mic.slash.fill", tr("mute", "كتم"))
                callControl("circle.grid.3x3.fill", tr("keypad", "لوحة"))
                callControl("speaker.wave.3.fill", tr("speaker", "مكبر"))
            }
            .padding(.top, 34)

            Spacer()

            VStack(spacing: 12) {
                // The bait
                Button {
                    isCorrectChoice = false
                    onMistake()
                    showResultAlert = true
                } label: {
                    Text(tr("Provide Code", "إعطاء الرمز"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.ctaBlue)
                        )
                }

                // The safe move
                Button {
                    isCorrectChoice = true
                    showResultAlert = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.down.fill")
                        Text(tr("Hang Up & Call Bank Directly", "إغلاق الخط والاتصال بالبنك مباشرة"))
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.red)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func callControl(_ icon: String, _ label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 58, height: 58)
                .background(Circle().fill(Color.white.opacity(0.15)))
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}
