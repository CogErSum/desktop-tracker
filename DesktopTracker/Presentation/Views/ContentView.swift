import SwiftUI

struct ContentView: View {
    @State private var selectedTab: String = "dashboard"
    @State private var isLoggedIn = UserDefaults.standard.string(forKey: "memberId") != nil
    
    var body: some View {
        if isLoggedIn {
            mainApp
        } else {
            LoginView { memberId in
                UserDefaults.standard.set(memberId, forKey: "memberId")
                isLoggedIn = true
            }
        }
    }
    
    private var mainApp: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailContent
        }
        .frame(minWidth: 900, minHeight: 600)
    }
    
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.tmst.accent)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .semibold))
                    )
                Text("TeamSight")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.tmst.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 4) {
                sidebarItem(icon: "chart.bar.fill", title: "Dashboard", tab: "dashboard")
                sidebarItem(icon: "clock.fill", title: "Timer", tab: "timer")
                sidebarItem(icon: "list.bullet", title: "Records", tab: "records")
            }
            .padding(.horizontal, 12)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Button {
                    UserDefaults.standard.removeObject(forKey: "memberId")
                    isLoggedIn = false
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14))
                            .frame(width: 20)
                        Text("Sign Out")
                            .font(.system(size: 13, weight: .regular))
                        Spacer()
                    }
                    .foregroundColor(Color.tmst.error)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .frame(width: 220)
        .background(Color.white)
    }
    
    private func sidebarItem(icon: String, title: String, tab: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 13, weight: selectedTab == tab ? .semibold : .regular))
                Spacer()
            }
            .foregroundColor(selectedTab == tab ? Color.tmst.accent : Color.tmst.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedTab == tab ? Color.tmst.accentLight : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var detailContent: some View {
        switch selectedTab {
        case "dashboard":
            DashboardView()
        case "timer":
            TimerView(cardId: "")
        case "records":
            RecordsView()
        default:
            DashboardView()
        }
    }
}
