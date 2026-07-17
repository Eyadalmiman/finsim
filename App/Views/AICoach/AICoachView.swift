import SwiftUI

struct AICoachView: View {
    /// When set, the coach is scoped to a Library subject: the greeting,
    /// header, and Gemini context all reference it.
    let contextSubject: LibrarySubject?

    @ObservedObject private var network = NetworkMonitor.shared

    @State private var messages: [AIChatMessage]
    @State private var draft = ""
    @State private var isThinking = false
    @State private var isTyping = false
    @FocusState private var inputFocused: Bool

    init(contextSubject: LibrarySubject? = nil) {
        self.contextSubject = contextSubject
        let greeting: String
        if let subject = contextSubject {
            greeting = tr("You're reading \"\(subject.title)\" — ask me anything about it and I'll explain!",
                          "أنت تقرأ \"\(subject.title)\" — اسألني أي شيء عنه وسأشرح لك!")
        } else {
            greeting = tr("Salam! I'm your AI Money Coach. Ask me anything about money — budgeting, saving, investing, Zakat — or about how to use FinSim.",
                          "السلام عليكم! أنا مدربك المالي الذكي. اسألني أي شيء عن المال — الميزانية، الادخار، الاستثمار، الزكاة — أو عن كيفية استخدام FinSim.")
        }
        _messages = State(initialValue: [AIChatMessage(role: .model, text: greeting)])
    }

    /// The subject's full text, handed to Gemini so answers stay on-topic.
    private var subjectContext: String? {
        guard let subject = contextSubject else { return nil }
        let sections = subject.sections
            .map { "\($0.title): \($0.body)" }
            .joined(separator: "\n")
        return """
        The user is currently reading the Library subject "\(subject.title)" (\(subject.summary)). \
        Its full content follows — answer with this subject in mind:
        \(sections)
        """
    }

    var body: some View {
        VStack(spacing: 0) {
            if !network.isConnected {
                offlineLockView
            } else if GeminiService.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                missingKeyView
            } else {
                chatView
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }

    // MARK: - Chat

    private var chatView: some View {
        VStack(spacing: 0) {
            header

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            bubble(for: message)
                                .id(message.id)
                        }

                        if isThinking {
                            AIThinkingIndicator()
                                .id("thinking")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages) {
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .onChange(of: isThinking) {
                    if isThinking {
                        withAnimation { proxy.scrollTo("thinking", anchor: .bottom) }
                    }
                }
            }

            inputBar
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image("AILogo")
                .resizable()
                .scaledToFill()
                .frame(width: 38, height: 38)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))

