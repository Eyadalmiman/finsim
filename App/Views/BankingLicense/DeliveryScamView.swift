import SwiftUI

/// Challenge B: a fake "delivery fee" SMS. The thread looks like the native
/// Messages app; tapping the link opens a fake in-app Safari payment page.
struct DeliveryScamView: View {
    var onMistake: () -> Void = {}
    var onPassed: () -> Void = {}

    @State private var showBrowser = false

    var body: some View {
        VStack(spacing: 0) {
            // Messages-style header
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.gray, Color(.systemGray2)],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: 50, height: 50)
                    Text("SPL")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.white)
                }

                Text("SPL-Aramex")
                    .font(.footnote)
                Image(systemName: "chevron.forward")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(.bar)

            // Thread
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(tr("Text Message • Today", "رسالة نصية • اليوم"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)

                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(tr("Your package cannot be delivered due to an outstanding fee of 7.50 SAR. Click here to pay:",
                                    "لا يمكن توصيل شحنتك بسبب رسوم غير مدفوعة بقيمة 7.50 ريال. اضغط هنا للدفع:"))

                            Button {
                                showBrowser = true
                            } label: {
                                Text(verbatim: "spl-delivery-secure.com")
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                        }
                        .font(.body)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(.systemGray5))
                        )
                        .frame(maxWidth: 300, alignment: .leading)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .background(Color(.systemBackground))

            // Decorative input bar
            HStack(spacing: 10) {
                Image(systemName: "camera.fill")
                    .foregroundColor(.secondary)
                Text(tr("Text Message", "رسالة نصية"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().stroke(Color.secondary.opacity(0.4), lineWidth: 1))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.bar)
        }
        .fullScreenCover(isPresented: $showBrowser) {
            FakePaymentBrowserView(
                onMistake: onMistake,
                onPassed: {
                    showBrowser = false
                    // Let the cover dismiss before the flow advances.
                    Task {
                        try? await Task.sleep(nanoseconds: 350_000_000)
                        onPassed()
                    }
                }
            )
        }
    }
}

// MARK: - Fake Safari payment page

private struct FakePaymentBrowserView: View {
    var onMistake: () -> Void
    var onPassed: () -> Void

    @State private var showResultAlert = false
    @State private var isCorrectChoice = false

    var body: some View {
        VStack(spacing: 0) {
            // Address bar
            HStack(spacing: 10) {
                Text("AA")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Text(verbatim: "spl-delivery-secure.com")
                        .font(.footnote)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color(.systemGray5)))

                Image(systemName: "arrow.clockwise")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.bar)

            // Fake payment gateway
            ScrollView {
                VStack(spacing: 18) {
                    Text(tr("Not Secure — this site pressures you to pay immediately", "غير آمن — هذا الموقع يضغط عليك للدفع فوراً"))
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.top, 10)

                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                        .frame(width: 84, height: 84)
                        .background(Circle().fill(Color.orange))
                        .padding(.top, 6)

                    Text(tr("Customs Fee Payment", "دفع الرسوم الجمركية"))
                        .font(.title2.weight(.bold))

                    Text(tr("Your shipment #SA-88214 is on hold. Pay 7.50 SAR now to release it. This offer expires in 10 minutes!",
                            "شحنتك رقم SA-88214 محتجزة. ادفع 7.50 ريال الآن للإفراج عنها. ينتهي العرض خلال 10 دقائق!"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    // Decorative card form
                    VStack(spacing: 10) {
                        fakeField(tr("Card Number", "رقم البطاقة"))
                        HStack(spacing: 10) {
                            fakeField(tr("MM/YY", "الشهر/السنة"))
                            fakeField("CVV")
                        }
                    }
                    .padding(.horizontal, 24)

                    VStack(spacing: 10) {
                        // The bait
                        Button {
                            isCorrectChoice = false
                            onMistake()
                            showResultAlert = true
                        } label: {
                            Text(tr("Enter Card Details", "إدخال بيانات البطاقة"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.orange)
                                )
                        }

                        // The safe exit
                        Button {
                            isCorrectChoice = true
                            showResultAlert = true
                        } label: {
                            Text(tr("Close Page & Verify on Official App", "إغلاق الصفحة والتحقق من التطبيق الرسمي"))
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.secondary.opacity(0.45), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 6)
                    .padding(.bottom, 30)
                }
            }

            // Safari toolbar
            HStack {
                Image(systemName: "chevron.backward")
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundColor(.secondary.opacity(0.4))
                Spacer()
                Image(systemName: "square.and.arrow.up")
                Spacer()
                Image(systemName: "book")
                Spacer()
                Image(systemName: "square.on.square")
            }
            .font(.title3)
            .foregroundColor(.blue)
            .padding(.horizontal, 26)
            .padding(.vertical, 10)
            .background(.bar)
        }
        .background(Color(.systemBackground))
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
                ? tr("Exactly right. Real couriers never charge fees through random links — when in doubt, check the shipment in the courier's official app or website.",
                     "صحيح تماماً. شركات الشحن الحقيقية لا تحصّل رسوماً عبر روابط عشوائية — عند الشك، تحقق من الشحنة في تطبيق الشركة الرسمي أو موقعها.")
                : tr("That page was a fake — the misspelled link and the 10-minute countdown are classic pressure tactics. Entering your card here hands it to scammers. Try again.",
                     "كانت تلك الصفحة مزيفة — الرابط الغريب والعد التنازلي لعشر دقائق من أساليب الضغط المعروفة. إدخال بطاقتك هنا يسلّمها للمحتالين. حاول مرة أخرى.")
            )
        }
    }

    private func fakeField(_ placeholder: String) -> some View {
        Text(placeholder)
            .font(.subheadline)
            .foregroundColor(.secondary.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
    }
}
