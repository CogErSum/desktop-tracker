import SwiftUI

struct TimerView: View {
    @State private var viewModel = TimerViewModel()
    let cardId: String
    
    var body: some View {
        VStack(spacing: 16) {
            if let timer = viewModel.activeTimer {
                activeTimerView(timer)
            } else if let conflict = viewModel.conflictInfo {
                conflictView(conflict)
            } else {
                idleView
            }
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .task {
            await viewModel.checkActiveTimer()
        }
    }
    
    private func activeTimerView(_ timer: ActiveTimer) -> some View {
        HStack {
            Text(viewModel.formattedTime(viewModel.elapsed))
                .font(.system(.title, design: .monospaced))
                .foregroundColor(.green)
            
            Button("Stop") {
                Task { await viewModel.stopTimer() }
            }
            .disabled(viewModel.loading)
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
    }
    
    private func conflictView(_ conflict: TimerConflict) -> some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                VStack(alignment: .leading) {
                    Text(conflict.activeCardName)
                        .font(.headline)
                    Text(conflict.activeBoardName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button("Stop & Start Here") {
                Task { await viewModel.stopAndStart(cardId: cardId) }
            }
            .disabled(viewModel.loading)
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
    }
    
    private var idleView: some View {
        HStack {
            Text("No active timer")
                .foregroundColor(.secondary)
            
            Button("Start") {
                Task { await viewModel.startTimer(cardId: cardId) }
            }
            .disabled(viewModel.loading)
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }
}
