import Foundation
import SwiftUI

@MainActor
@Observable
class RecordsViewModel {
    private let repository: TimeTrackerRepository
    private var memberId: String
    
    var records: [TimeRecord] = []
    var totalRecords = 0
    var cardNames: [String: String] = [:]
    var loading = false
    var loadingMore = false
    var error: String?
    var selectedRecord: TimeRecord?
    var searchText = ""
    
    private let pageSize = 10
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl(), memberId: String? = nil) {
        self.repository = repository
        self.memberId = memberId ?? UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
    }
    
    func loadRecords() async {
        loading = true
        error = nil
        records = []
        
        do {
            let result = try await repository.getRecords(memberId: memberId, limit: pageSize, offset: 0)
            records = result.records
            totalRecords = result.total
            await loadCardNames(for: result.records)
        } catch {
            print("Records load error: \(error)")
            self.error = "Failed to load records"
        }
        
        loading = false
    }
    
    func loadMore() async {
        guard !loadingMore, records.count < totalRecords else { return }
        
        loadingMore = true
        
        do {
            let result = try await repository.getRecords(memberId: memberId, limit: pageSize, offset: records.count)
            records.append(contentsOf: result.records)
            await loadCardNames(for: result.records)
        } catch {
            print("Load more error: \(error)")
        }
        
        loadingMore = false
    }
    
    private func loadCardNames(for newRecords: [TimeRecord]) async {
        let newCardIds = Array(Set(newRecords.map { $0.trelloCardId })).filter { cardNames[$0] == nil }
        if !newCardIds.isEmpty {
            do {
                let names = try await repository.getCardNames(cardIds: newCardIds)
                cardNames.merge(names) { _, new in new }
            } catch {
                print("Failed to load card names: \(error)")
            }
        }
    }
    
    func deleteRecord(_ record: TimeRecord) async {
        do {
            try await repository.deleteRecord(id: record.id)
            records.removeAll { $0.id == record.id }
            totalRecords -= 1
        } catch {
            self.error = "Failed to delete record"
        }
    }
    
    func filteredRecords() -> [TimeRecord] {
        if searchText.isEmpty { return records }
        return records.filter { record in
            let cardName = cardNames[record.trelloCardId] ?? ""
            return cardName.localizedCaseInsensitiveContains(searchText) ||
                   record.comment?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
    func cardName(for cardId: String) -> String {
        cardNames[cardId] ?? String(cardId.prefix(8)) + "..."
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
