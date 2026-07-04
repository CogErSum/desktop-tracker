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
                .background(CaptureWindow())
        }
        .defaultSize(width: 1000, height: 700)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static let shared = AppDelegate()
    var window: NSWindow?
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
    
    func showWindow() {
        if let w = window, !w.isReleasedWhenClosed {
            w.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            NSApp.sendAction(Selector(("showWindows")), to: nil, from: nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

struct CaptureWindow: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = CapturingView()
        DispatchQueue.main.async {
            AppDelegate.shared.window = view.window
            view.window?.delegate = context.coordinator
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, NSWindowDelegate {
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            sender.orderOut(nil)
            return false
        }
    }
}

class CapturingView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let window = self.window {
            AppDelegate.shared.window = window
        }
    }
}
