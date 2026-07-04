import SwiftUI

struct MenuBarView: View {
    @State private var timerViewModel = TimerViewModel()
    @State private var showingStartTimer = false
    @State private var cardName: String = ""
    
    var body: some View {
        if let timer = timerViewModel.activeTimer {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.green)
                    Text(timerViewModel.formattedTime(timerViewModel.elapsed))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.green)
                }
                
                if !cardName.isEmpty {
                    Text(cardName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text(String(timer.trelloCardId.prefix(12)) + "...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(minWidth: 200)
            
            Divider()
            
            Button("Stop Timer") {
                Task { await timerViewModel.stopTimer() }
                cardName = ""
            }
            .keyboardShortcut("s")
        } else {
            Button("Start Timer...") {
                showingStartTimer = true
            }
            .keyboardShortcut("t")
            
            Text("No active timer")
                .foregroundColor(.secondary)
        }
        
        Divider()
        
        Button("Open Dashboard") {
            NSApp.activate(ignoringOtherApps: true)
            if let window = NSApp.windows.first(where: { $0.title == "TeamSight Tracker" }) {
                window.makeKeyAndOrderFront(nil)
            }
        }
        .keyboardShortcut("d")
        
        Divider()
        
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
        .sheet(isPresented: $showingStartTimer) {
            StartTimerView()
                .onDisappear {
                    Task {
                        await timerViewModel.checkActiveTimer()
                        if let timer = timerViewModel.activeTimer {
                            await fetchCardName(cardId: timer.trelloCardId)
                        }
                    }
                }
        }
        .task {
            await timerViewModel.checkActiveTimer()
            if let timer = timerViewModel.activeTimer {
                await fetchCardName(cardId: timer.trelloCardId)
            }
        }
    }
    
    private func fetchCardName(cardId: String) async {
        let repository = TimeTrackerRepositoryImpl()
        do {
            let info = try await repository.getCardInfo(cardId: cardId)
            cardName = info.name
        } catch {
            cardName = ""
        }
    }
}
