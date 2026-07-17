//
//  ContentView.swift
//  FinSim
//
//  Created by Eyad Almiman on 7/9/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    @AppStorage("hasSeenMission") private var hasSeenMission = false

    /// The launch video plays once per cold start — this flag survives the
    /// full tree rebuild that a language switch triggers via .id().
    private final class SplashGate { static var played = false }
    @State private var showSplash = !SplashGate.played

    private var isArabic: Bool { selectedLanguage == "العربية" }

    var body: some View {
        ZStack {
            Group {
                if isLoggedIn {
                    MainTabView()
                        // Covers present above the whole ZStack, so the
                        // mission waits until the splash video has finished.
                        .fullScreenCover(isPresented: .init(
                            get: { !hasSeenMission && !showSplash },
                            set: { hasSeenMission = !$0 }
                        )) {
                            AboutFinSimView(isFirstLaunch: true)
                        }
                } else {
                    AuthGateView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isLoggedIn)

            if showSplash {
                SplashScreenView {
                    SplashGate.played = true
                    withAnimation(.easeOut(duration: 0.45)) { showSplash = false }
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .preferredColorScheme(darkMode ? .dark : .light)
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        .environment(\.locale, Locale(identifier: isArabic ? "ar" : "en"))
        // Rebuild the whole tree on language change so every tr() re-evaluates.
        .id(selectedLanguage)
    }
}

struct AuthGateView: View {
    @State private var showSignIn = true

    var body: some View {
        Group {
            if showSignIn {
                SignInView(showSignIn: $showSignIn)
            } else {
                LogInView(showSignIn: $showSignIn)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSignIn)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: User.self, inMemory: true)
}
