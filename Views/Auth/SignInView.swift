import SwiftUI
import SwiftData

struct SignInView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Binding var showSignIn: Bool
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("currentUserEmail") private var currentUserEmail = ""

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var dateOfBirth = Date()
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showOfflineAlert = false
    @ObservedObject private var network = NetworkMonitor.shared

    var body: some View {
        ZStack {
            GreenPatternBackground()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 30)

                    Text(tr("Sign in", "إنشاء حساب"))
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)

                    // Form Fields
                    VStack(spacing: 14) {
                        GlassmorphicTextField(placeholder: tr("Name", "الاسم"), text: $name)

                        GlassmorphicTextField(placeholder: tr("Email", "البريد الإلكتروني"), text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        GlassmorphicTextField(placeholder: tr("Password", "كلمة المرور"), text: $password, isSecure: true)

                        // Date of Birth picker
                        HStack {
                            Text(tr("Date of birth", "تاريخ الميلاد"))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.10))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.20), lineWidth: 1)
                        )
                    }

                    // Sign In Button
                    Button {
                        createAccountAndLogin()
                    } label: {
                        Text(tr("Sign in", "إنشاء حساب"))
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

                    // Toggle to Login
                    Button {
                        withAnimation { showSignIn = false }
                    } label: {
                        Text(tr("Login", "تسجيل الدخول"))
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
            Text(tr("Signing in with Google or Apple needs an internet connection. You can still sign in with email and password.", "يتطلب تسجيل الدخول عبر Google أو Apple اتصالاً بالإنترنت. لا يزال بإمكانك التسجيل بالبريد الإلكتروني وكلمة المرور."))
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

    private func createAccountAndLogin() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()

        guard !trimmedName.isEmpty, !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = tr("Please fill in your name, email, and password.", "يرجى تعبئة الاسم والبريد الإلكتروني وكلمة المرور.")
            showError = true
            return
        }

        guard !users.contains(where: { $0.email.lowercased() == trimmedEmail }) else {
            errorMessage = tr("An account with this email already exists. Please log in instead.", "يوجد حساب بهذا البريد الإلكتروني بالفعل. يرجى تسجيل الدخول بدلاً من ذلك.")
            showError = true
            return
        }

        let user = User(
            name: trimmedName,
            email: trimmedEmail,
            password: password,
            dateOfBirth: dateOfBirth,
            idNumber: "1150000089"
        )
        modelContext.insert(user)
        currentUserEmail = trimmedEmail
        isLoggedIn = true
    }
}
