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
                .background(WindowAccessor())
        }
        .defaultSize(width: 1000, height: 700)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    var mainWindow: NSWindow?
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        print("[AppDelegate] Launched")
    }
}

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                AppDelegate.shared?.mainWindow = window
                print("[WindowAccessor] Captured window: \(window.title), isVisible: \(window.isVisible)")
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

func openMainWindow() {
    print("[OpenWindow] Called. AppDelegate.shared: \(AppDelegate.shared != nil)")
    print("[OpenWindow] mainWindow: \(String(describing: AppDelegate.shared?.mainWindow))")
    
    if let window = AppDelegate.shared?.mainWindow {
        print("[OpenWindow] Window found, isVisible: \(window.isVisible), isMiniaturized: \(window.isMiniaturized)")
        window.makeKeyAndOrderFront(nil)
        window.orderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        print("[OpenWindow] Called makeKeyAndOrderFront and activate")
    } else {
        print("[OpenWindow] No window reference, trying NSApp.windows")
        for (i, window) in NSApp.windows.enumerated() {
            print("[OpenWindow] Window[\(i)]: title='\(window.title)', isVisible=\(window.isVisible)")
            if window.title == "TeamSight Tracker" {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                print("[OpenWindow] Found and activated window \(i)")
                return
            }
        }
        print("[OpenWindow] No matching window found in NSApp.windows (\(NSApp.windows.count) total)")
    }
}
