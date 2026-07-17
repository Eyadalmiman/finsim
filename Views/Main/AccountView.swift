import SwiftUI
import SwiftData

struct AccountView: View {
    @Query private var users: [User]
    @AppStorage("currentUserEmail") private var currentUserEmail = ""

    private var user: User? {
        users.current(email: currentUserEmail)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Banner
                PageHeaderBanner(icon: "person.circle", title: tr("Account", "الحساب"))

                // Profile Image
                VStack(spacing: 12) {
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .foregroundColor(.gray.opacity(0.5))
                            .background(
                                Circle()
                                    .fill(Color(.systemBackground))
                            )
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.finSimGreen, lineWidth: 3)
                            )

                        // Verified badge
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .foregroundColor(.finSimGreen)
                            .background(
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .frame(width: 22, height: 22)
                            )
                            .offset(x: -5, y: -5)
                    }

                    Text(user?.name ?? "Eyad Ali Abdulrahman Almiman")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 10)

                // Identity Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: tr("Identity", "الهوية"))
                        .padding(.horizontal, 16)
                        .padding(.top, 14)

                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 10) {
                        identityRow(label: tr("Name", "الاسم"), value: user?.name ?? "Eyad Ali Abdulrahman Almiman")
                        identityRow(label: tr("ID number", "رقم الهوية"), value: user?.maskedID ?? "115*****89")
                        identityRow(label: tr("Date of birth", "تاريخ الميلاد"), value: user?.formattedDOB ?? "22 Nov 2010")
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .liquidGlass(cornerRadius: 16, tint: .finSimGreen, interactive: false)

                // Progress and Completion Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: tr("Progress and completion", "التقدم والإنجاز"))
                        .padding(.horizontal, 16)
                        .padding(.top, 14)

                    // Banking License Progress
                    HStack {
                        Text(tr("Banking License", "الرخصة البنكية"))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int((user?.bankingLicenseProgress ?? 0) * 100))%")
                            .foregroundColor(.white)
                            .font(.body.weight(.semibold))
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 16)

                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.ctaBlue, .ctaBlue.opacity(0.75)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geo.size.width * (user?.bankingLicenseProgress ?? 0),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 16)

                    // Skill Badges
                    Text(tr("Skill Badges", "شارات المهارة"))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                    HStack(spacing: 10) {
                        skillBadge(icon: "books.vertical.fill", title: tr("Scholar", "القارئ"), earned: user?.hasReadEntireLibrary ?? false)
                        skillBadge(icon: "shield.checkered", title: tr("Scam Spotter", "كاشف الاحتيال"), earned: user?.bankingLicenseCompleted ?? false)
                        skillBadge(icon: "chart.line.uptrend.xyaxis", title: tr("Investor", "المستثمر"), earned: user?.ownsAnyInvestment ?? false)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .liquidGlass(cornerRadius: 16, tint: .finSimGreen, interactive: false)

                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }

    /// A badge chip; locked badges are dimmed with a lock indicator so the
    /// empty state still communicates what can be earned.
    private func skillBadge(icon: String, title: String, earned: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: earned ? icon : "lock.fill")
                .font(.body.weight(.medium))
                .foregroundColor(.white.opacity(earned ? 1 : 0.45))
                .frame(width: 34, height: 34)
                .background(Circle().fill(Color.white.opacity(earned ? 0.22 : 0.10)))

            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundColor(.white.opacity(earned ? 0.95 : 0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(earned ? 0.10 : 0.05))
        )
    }

    private func identityRow(label: String, value: String) -> some View {
        GridRow {
            Text(label)
                .foregroundColor(.white.opacity(0.75))
                .font(.subheadline)
                .gridColumnAlignment(.leading)
            Text(value)
                .foregroundColor(.white)
                .font(.subheadline.weight(.medium))
                .monospacedDigit()
        }
    }
}
