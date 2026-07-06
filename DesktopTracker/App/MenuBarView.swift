import SwiftUI

struct MenuBarView: View {
    @StateObject private var timerState = TimerState.shared
    @State private var recentCards: [RecentCard] = []
    @State private var showingPicker = false
    
    var body: some View {
        if let timer = timerState.activeTimer {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.green)
                    Text(timerState.formattedTime(timerState.elapsed))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.green)
                }
                
                if !timerState.activeCardName.isEmpty {
                    Text(timerState.activeCardName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: 200)
                }
            }
            .frame(minWidth: 180)
            
            Divider()
            
            Button("Stop Timer") {
                Task { await timerState.stopTimer() }
            }
        } else {
            Menu("Start Timer") {
                if recentCards.isEmpty {
                    Text("No recent cards")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(recentCards) { card in
                        Button(card.name) {
                            Task { await timerState.startTimer(cardId: card.id) }
                        }
                    }
                }
                
                Divider()
                
                Button("Search All Cards...") {
                    showingPicker = true
                }
            }
        }
        
        Divider()
        
        Button("Open Dashboard") {
            AppDelegate.shared.showMainWindow()
        }
        .keyboardShortcut("d")
        
        Divider()
        
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
        .task {
            await timerState.checkActiveTimer()
            await loadRecentCards()
        }
        .sheet(isPresented: $showingPicker) {
            MenuBarCardPicker(selectedCard: { cardId in
                Task { await timerState.startTimer(cardId: cardId) }
            })
        }
    }
    
    private func loadRecentCards() async {
        let repository = TimeTrackerRepositoryImpl()
        let memberId = UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
        do {
            let (records, _) = try await repository.getRecords(memberId: memberId, limit: 10, offset: 0)
            let cardIds = Array(Set(records.map { $0.trelloCardId }))
            if !cardIds.isEmpty {
                let names = try await repository.getCardNames(cardIds: cardIds)
                recentCards = cardIds.prefix(8).compactMap { id in
                    guard let name = names[id] else { return nil }
                    return RecentCard(id: id, name: name)
                }
            }
        } catch {
            print("Failed to load recent cards: \(error)")
        }
    }
}

struct MenuBarCardPicker: View {
    let selectedCard: (String) -> Void
    
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var searching = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Select Card")
                .font(.headline)
            
            TextField("Search cards...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .onChange(of: searchText) { _, newValue in
                    debounceSearch(query: newValue)
                }
            
            if searching {
                ProgressView()
                    .scaleEffect(0.8)
            }
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(searchResults) { card in
                        Button {
                            selectedCard(card.id)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(card.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                    if !card.boardName.isEmpty {
                                        Text(card.boardName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 350)
    }
    
    private func debounceSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            await searchCards(query: query)
        }
    }
    
    private func searchCards(query: String) async {
        searching = true
        let repository = TimeTrackerRepositoryImpl()
        do {
            searchResults = try await repository.searchCards(query: query)
        } catch {
            searchResults = []
        }
        searching = false
    }
}
