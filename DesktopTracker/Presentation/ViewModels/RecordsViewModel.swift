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
    private var loadTask: Task<Void, Never>?
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl(), memberId: String? = nil) {
        self.repository = repository
        self.memberId = memberId ?? UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
    }
    
    func loadRecords() async {
        loadTask?.cancel()
        
        loading = true
        error = nil
        records = []
        
        loadTask = Task {
            do {
                let result = try await repository.getRecords(memberId: memberId, limit: pageSize, offset: 0)
                guard !Task.isCancelled else { return }
                
                let cardIds = Array(Set(result.records.map { $0.trelloCardId }))
                var names: [String: String] = [:]
                if !cardIds.isEmpty {
                    names = try await repository.getCardNames(cardIds: cardIds)
                }
                guard !Task.isCancelled else { return }
                
                records = result.records
                totalRecords = result.total
                cardNames = names
            } catch {
                guard !Task.isCancelled else { return }
                print("Records load error: \(error)")
                self.error = "Failed to load records"
            }
            
            loading = false
        }
        
        await loadTask?.value
    }
    
    func loadMore() async {
        guard !loadingMore, records.count < totalRecords else { return }
        
        loadingMore = true
        
        do {
            let result = try await repository.getRecords(memberId: memberId, limit: pageSize, offset: records.count)
            guard !Task.isCancelled else { return }
            
            let newCardIds = Array(Set(result.records.map { $0.trelloCardId })).filter { cardNames[$0] == nil }
            if !newCardIds.isEmpty {
                let names = try await repository.getCardNames(cardIds: newCardIds)
                cardNames.merge(names) { _, new in new }
            }
            guard !Task.isCancelled else { return }
            
            records.append(contentsOf: result.records)
        } catch {
            print("Load more error: \(error)")
        }
        
        loadingMore = false
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
