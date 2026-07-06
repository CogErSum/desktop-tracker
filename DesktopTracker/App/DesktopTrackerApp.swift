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
                .preferredColorScheme(.light)
                .onOpenURL { url in
                    if url.scheme == "teamsight",
                       url.host == "auth",
                       let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let memberId = components.queryItems?.first(where: { $0.name == "member_id" })?.value {
                        UserDefaults.standard.set(memberId, forKey: "memberId")
                        NotificationCenter.default.post(name: .authCompleted, object: memberId)
                    }
                }
        }
        .defaultSize(width: 1000, height: 700)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static let shared = AppDelegate()
    private var window: NSWindow?
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
    }
    
    @objc private func systemWillSleep(_ notification: Notification) {
        print("[AppDelegate] System going to sleep, stopping timer")
        Task { @MainActor in
            await TimerState.shared.stopTimer()
        }
    }
    
    func showMainWindow() {
        if let w = window {
            w.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let contentView = ContentView()
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        newWindow.title = "TeamSight Tracker"
        newWindow.contentView = NSHostingView(rootView: contentView)
        newWindow.isReleasedWhenClosed = false
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = newWindow
    }
}

extension Notification.Name {
    static let authCompleted = Notification.Name("authCompleted")
}
