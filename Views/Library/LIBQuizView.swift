import SwiftUI

/// Three-question knowledge check at the end of a library subject. Passing
/// (at least 2 of 3) marks the subject as completed and counts toward the
/// Scholar badge. Answers show right/wrong immediately with the correct
/// option highlighted, so a wrong pick still teaches.
struct LIBQuizView: View {
    let subject: LibrarySubject
    var onPassed: () -> Void = {}

    @Environment(\.dismiss) private var dismiss

    @State private var questionIndex = 0
    @State private var chosenIndex: Int?
    @State private var correctCount = 0
    @State private var finished = false

    private var questions: [QuizQuestion] { subject.quiz }
    private var passThreshold: Int { max(1, questions.count - 1) }
    private var passed: Bool { correctCount >= passThreshold }

    var body: some View {
        ZStack {
            GreenPatternBackground()

            VStack(spacing: 0) {
                header

                if finished {
                    resultBody
                } else if questions.isEmpty {
                    // No quiz authored — never block the subject on it.
                    Color.clear.onAppear {
                        onPassed()
                        dismiss()
                    }
                } else {
                    questionBody
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.15)))
            }
            .accessibilityLabel("Close")

            Spacer()

            VStack(spacing: 1) {
                Text(tr("Quiz", "اختبار"))
                    .font(.headline)
                    .foregroundColor(.white)
                Text(subject.title)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(1)
            }

            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Question

    private var questionBody: some View {
        let question = questions[questionIndex]

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(tr("Question \(questionIndex + 1) of \(questions.count)",
                        "السؤال \(questionIndex + 1) من \(questions.count)"))
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.finSimLightGreen)

                Text(question.text)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 10) {
                    ForEach(question.options.indices, id: \.self) { index in
                        optionButton(question, index: index)
                    }
                }

                if chosenIndex != nil {
                    Button {
                        advance()
                    } label: {
                        Text(questionIndex + 1 < questions.count
                             ? tr("Next", "التالي")
                             : tr("See result", "عرض النتيجة"))
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 6)
                }
            }
            .padding(20)
        }
    }

    private func optionButton(_ question: QuizQuestion, index: Int) -> some View {
        let isCorrect = index == question.correctIndex
        let isChosen = index == chosenIndex
        let revealed = chosenIndex != nil

        return Button {
            guard chosenIndex == nil else { return }
            withAnimation(.snappy) {
                chosenIndex = index
                if isCorrect { correctCount += 1 }
            }
        } label: {
            HStack(spacing: 10) {
                Text(question.options[index])
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                if revealed, isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if revealed, isChosen {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.dangerRed)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(revealed && isCorrect ? 0.22 : (revealed && isChosen ? 0.16 : 0.10)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        revealed && isCorrect ? Color.green
                        : revealed && isChosen ? Color.dangerRed
                        : Color.white.opacity(0.18),
                        lineWidth: revealed && (isCorrect || isChosen) ? 2 : 1
                    )
            )
        }
        .buttonStyle(PressableCardStyle())
        .disabled(revealed)
    }

    private func advance() {
        withAnimation(.snappy) {
            if questionIndex + 1 < questions.count {
                questionIndex += 1
                chosenIndex = nil
            } else {
                finished = true
                if passed { onPassed() }
            }
        }
    }

    // MARK: - Result

    private var resultBody: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: passed ? "checkmark.seal.fill" : "arrow.counterclockwise.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white, passed ? .green : .orange)
                .shadow(color: (passed ? Color.green : .orange).opacity(0.5), radius: 12)

            Text(passed ? tr("Subject completed!", "!أكملت الموضوع") : tr("Almost there!", "!اقتربت"))
                .font(.title2.weight(.bold))
                .foregroundColor(.white)

            Text(tr("You got \(correctCount) of \(questions.count) right.",
                    "أجبت بشكل صحيح على \(correctCount) من \(questions.count)."))
                .font(.body)
                .foregroundColor(.white.opacity(0.85))

            if passed {
                Text(tr("This subject now counts toward your Scholar badge.",
                        "يُحسب هذا الموضوع الآن ضمن شارة القارئ."))
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            } else {
                Text(tr("You need \(passThreshold) correct to complete the subject. Skim the article and try again.",
                        "تحتاج \(passThreshold) إجابات صحيحة لإكمال الموضوع. راجع المقال وحاول مرة أخرى."))
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }

            Spacer()

            VStack(spacing: 10) {
                if !passed {
                    Button {
                        withAnimation(.snappy) {
                            questionIndex = 0
                            chosenIndex = nil
                            correctCount = 0
                            finished = false
                        }
                    } label: {
                        Text(tr("Try again", "حاول مرة أخرى"))
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }

                Button {
                    dismiss()
                } label: {
                    Text(passed ? tr("Done", "تم") : tr("Back to the article", "العودة إلى المقال"))
                        .font(.body.weight(passed ? .semibold : .regular))
                        .foregroundColor(.white.opacity(passed ? 1 : 0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(passed ? 0.2 : 0.1))
                        )
                }
                .buttonStyle(PressableCardStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 20)
    }
}
