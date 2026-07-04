import SwiftUI

struct ContentView: View {
    @State private var selectedTab: String = "dashboard"
    
    var body: some View {
        NavigationSplitView {
            List {
                Section("Tracking") {
                    NavigationLink(value: "dashboard") {
                        Label("Dashboard", systemImage: "chart.bar")
                    }
                    NavigationLink(value: "records") {
                        Label("Records", systemImage: "list.bullet")
                    }
                    NavigationLink(value: "manual") {
                        Label("Manual Entry", systemImage: "plus.circle")
                    }
                    NavigationLink(value: "timer") {
                        Label("Timer", systemImage: "timer")
                    }
                }
                
                Section("Settings") {
                    NavigationLink(value: "settings") {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("TeamSight")
            .navigationDestination(for: String.self) { tab in
                switch tab {
                case "dashboard":
                    DashboardView()
                case "records":
                    RecordsView()
                case "manual":
                    ManualEntryView()
                case "timer":
                    TimerView(cardId: "")
                case "settings":
                    SettingsView()
                default:
                    Text("Unknown")
                }
            }
        } detail: {
            DashboardView()
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}
