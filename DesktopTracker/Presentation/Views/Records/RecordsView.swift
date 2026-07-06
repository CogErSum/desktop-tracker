import SwiftUI

struct RecordsView: View {
    @State private var viewModel = RecordsViewModel()
    @State private var selectedRecord: TimeRecord?
    @State private var showingAddForm = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .fill(Color.tmst.stroke)
                        .frame(height: 1),
                    alignment: .bottom
                )
            
            toolbarSection
            
            recordsContent
        }
        .background(Color.tmst.surface)
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
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Records")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.tmst.textPrimary)
            Text("\(viewModel.totalRecords) total records")
                .font(.system(size: 14))
                .foregroundColor(Color.tmst.textSecondary)
        }
    }
    
    private var toolbarSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.tmst.textSecondary)
                TextField("Search records...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.tmst.stroke, lineWidth: 1)
            )
            .frame(maxWidth: 280)
            
            Spacer()
            
            Button {
                showingAddForm = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Add Activity")
                }
            }
            .buttonStyle(TMSTButtonStyle())
            
            Button {
                Task { await viewModel.loadRecords() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
            }
            .buttonStyle(TMSTButtonStyle(color: Color.tmst.accentHover))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color.tmst.stroke)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    @ViewBuilder
    private var recordsContent: some View {
        if viewModel.loading {
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading records...")
                    .font(.system(size: 14))
                    .foregroundColor(Color.tmst.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.error {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 32))
                    .foregroundColor(Color.tmst.error)
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(Color.tmst.textSecondary)
                Button("Retry") {
                    Task { await viewModel.loadRecords() }
                }
                .buttonStyle(TMSTButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.filteredRecords().isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "tray")
                    .font(.system(size: 32))
                    .foregroundColor(Color.tmst.stroke)
                Text("No records found")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.tmst.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.filteredRecords()) { record in
                        recordRow(record)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRecord = record
                            }
                            .contextMenu {
                                Button("Edit") {
                                    selectedRecord = record
                                }
                                Button("Delete", role: .destructive) {
                                    Task { await viewModel.deleteRecord(record) }
                                }
                            }
                        
                        Divider()
                            .background(Color.tmst.stroke)
                            .padding(.leading, 24)
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
    
    private func recordRow(_ record: TimeRecord) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.cardName(for: record.trelloCardId))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.tmst.textPrimary)
                    .lineLimit(1)
                if let comment = record.comment {
                    Text(comment)
                        .font(.system(size: 11))
                        .foregroundColor(Color.tmst.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(viewModel.formatDuration(record.durationSec))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.tmst.accent)
                Text(formatDate(record.recordDate ?? record.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(Color.tmst.textSecondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString) else {
            return String(dateString.prefix(10))
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd MMM, HH:mm"
        return displayFormatter.string(from: date)
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
        VStack(spacing: 0) {
            header
            
            Divider()
                .background(Color.tmst.stroke)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if selectedCardId.isEmpty {
                        cardSelectionSection
                    } else {
                        selectedCardSection
                    }
                    
                    if !selectedCardId.isEmpty {
                        formSection
                    }
                }
                .padding(20)
            }
            
            Divider()
                .background(Color.tmst.stroke)
            
            footer
        }
        .frame(minWidth: 480, minHeight: 450)
        .background(Color.white)
        .task {
            await loadRecentCards()
        }
    }
    
    private var header: some View {
        HStack {
            Text("Add Activity")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.tmst.textPrimary)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.tmst.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
    }
    
    private var footer: some View {
        HStack {
            if let error = error {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(Color.tmst.error)
            }
            
            Spacer()
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(TMSTButtonStyle(color: Color.tmst.stroke))
            .foregroundColor(Color.tmst.textPrimary)
            
            Button {
                Task { await save() }
            } label: {
                if loading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("Save")
                }
            }
            .buttonStyle(TMSTButtonStyle())
            .disabled(selectedCardId.isEmpty || loading)
        }
        .padding(16)
    }
    
    private var cardSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Select Card", systemImage: "creditcard")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.tmst.textPrimary)
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.tmst.textSecondary)
                TextField("Search cards...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onChange(of: searchText) { _, newValue in
                        debounceSearch(query: newValue)
                    }
            }
            .padding(10)
            .background(Color.tmst.surface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.tmst.stroke, lineWidth: 1)
            )
            
            if searching {
                ProgressView()
                    .scaleEffect(0.8)
                    .frame(maxWidth: .infinity)
            }
            
            if !recentCards.isEmpty && searchText.isEmpty {
                Text("Recent Cards")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.tmst.textSecondary)
                    .textCase(.uppercase)
                
                recentCardsList
            }
            
            if !searchResults.isEmpty {
                searchResultsList
            }
        }
    }
    
    private var recentCardsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(recentCards) { card in
                    Button {
                        selectedCardId = card.id
                        selectedCardName = card.name
                    } label: {
                        HStack {
                            Text(card.name)
                                .font(.system(size: 13))
                                .foregroundColor(Color.tmst.textPrimary)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                                .foregroundColor(Color.tmst.textSecondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 4)
                    }
                    .buttonStyle(.plain)
                    Divider()
                        .background(Color.tmst.stroke)
                }
            }
        }
        .frame(maxHeight: 160)
    }
    
    private var searchResultsList: some View {
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
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.tmst.textPrimary)
                                    .lineLimit(2)
                                if !card.boardName.isEmpty {
                                    Text(card.boardName)
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.tmst.textSecondary)
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 4)
                    }
                    .buttonStyle(.plain)
                    Divider()
                        .background(Color.tmst.stroke)
                }
            }
        }
        .frame(maxHeight: 200)
    }
    
    private var selectedCardSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.tmst.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedCardName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.tmst.textPrimary)
                Text("Selected card")
                    .font(.system(size: 11))
                    .foregroundColor(Color.tmst.textSecondary)
            }
            Spacer()
            Button("Change") {
                selectedCardId = ""
                selectedCardName = ""
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color.tmst.accent)
        }
        .padding(12)
        .background(Color.tmst.accentLight)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.tmst.accent.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var formSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Duration", systemImage: "clock")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.tmst.textPrimary)
                
                HStack(spacing: 8) {
                    Picker("Hours", selection: $durationHours) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)h").tag(hour)
                        }
                    }
                    .labelsHidden()
                    .colorMultiply(Color.tmst.textPrimary)
                    
                    Picker("Minutes", selection: $durationMinutes) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text("\(minute)m").tag(minute)
                        }
                    }
                    .labelsHidden()
                    .colorMultiply(Color.tmst.textPrimary)
                }
                .padding(8)
                .background(Color.tmst.surface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.tmst.stroke, lineWidth: 1)
                )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Date", systemImage: "calendar")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.tmst.textPrimary)
                
                HStack {
                    Text(recordDate.formatted(date: .long, time: .omitted))
                        .foregroundColor(Color.tmst.textPrimary)
                    Spacer()
                    DatePicker("", selection: $recordDate, displayedComponents: .date)
                        .labelsHidden()
                        .frame(width: 0, height: 0)
                        .clipped()
                        .opacity(0)
                }
                .padding(8)
                .background(Color.tmst.surface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.tmst.stroke, lineWidth: 1)
                )
                .overlay(
                    DatePicker("", selection: $recordDate, displayedComponents: .date)
                        .labelsHidden()
                        .opacity(0)
                )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Comment", systemImage: "text.bubble")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.tmst.textPrimary)
                
                TextField("Optional note...", text: $comment)
                    .textFieldStyle(.plain)
                    .foregroundColor(Color.tmst.textPrimary)
                    .padding(8)
                    .background(Color.tmst.surface)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.tmst.stroke, lineWidth: 1)
                    )
            }
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
