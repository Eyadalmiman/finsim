import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("currentUserEmail") private var currentUserEmail = ""

    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    @State private var showAbout = false
    @State private var showResetConfirm = false
    @State private var didReset = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Banner
                PageHeaderBanner(icon: "gearshape", title: tr("Settings", "الإعدادات"))

                // General Preferences
                settingsSection(title: tr("General Preferences", "التفضيلات العامة")) {
                    VStack(spacing: 0) {
                        // Language
                        HStack(spacing: 12) {
                            SettingsRowIcon(systemName: "globe")
                            Text(tr("Language", "اللغة"))
                                .foregroundColor(.white)
                            Spacer()
                            Menu {
                                Button("English") { selectedLanguage = "English" }
                                Button("العربية") { selectedLanguage = "العربية" }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedLanguage)
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .liquidGlass(cornerRadius: 14, tint: .ctaBlue)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        Divider().background(Color.white.opacity(0.2))

                        // Dark Mode
                        Toggle(isOn: $darkMode) {
                            HStack(spacing: 12) {
                                SettingsRowIcon(systemName: "moon.fill")
                                Text(tr("Dark mode", "الوضع الداكن"))
                                    .foregroundColor(.white)
                            }
                        }
                        .tint(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }

                // About
                settingsSection(title: tr("About", "حول التطبيق")) {
                    Button {
                        showAbout = true
                    } label: {
                        HStack(spacing: 12) {
                            SettingsRowIcon(systemName: "info.circle.fill")
                            Text(tr("About FinSim", "حول FinSim"))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: appIsArabic ? "chevron.backward" : "chevron.forward")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .liquidGlass(cornerRadius: 12, tint: .white.opacity(0.2), interactive: true)
                    }
                    .buttonStyle(PressableCardStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }

                // Account Management
                settingsSection(title: tr("Account Management", "إدارة الحساب")) {
                    VStack(spacing: 0) {
                        // Reset progress — the demo switch
                        Button {
                            showResetConfirm = true
                        } label: {
                            HStack(spacing: 12) {
                                SettingsRowIcon(systemName: "arrow.counterclockwise")
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(tr("Reset All Progress", "إعادة تعيين كل التقدم"))
                                        .foregroundColor(.white)
                                    Text(tr("Start fresh — badges, license, and investments", "ابدأ من جديد — الشارات والرخصة والاستثمارات"))
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.65))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .liquidGlass(cornerRadius: 12, tint: .white.opacity(0.2), interactive: true)
                        }
                        .buttonStyle(PressableCardStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)

                        // Sign Out Button
                        Button {
                            isLoggedIn = false
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.subheadline.weight(.semibold))
                                Text(tr("Sign Out", "تسجيل الخروج"))
                            }
                        }
                        .buttonStyle(LiquidGlassButtonStyle(tint: .dangerRed, isProminent: true))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }

                // Footer
                VStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Image(systemName: "phone.fill")
                            .font(.caption2)
                        Text(tr("Support: +966 533442072", "الدعم: 533442072 966+"))
                            .monospacedDigit()
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    HStack(spacing: 14) {
                        Text(tr("Privacy & Policy", "سياسة الخصوصية"))
                        Text("•")
                            .foregroundColor(.secondary.opacity(0.5))
                        Text(tr("Terms & Conditions", "الشروط والأحكام"))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    Text(tr("All rights reserved FinSim\u{00AE} 2026", "جميع الحقوق محفوظة FinSim\u{00AE} 2026"))
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.top, 2)
                }
                .padding(.top, 10)
                .padding(.bottom, 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .sheet(isPresented: $showAbout) {
            AboutFinSimView()
                .presentationDragIndicator(.visible)
        }
        .alert(tr("Reset all progress?", "إعادة تعيين كل التقدم؟"), isPresented: $showResetConfirm) {
            Button(tr("Reset", "إعادة تعيين"), role: .destructive) {
                if let user = users.current(email: currentUserEmail) {
                    user.resetProgress()
                    try? modelContext.save()
                    didReset = true
                }
            }
            Button(tr("Cancel", "إلغاء"), role: .cancel) { }
        } message: {
            Text(tr("Badges, the banking license, library quizzes, and all investments go back to the start. Your account stays.",
                    "تعود الشارات والرخصة البنكية واختبارات المكتبة وكل الاستثمارات إلى نقطة البداية. حسابك يبقى كما هو."))
        }
        .alert(tr("Fresh start!", "بداية جديدة!"), isPresented: $didReset) {
            Button(tr("Okay!", "حسناً!"), role: .cancel) { }
        } message: {
            Text(tr("All progress has been reset.", "تمت إعادة تعيين كل التقدم."))
        }
    }

    @ViewBuilder
    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: title)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)

            content()

            Spacer().frame(height: 8)
        }
        .liquidGlass(cornerRadius: 16, tint: .finSimGreen, interactive: false)
    }
}
