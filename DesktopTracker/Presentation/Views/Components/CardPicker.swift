import SwiftUI

struct RecentCard: Identifiable {
    let id: String
    let name: String
}

struct CardPicker: View {
    @Binding var selectedCardId: String
    let memberId: String
    
    @State private var searchText = ""
    @State private var recentCards: [RecentCard] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Search or paste Card ID...", text: $searchText)
                .textFieldStyle(.roundedBorder)
            
            if !recentCards.isEmpty {
                Text("Recent Cards")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(recentCards) { card in
                    Button(card.name) {
                        selectedCardId = card.id
                        searchText = card.name
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                }
            }
        }
        .task {
            await loadRecentCards()
        }
    }
    
    private func loadRecentCards() async {
        let repository = TimeTrackerRepositoryImpl()
        do {
            let (records, _) = try await repository.getRecords(memberId: memberId, limit: 50, offset: 0)
            let uniqueIds = Array(Set(records.map { $0.trelloCardId }))
            recentCards = uniqueIds.prefix(5).map { RecentCard(id: $0, name: $0) }
        } catch {
            // Silent fail
        }
    }
}
