import SwiftUI

struct TimerView: View {
    @StateObject private var timerState = TimerState.shared
    @State private var boards: [Board] = []
    @State private var selectedBoard: Board?
    @State private var cards: [BoardCard] = []
    @State private var selectedCard: BoardCard?
    @State private var loadingBoards = false
    @State private var loadingCards = false
    
    let cardId: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                
                if let timer = timerState.activeTimer {
                    activeTimerSection(timer)
                } else if let conflict = timerState.conflictInfo {
                    conflictSection(conflict)
                } else {
                    startTimerSection
                }
                
                if let error = timerState.error {
                    errorBanner(error)
                }
            }
            .padding(24)
        }
        .background(Color.tmst.surface.opacity(0.3))
        .task {
            await timerState.checkActiveTimer()
            await loadBoards()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Timer")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.tmst.textPrimary)
            Text("Track time on your tasks")
                .font(.system(size: 14))
                .foregroundColor(Color.tmst.textSecondary)
        }
    }
    
    private func activeTimerSection(_ timer: ActiveTimer) -> some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Image(systemName: "timer")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.tmst.accent)
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(timerState.formattedTime(timerState.elapsed))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.tmst.textPrimary)
                    Text(timerState.activeCardName.isEmpty ? "Timer is running" : timerState.activeCardName)
                        .font(.system(size: 14))
                        .foregroundColor(Color.tmst.textSecondary)
                }
                
                Spacer()
                
                Button {
                    Task { await timerState.stopTimer() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                }
                .buttonStyle(TMSTButtonStyle(color: Color.tmst.error))
                .disabled(timerState.loading)
            }
            .padding(20)
            .tmstCard()
        }
    }
    
    private func conflictSection(_ conflict: TimerConflict) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.tmst.warning)
                    .frame(width: 44, height: 44)
                    .background(Color.tmst.warning.opacity(0.15))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(conflict.activeCardName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.tmst.textPrimary)
                    Text(conflict.activeBoardName)
                        .font(.system(size: 12))
                        .foregroundColor(Color.tmst.textSecondary)
                }
                
                Spacer()
            }
            
            Button {
                if let card = selectedCard {
                    Task { await timerState.stopAndStart(cardId: card.id) }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Stop & Start Here")
                }
            }
            .buttonStyle(TMSTButtonStyle(color: Color.tmst.warning))
            .disabled(timerState.loading || selectedCard == nil)
        }
        .padding(20)
        .tmstCard()
    }
    
    private var startTimerSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            boardSelection
            if selectedBoard != nil {
                cardSelection
            }
            startButton
        }
        .padding(20)
        .tmstCard()
    }
    
    private var boardSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Select Board", systemImage: "square.stack")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.tmst.textPrimary)
            
            if loadingBoards {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
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
        }
    }
    
    private var cardSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Select Card", systemImage: "creditcard")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.tmst.textPrimary)
            
            if loadingCards {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if cards.isEmpty {
                Text("No cards in this board")
                    .font(.system(size: 13))
                    .foregroundColor(Color.tmst.textSecondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(cards) { card in
                            cardRow(card)
                        }
                    }
                }
                .frame(maxHeight: 280)
                .background(Color.tmst.surface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.tmst.stroke, lineWidth: 1)
                )
            }
        }
    }
    
    private func cardRow(_ card: BoardCard) -> some View {
        Button {
            selectedCard = card
        } label: {
            HStack {
                Text(card.name)
                    .font(.system(size: 13))
                    .foregroundColor(selectedCard?.id == card.id ? .white : Color.tmst.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
                if selectedCard?.id == card.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                selectedCard?.id == card.id
                    ? Color.tmst.accent
                    : Color.clear
            )
        }
        .buttonStyle(.plain)
        Divider()
            .background(Color.tmst.stroke)
    }
    
    private var startButton: some View {
        Button {
            Task {
                if let card = selectedCard {
                    await timerState.startTimer(cardId: card.id)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                Text("Start Timer")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(TMSTButtonStyle())
        .disabled(selectedCard == nil || timerState.loading)
    }
    
    private func errorBanner(_ error: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(Color.tmst.error)
            Text(error)
                .font(.system(size: 13))
                .foregroundColor(Color.tmst.error)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tmst.error.opacity(0.08))
        .cornerRadius(8)
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
