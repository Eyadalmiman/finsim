import SwiftUI
import SwiftData

struct LogInView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Binding var showSignIn: Bool
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("currentUserEmail") private var currentUserEmail = ""

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showOfflineAlert = false
    @ObservedObject private var network = NetworkMonitor.shared

    var body: some View {
        ZStack {
            GreenPatternBackground()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 50)

                    Text(tr("Log in", "تسجيل الدخول"))
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)

                    // Form Fields
                    VStack(spacing: 14) {
                        GlassmorphicTextField(placeholder: tr("Email", "البريد الإلكتروني"), text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        GlassmorphicTextField(placeholder: tr("Password", "كلمة المرور"), text: $password, isSecure: true)
                    }

                    // Log In Button
                    Button {
                        logIn()
                    } label: {
                        Text(tr("Log in", "تسجيل الدخول"))
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    // Divider
                    HStack {
                        Rectangle().fill(Color.white.opacity(0.3)).frame(height: 1)
                        Text(tr("or", "أو"))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        Rectangle().fill(Color.white.opacity(0.3)).frame(height: 1)
                    }

                    // Social Sign In Buttons
                    VStack(spacing: 10) {
                        Button {
                            socialSignIn(.google)
                        } label: {
                            HStack(spacing: 10) {
                                Text("G")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.red, .yellow, .green, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Text(tr("Sign in with Google", "تسجيل الدخول عبر Google"))
                            }
                        }
                        .buttonStyle(SocialButtonStyle())

                        Button {
                            socialSignIn(.apple)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "apple.logo")
                                    .font(.title3)
                                Text(tr("Sign in with Apple", "تسجيل الدخول عبر Apple"))
                            }
                        }
                        .buttonStyle(SocialButtonStyle())

                        if !network.isConnected {
                            HStack(spacing: 6) {
                                Image(systemName: "wifi.slash")
                                Text(tr("Social sign-in is locked while you're offline", "تسجيل الدخول الاجتماعي مقفل أثناء عدم الاتصال بالإنترنت"))
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        }

                    }

                    // Toggle to Sign In
                    Button {
                        withAnimation { showSignIn = true }
                    } label: {
                        Text(tr("Sign in", "إنشاء حساب"))
                            .foregroundColor(.white.opacity(0.8))
                            .font(.body)
                    }
                    .padding(.top, 5)

                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 28)
            }
        }
        .alert(errorMessage, isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
        .alert(tr("You're Offline", "لا يوجد اتصال بالإنترنت"), isPresented: $showOfflineAlert) {
            Button(tr("Okay!", "حسناً!"), role: .cancel) { }
        } message: {
            Text(tr("Signing in with Google or Apple needs an internet connection. You can still log in with email and password.", "يتطلب تسجيل الدخول عبر Google أو Apple اتصالاً بالإنترنت. لا يزال بإمكانك تسجيل الدخول بالبريد الإلكتروني وكلمة المرور."))
        }
    }

    private func socialSignIn(_ provider: SocialProvider) {
        guard network.isConnected else {
            showOfflineAlert = true
            return
        }
        let account = User.signIn(with: provider, existing: users, context: modelContext)
        currentUserEmail = account.email
        isLoggedIn = true
    }

    private func logIn() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()

        guard
            let user = users.first(where: { $0.email.lowercased() == trimmedEmail }),
            user.matches(password: password)
        else {
            errorMessage = tr("Incorrect email or password.", "البريد الإلكتروني أو كلمة المرور غير صحيحة.")
            showError = true
            return
        }

        currentUserEmail = trimmedEmail
        isLoggedIn = true
    }
}
