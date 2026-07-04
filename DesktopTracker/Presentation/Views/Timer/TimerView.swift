import SwiftUI

struct TimerView: View {
    @State private var viewModel = TimerViewModel()
    @State private var boards: [Board] = []
    @State private var selectedBoard: Board?
    @State private var cards: [BoardCard] = []
    @State private var selectedCard: BoardCard?
    @State private var loadingBoards = false
    @State private var loadingCards = false
    
    let cardId: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let timer = viewModel.activeTimer {
                    activeTimerView(timer)
                } else if let conflict = viewModel.conflictInfo {
                    conflictView(conflict)
                } else {
                    startTimerView
                }
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(Color.tmst.error)
                        .font(.caption)
                }
            }
            .padding()
        }
        .navigationTitle("Timer")
        .task {
            await viewModel.checkActiveTimer()
            await loadBoards()
        }
    }
    
    private var startTimerView: some View {
        VStack(spacing: 16) {
            Text("Start Timer")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.tmst.textPrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Board")
                    .font(.headline)
                    .foregroundColor(Color.tmst.textSecondary)
                
                if loadingBoards {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Picker("Board", selection: $selectedBoard) {
                        Text("Choose board...").tag(nil as Board?)
                        ForEach(boards) { board in
                            Text(board.name).tag(board as Board?)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedBoard) { _, newBoard in
                        if let board = newBoard {
                            Task { await loadCards(boardId: board.id) }
                        } else {
                            cards = []
                            selectedCard = nil
                        }
                    }
                }
                
                if selectedBoard != nil {
                    Divider()
                    
                    Text("Select Card")
                        .font(.headline)
                        .foregroundColor(Color.tmst.textSecondary)
                    
                    if loadingCards {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else if cards.isEmpty {
                        Text("No cards in this board")
                            .foregroundColor(Color.tmst.textSecondary)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(cards) { card in
                                    Button {
                                        selectedCard = card
                                    } label: {
                                        HStack {
                                            Text(card.name)
                                                .font(.body)
                                                .foregroundColor(selectedCard?.id == card.id ? Color.white : Color.tmst.textPrimary)
                                                .lineLimit(2)
                                            Spacer()
                                            if selectedCard?.id == card.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color.white)
                                            }
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(
                                            selectedCard?.id == card.id
                                                ? Color.tmst.accent
                                                : Color.clear
                                        )
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                    Divider()
                                }
                            }
                        }
                        .frame(maxHeight: 250)
                        .background(Color.tmst.surface)
                        .cornerRadius(8)
                    }
                }
            }
            
            Button("Start Timer") {
                Task {
                    if let card = selectedCard {
                        await viewModel.startTimer(cardId: card.id)
                    }
                }
            }
            .disabled(selectedCard == nil || viewModel.loading)
            .buttonStyle(.borderedProminent)
            .tint(Color.tmst.accent)
        }
    }
    
    private func activeTimerView(_ timer: ActiveTimer) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "timer")
                    .font(.largeTitle)
                    .foregroundColor(Color.tmst.accent)
                
                VStack(alignment: .leading) {
                    Text(viewModel.formattedTime(viewModel.elapsed))
                        .font(.system(.title, design: .monospaced))
                        .foregroundColor(Color.tmst.accent)
                    
                    Text("Timer is running")
                        .font(.caption)
                        .foregroundColor(Color.tmst.textSecondary)
                }
            }
            
            Button("Stop Timer") {
                Task { await viewModel.stopTimer() }
            }
            .disabled(viewModel.loading)
            .buttonStyle(.borderedProminent)
            .tint(Color.tmst.error)
        }
    }
    
    private func conflictView(_ conflict: TimerConflict) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(Color.tmst.warning)
                
                VStack(alignment: .leading) {
                    Text(conflict.activeCardName)
                        .font(.headline)
                        .foregroundColor(Color.tmst.textPrimary)
                    Text(conflict.activeBoardName)
                        .font(.caption)
                        .foregroundColor(Color.tmst.textSecondary)
                }
            }
            
            Button("Stop & Start New Timer") {
                if let card = selectedCard {
                    Task { await viewModel.stopAndStart(cardId: card.id) }
                }
            }
            .disabled(viewModel.loading || selectedCard == nil)
            .buttonStyle(.borderedProminent)
            .tint(Color.tmst.warning)
        }
    }
    
    private func loadBoards() async {
        loadingBoards = true
        let repository = TimeTrackerRepositoryImpl()
        do {
            let memberId = UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
            boards = try await repository.getBoards(memberId: memberId)
        } catch {
            print("Failed to load boards: \(error)")
        }
        loadingBoards = false
    }
    
    private func loadCards(boardId: String) async {
        loadingCards = true
        selectedCard = nil
        let repository = TimeTrackerRepositoryImpl()
        do {
            cards = try await repository.getBoardCards(boardId: boardId)
        } catch {
            print("Failed to load cards: \(error)")
            cards = []
        }
        loadingCards = false
    }
}

struct Board: Identifiable, Codable, Hashable {
    let id: String
    let name: String
}