            VStack(alignment: .leading, spacing: 1) {
                Text(tr("AI Money Coach", "المدرب المالي الذكي"))
                    .font(.headline)
                    .foregroundColor(.white)
                Text(contextSubject.map { tr("Asking about \"\($0.title)\"", "تسأل عن \"\($0.title)\"") }
                     ?? tr("Powered by Gemini • Educational, not financial advice", "مدعوم من Gemini • تعليمي، وليس نصيحة مالية"))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.finSimGreen)
    }

    @ViewBuilder
    private func bubble(for message: AIChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .user {
                Spacer(minLength: 40)
            } else {
                AICoachAvatar(size: 28)
            }

            Text(message.text)
                .font(.body)
                .foregroundColor(message.role == .user ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(message.role == .user
                              ? Color.finSimGreen
                              : Color(.secondarySystemGroupedBackground))
                )

            if message.role == .model { Spacer(minLength: 40) }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField(tr("Ask about money…", "اسأل عن المال…"), text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .focused($inputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                .onSubmit(send)

            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(canSend ? .finSimGreen : .gray.opacity(0.5))
            }
            .disabled(!canSend)
            .accessibilityLabel("Send")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isThinking && !isTyping
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isThinking, !isTyping else { return }

        draft = ""
        messages.append(AIChatMessage(role: .user, text: text))
        isThinking = true

        let conversation = messages

        Task {
            let answer: String
            do {
                answer = try await GeminiService.reply(to: conversation, extraContext: subjectContext)
            } catch {
                answer = tr("Sorry, something went wrong: \(error.localizedDescription)", "عذراً، حدث خطأ ما: \(error.localizedDescription)")
            }

            withAnimation(.snappy) { isThinking = false }
            await typeOut(answer)
        }
    }

    /// Reveals the reply word by word, like an LLM streaming its answer.
    @MainActor
    private func typeOut(_ full: String) async {
        isTyping = true
        defer { isTyping = false }

        messages.append(AIChatMessage(role: .model, text: ""))
        let index = messages.count - 1

        // Split on spaces while keeping newlines attached to their words,
        // so paragraph breaks survive the reveal.
        let words = full.split(separator: " ", omittingEmptySubsequences: false)
        var revealed = ""

        for (i, word) in words.enumerated() {
            revealed += (i == 0 ? "" : " ") + word
            messages[index].text = revealed + " ▍"
            // Small random jitter makes the pace feel like live generation.
            try? await Task.sleep(nanoseconds: UInt64.random(in: 30_000_000...90_000_000))
        }

        messages[index].text = full
    }

    // MARK: - Locked states

    private var offlineLockView: some View {
        lockedState(
            icon: "wifi.slash",
            title: tr("You're Offline", "لا يوجد اتصال بالإنترنت"),
            message: tr("The AI Money Coach needs an internet connection. Reconnect to continue chatting — the rest of FinSim still works offline.",
                        "يحتاج المدرب المالي الذكي إلى اتصال بالإنترنت. أعد الاتصال لمتابعة المحادثة — بقية تطبيق FinSim يعمل دون إنترنت.")
        )
    }

    private var missingKeyView: some View {
        lockedState(
            icon: "key.fill",
            title: tr("Coach Not Set Up Yet", "المدرب غير مهيأ بعد"),
            message: tr("The AI Money Coach isn't configured yet. Please check back later.", "لم يتم تهيئة المدرب المالي الذكي بعد. يرجى العودة لاحقاً.")
        )
    }

    private func lockedState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 0) {
            header

            Spacer()

            VStack(spacing: 14) {
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 44))
                        .foregroundColor(.finSimGreen)
                        .frame(width: 96, height: 96)
                        .background(Circle().fill(Color.finSimGreen.opacity(0.12)))

                    Image(systemName: "lock.fill")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color.finSimGreen))
                }

                Text(title)
                    .font(.title3.weight(.bold))

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - AI Avatar

/// The app logo used as the coach's face in chat.
struct AICoachAvatar: View {
    var size: CGFloat = 28

    var body: some View {
        Image("AILogo")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

// MARK: - Thinking Indicator

/// Shown while waiting for Gemini: the logo gently pulses, three dots ripple,
/// and a status line cycles through "research" steps so it feels like the
/// coach is digging through sources for the answer.
struct AIThinkingIndicator: View {
    private static var phrases: [String] {
        [
            tr("Thinking", "أفكر"),
            tr("Searching the library", "أبحث في المكتبة"),
            tr("Scanning trusted sources", "أتصفح مصادر موثوقة"),
            tr("Checking the numbers", "أتحقق من الأرقام"),
            tr("Writing your answer", "أكتب إجابتك")
        ]
    }

    @State private var animating = false
    @State private var phraseIndex = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            AICoachAvatar(size: 28)
                .scaleEffect(animating ? 1.12 : 0.94)
                .animation(
                    .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                    value: animating
                )

            HStack(spacing: 10) {
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.finSimGreen)
                            .frame(width: 8, height: 8)
                            .offset(y: animating ? -4 : 2)
                            .opacity(animating ? 1 : 0.35)
                            .animation(
                                .easeInOut(duration: 0.55)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.18),
                                value: animating
                            )
                    }
                }

                Text(Self.phrases[phraseIndex] + "…")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .id(phraseIndex)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

            Spacer(minLength: 40)
        }
        .onAppear { animating = true }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_700_000_000)
                withAnimation(.easeInOut(duration: 0.35)) {
                    phraseIndex = (phraseIndex + 1) % Self.phrases.count
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}
