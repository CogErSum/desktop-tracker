import SwiftUI

struct TimerView: View {
    @State private var viewModel = TimerViewModel()
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var selectedCard: SearchResult?
    @State private var searching = false
    
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
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
        }
        .navigationTitle("Timer")
        .task {
            await viewModel.checkActiveTimer()
        }
    }
    
    private var startTimerView: some View {
        VStack(spacing: 16) {
            Text("Start Timer")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Search for a Trello card:")
                    .foregroundColor(.secondary)
                
                TextField("Type card name...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: searchText) { _, newValue in
                        debounceSearch(query: newValue)
                    }
                
                if searching {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity)
                }
                
                if !searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(searchResults) { card in
                                Button {
                                    selectedCard = card
                                    searchText = card.name
                                    searchResults = []
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
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 4)
                                }
                                .buttonStyle(.plain)
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
            
            if let selected = selectedCard {
                HStack {
                    Text("Selected:")
                        .foregroundColor(.secondary)
                    Text(selected.name)
                        .fontWeight(.medium)
                    Spacer()
                    Button("Clear") {
                        selectedCard = nil
                        searchText = ""
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
            }
            
            Button("Start Timer") {
                Task {
                    if let card = selectedCard {
                        await viewModel.startTimer(cardId: card.id)
                    } else if !searchText.isEmpty {
                        await viewModel.startTimer(cardId: searchText)
                    }
                }
            }
            .disabled((selectedCard == nil && searchText.isEmpty) || viewModel.loading)
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }
    
    private func activeTimerView(_ timer: ActiveTimer) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "timer")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading) {
                    Text(viewModel.formattedTime(viewModel.elapsed))
                        .font(.system(.title, design: .monospaced))
                        .foregroundColor(.green)
                    
                    Text("Timer is running")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button("Stop Timer") {
                Task { await viewModel.stopTimer() }
            }
            .disabled(viewModel.loading)
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
    }
    
    private func conflictView(_ conflict: TimerConflict) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading) {
                    Text(conflict.activeCardName)
                        .font(.headline)
                    Text(conflict.activeBoardName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button("Stop & Start New Timer") {
                if let card = selectedCard {
                    Task { await viewModel.stopAndStart(cardId: card.id) }
                }
            }
            .disabled(viewModel.loading || selectedCard == nil)
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
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
            print("Search error: \(error)")
            searchResults = []
        }
        searching = false
    }
}
