import SwiftUI

struct RecordsView: View {
    @State private var viewModel = RecordsViewModel()
    @State private var selectedRecord: TimeRecord?
    @State private var showingAddForm = false
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search records...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
                
                Spacer()
                
                Button {
                    showingAddForm = true
                } label: {
                    Label("Add Activity", systemImage: "plus.circle")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.tmst.accent)
                
                Text("\(viewModel.records.count)/\(viewModel.totalRecords)")
                    .foregroundColor(Color.tmst.textSecondary)
                    .font(.caption)
                
                Button("Refresh") {
                    Task { await viewModel.loadRecords() }
                }
            }
            .padding()
            
            if viewModel.loading {
                ProgressView()
            } else if let error = viewModel.error {
                Text(error)
                    .foregroundColor(Color.tmst.error)
            } else if viewModel.filteredRecords().isEmpty {
                Text("No records found")
                    .foregroundColor(Color.tmst.textSecondary)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredRecords()) { record in
                            RecordRow(
                                record: record,
                                cardName: viewModel.cardName(for: record.trelloCardId),
                                formatDuration: viewModel.formatDuration
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRecord = record
                            }
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    Task { await viewModel.deleteRecord(record) }
                                }
                            }
                            Divider()
                        }
                        
                        if viewModel.records.count < viewModel.totalRecords {
                            ProgressView()
                                .padding()
                                .task {
                                    try? await Task.sleep(for: .milliseconds(200))
                                    await viewModel.loadMore()
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("Records")
        .task {
            await viewModel.loadRecords()
        }
        .sheet(item: $selectedRecord) { record in
            RecordDetail(
                record: record,
                cardName: viewModel.cardName(for: record.trelloCardId),
                formatDuration: viewModel.formatDuration,
                onDelete: {
                    Task { await viewModel.deleteRecord(record) }
                    selectedRecord = nil
                }
            )
        }
        .sheet(isPresented: $showingAddForm) {
            AddActivityView {
                showingAddForm = false
                Task { await viewModel.loadRecords() }
            }
        }
    }
}

struct AddActivityView: View {
    let onComplete: () -> Void
    
    @State private var recentCards: [RecentCard] = []
    @State private var selectedCardId: String = ""
    @State private var selectedCardName: String = ""
    @State private var searchText: String = ""
    @State private var searchResults: [SearchResult] = []
    @State private var searching = false
    @State private var durationHours = 0
    @State private var durationMinutes = 30
    @State private var comment = ""
    @State private var recordDate = Date()
    @State private var loading = false
    @State private var error: String?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Add Activity")
                .font(.title2)
                .fontWeight(.bold)
            
            if selectedCardId.isEmpty {
                cardSelectionView
            } else {
                selectedCardView
            }
            
            if !selectedCardId.isEmpty {
                durationView
                dateView
                commentView
            }
            
            if let error = error {
                Text(error)
                    .foregroundColor(Color.tmst.error)
                    .font(.caption)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Button("Save") {
                    Task { await save() }
                }
                .disabled(selectedCardId.isEmpty || loading)
                .buttonStyle(.borderedProminent)
                .tint(Color.tmst.accent)
            }
        }
        .padding()
        .frame(minWidth: 450, minHeight: 400)
        .task {
            await loadRecentCards()
        }
    }
    
    private var cardSelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Card")
                .font(.headline)
                .foregroundColor(Color.tmst.textSecondary)
            
            TextField("Search cards...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .onChange(of: searchText) { _, newValue in
                    debounceSearch(query: newValue)
                }
            
            if searching {
                ProgressView()
                    .scaleEffect(0.8)
            }
            
            if !recentCards.isEmpty && searchText.isEmpty {
                Text("Recent Cards")
                    .font(.caption)
                    .foregroundColor(Color.tmst.textSecondary)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(recentCards) { card in
                            Button {
                                selectedCardId = card.id
                                selectedCardName = card.name
                            } label: {
                                HStack {
                                    Text(card.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
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
                .frame(maxHeight: 150)
            }
            
            if !searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchResults) { card in
                            Button {
                                selectedCardId = card.id
                                selectedCardName = card.name
                                searchText = ""
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
    }
    
    private var selectedCardView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Selected Card")
                    .font(.caption)
                    .foregroundColor(Color.tmst.textSecondary)
                Text(selectedCardName)
                    .font(.body)
                    .fontWeight(.medium)
            }
            Spacer()
            Button("Change") {
                selectedCardId = ""
                selectedCardName = ""
            }
            .buttonStyle(.plain)
            .foregroundColor(Color.tmst.accent)
        }
        .padding()
        .background(Color.tmst.surface)
        .cornerRadius(8)
    }
    
    private var durationView: some View {
        HStack {
            Text("Duration")
                .font(.headline)
                .foregroundColor(Color.tmst.textSecondary)
            
            Picker("Hours", selection: $durationHours) {
                ForEach(0..<24) { hour in
                    Text("\(hour)h").tag(hour)
                }
            }
            .frame(width: 80)
            
            Picker("Minutes", selection: $durationMinutes) {
                ForEach(0..<60) { minute in
                    Text("\(minute)m").tag(minute)
                }
            }
            .frame(width: 80)
        }
    }
    
    private var dateView: some View {
        DatePicker("Date", selection: $recordDate, displayedComponents: .date)
    }
    
    private var commentView: some View {
        TextField("Comment (optional)", text: $comment)
            .textFieldStyle(.roundedBorder)
    }
    
    private func loadRecentCards() async {
        let repository = TimeTrackerRepositoryImpl()
        let memberId = UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
        do {
            let (records, _) = try await repository.getRecords(memberId: memberId, limit: 10, offset: 0)
            let cardIds = Array(Set(records.map { $0.trelloCardId }))
            if !cardIds.isEmpty {
                let names = try await repository.getCardNames(cardIds: cardIds)
                recentCards = cardIds.prefix(5).compactMap { id in
                    guard let name = names[id] else { return nil }
                    return RecentCard(id: id, name: name)
                }
            }
        } catch {
            print("Failed to load recent cards: \(error)")
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
            searchResults = []
        }
        searching = false
    }
    
    private func save() async {
        guard !selectedCardId.isEmpty else { return }
        
        let totalSeconds = durationHours * 3600 + durationMinutes * 60
        guard totalSeconds > 0 else {
            error = "Duration must be greater than 0"
            return
        }
        
        loading = true
        error = nil
        
        let repository = TimeTrackerRepositoryImpl()
        let memberId = UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        do {
            _ = try await repository.createRecord(
                memberId: memberId,
                cardId: selectedCardId,
                duration: totalSeconds,
                comment: comment.isEmpty ? nil : comment,
                date: formatter.string(from: recordDate)
            )
            onComplete()
        } catch {
            self.error = "Failed to save: \(error.localizedDescription)"
        }
        
        loading = false
    }
}
