import SwiftUI

struct MenuBarView: View {
    @State private var timerViewModel = TimerViewModel()
    
    var body: some View {
        if let timer = timerViewModel.activeTimer {
            Text("Active: \(timer.trelloCardId)")
            Text(timerViewModel.formattedTime(timerViewModel.elapsed))
            Divider()
            Button("Stop Timer") {
                Task { await timerViewModel.stopTimer() }
            }
        } else {
            Text("No active timer")
        }
        
        Divider()
        
        Button("Open Dashboard") {
            NSApp.activate(ignoringOtherApps: true)
            if let window = NSApp.windows.first(where: { $0.title == "TeamSight Tracker" }) {
                window.makeKeyAndOrderFront(nil)
            }
        }
        
        Divider()
        
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
