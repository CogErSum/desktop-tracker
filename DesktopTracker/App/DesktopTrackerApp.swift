import SwiftUI

@main
struct DesktopTrackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
