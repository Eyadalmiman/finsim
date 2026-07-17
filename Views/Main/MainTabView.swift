import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(tr("Home", "الرئيسية"), systemImage: "house.fill", value: 0) {
                NavigationStack {
                    LearningOptionsView()
                }
            }

            Tab(tr("AI Coach", "المدرب الذكي"), systemImage: "sparkles", value: 3) {
                NavigationStack {
                    AICoachView()
                }
            }

            Tab(tr("Settings", "الإعدادات"), systemImage: "gearshape.fill", value: 1) {
                NavigationStack {
                    SettingsView()
                }
            }

            Tab(tr("Account", "الحساب"), systemImage: "person.circle.fill", value: 2) {
                NavigationStack {
                    AccountView()
                }
            }
        }
        .tint(Color.finSimGreen)
    }
}
