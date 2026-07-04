import SwiftUI

struct CardPicker: View {
    @Binding var selectedCardId: String
    let memberId: String
    
    @State private var searchText = ""
    @State private var recentCards: [(id: String, name: String)] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Search or paste Card ID...", text: $searchText)
                .textFieldStyle(.roundedBorder)
            
            if !recentCards.isEmpty {
                Text("Recent Cards")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(recentCards, id: \.id) { card in
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
            let records = try await repository.getRecords(memberId: memberId)
            let uniqueCards = Array(Set(records.map { ($0.trelloCardId, $0.trelloCardId) }))
            recentCards = Array(uniqueCards.prefix(5))
        } catch {
            // Silent fail
        }
    }
}
