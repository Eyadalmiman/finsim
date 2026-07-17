import SwiftUI
import SwiftData

struct LIBContentView: View {
    @State var subject: LibrarySubject
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @AppStorage("currentUserEmail") private var currentUserEmail = ""
    @State private var showTOC = false
    @State private var showAICoach = false
    @State private var showQuiz = false

    private var user: User? {
        users.current(email: currentUserEmail)
    }

    private var isCompleted: Bool {
        user?.readSubjectIDs.contains(subject.id) ?? false
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.15))
                        )
                }
                .accessibilityLabel("Back")

                Spacer()

                Text(subject.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                Button {
                    showTOC = true
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.15))
                        )
                }
                .accessibilityLabel("Table of contents")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title block
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: subject.icon)
                            .font(.title)
                            .foregroundColor(.finSimLightGreen)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color.white.opacity(0.08)))

                        Text(subject.title)
                            .font(.title.weight(.bold))
                            .foregroundColor(.white)

                        Text(subject.summary)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.bottom, 4)

                    // Sections
                    ForEach(subject.sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title)
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.finSimLightGreen)

                            Text(section.body)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    // End of subject: the quiz is what completes it and
                    // counts toward the Scholar badge — not just scrolling.
                    VStack(spacing: 10) {
                        if isCompleted {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.finSimLightGreen)
                                Text(tr("Subject completed — quiz passed", "أكملت الموضوع — اجتزت الاختبار"))
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.55))
                                Spacer()
                            }
                        } else {
                            Text(tr("Finished reading? Prove it.", "أنهيت القراءة؟ أثبت ذلك."))
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.55))

                            Button {
                                showQuiz = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.seal")
                                    Text(tr("Take the quiz", "ابدأ الاختبار"))
                                }
                                .font(.body.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.finSimGreen)
                                )
                            }
                            .buttonStyle(PressableCardStyle())
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .overlay(alignment: .bottomTrailing) {
            // Ask-the-AI button for the subject being read
            Button {
                showAICoach = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image("AILogo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .frame(width: 58, height: 58)
                        .glassEffect(
                            .regular.tint(.finSimGreen.opacity(0.45)).interactive(),
                            in: Circle()
                        )
                        .shadow(color: .black.opacity(0.35), radius: 8, y: 3)

                    Image(systemName: "questionmark")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.finSimGreen)
                        .frame(width: 18, height: 18)
                        .background(Circle().fill(Color.white))
                }
            }
            .buttonStyle(PressableCardStyle())
            .accessibilityLabel("Ask the AI about \(subject.title)")
            .padding(.trailing, 20)
            .padding(.bottom, 24)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showTOC) {
            LIBTableOfContentsView(presentedAsSheet: true) { picked in
                subject = picked
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showAICoach) {
            AICoachView(contextSubject: subject)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showQuiz) {
            LIBQuizView(subject: subject, onPassed: markSubjectRead)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    /// Persists that the user passed this subject's quiz.
    private func markSubjectRead() {
        guard let user, !user.readSubjectIDs.contains(subject.id) else { return }
        user.markSubjectRead(subject.id)
        try? modelContext.save()
    }
}
