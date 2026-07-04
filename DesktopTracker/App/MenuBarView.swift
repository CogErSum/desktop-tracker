import SwiftUI

struct MenuBarView: View {
    @State private var timerViewModel = TimerViewModel()
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
                        .frame(maxWidth: 200)
                }
            }
            .frame(minWidth: 180)
            
            Divider()
            
            Button("Stop Timer") {
                Task { await timerViewModel.stopTimer() }
                cardName = ""
            }
        } else {
            Text("No active timer")
                .foregroundColor(.secondary)
                .frame(minWidth: 150)
        }
        
        Divider()
        
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
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
