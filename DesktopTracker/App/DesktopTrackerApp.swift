import SwiftUI

@main
struct DesktopTrackerApp: App {
    var body: some Scene {
        MenuBarExtra("TeamSight", systemImage: "timer") {
            MenuBarView()
        }
        
        WindowGroup("TeamSight Tracker") {
            ContentView()
        }
        .defaultSize(width: 1000, height: 700)
    }
}
