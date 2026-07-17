import SwiftUI
import SwiftData

struct LIBTableOfContentsView: View {
    /// When shown as a quick-jump sheet the trailing button just closes the
    /// sheet and rows report the chosen subject back instead of pushing.
    var presentedAsSheet: Bool = false
    var onSelect: ((LibrarySubject) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.exitExperience) private var exitExperience
    @Query private var users: [User]
    @AppStorage("currentUserEmail") private var currentUserEmail = ""
    @State private var searchText = ""

    private var readIDs: Set<String> {
        let user = users.current(email: currentUserEmail)
        return Set(user?.readSubjectIDs ?? [])
    }

    /// One pass over the catalog: each category paired with the subjects
    /// matching the current search, with empty categories dropped.
    private var visibleSections: [(category: String, subjects: [LibrarySubject])] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        return Library.categories.compactMap { category in
            var subjects = Library.subjects(in: category)
            if !query.isEmpty {
                subjects = subjects.filter { subject in
                    subject.title.localizedCaseInsensitiveContains(query)
                        || subject.summary.localizedCaseInsensitiveContains(query)
                        || subject.sections.contains { $0.title.localizedCaseInsensitiveContains(query) }
                }
            }
            return subjects.isEmpty ? nil : (category, subjects)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                Text(tr("Table of contents", "جدول المحتويات"))
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    if presentedAsSheet {
                        dismiss()
                    } else {
                        exitExperience()
                    }
                } label: {
                    Image(systemName: presentedAsSheet ? "xmark" : "rectangle.portrait.and.arrow.right")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 40, height: 40)
                }
                .accessibilityLabel(presentedAsSheet ? "Close" : "Exit experience")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.black)

            // Search Bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))

                TextField(tr("Search subjects", "ابحث في المواضيع"), text: $searchText)
                    .foregroundColor(.white)
                    .tint(.finSimLightGreen)
                    .autocorrectionDisabled()
                    .submitLabel(.search)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 4)

            // Subject List
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    let sections = visibleSections
                    let read = readIDs
                    if sections.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "text.magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.3))
                            Text(tr("No subjects match \"\(searchText)\"", "لا توجد مواضيع تطابق \"\(searchText)\""))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.55))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        ForEach(sections, id: \.category) { section in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(section.category.uppercased())
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.finSimLightGreen)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 1) {
                                    ForEach(section.subjects) { subject in
                                        subjectRow(subject, isRead: read.contains(subject.id))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func subjectRow(_ subject: LibrarySubject, isRead: Bool) -> some View {
        if presentedAsSheet {
            Button {
                onSelect?(subject)
                dismiss()
            } label: {
                subjectRowLabel(subject, isRead: isRead)
            }
            .buttonStyle(PressableCardStyle())
        } else {
            NavigationLink(destination: LIBContentView(subject: subject)) {
                subjectRowLabel(subject, isRead: isRead)
            }
            .buttonStyle(PressableCardStyle())
        }
    }

    private func subjectRowLabel(_ subject: LibrarySubject, isRead: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: subject.icon)
                .font(.body.weight(.medium))
                .foregroundColor(.finSimLightGreen)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Color.white.opacity(0.08)))

            VStack(alignment: .leading, spacing: 2) {
                Text(subject.title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                Text(subject.summary)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.55))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            // Read indicator — feeds the Scholar badge on the Account page.
            if isRead {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body)
                    .foregroundColor(.finSimLightGreen)
            }

            Image(systemName: "chevron.forward")
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.35))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
