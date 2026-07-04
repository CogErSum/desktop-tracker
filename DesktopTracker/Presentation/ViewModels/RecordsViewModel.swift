import Foundation
import SwiftUI

@MainActor
@Observable
class RecordsViewModel {
    private let repository: TimeTrackerRepository
    private var memberId: String
    
    var records: [TimeRecord] = []
    var cardNames: [String: String] = [:]
    var loading = false
    var error: String?
    var selectedRecord: TimeRecord?
    var searchText = ""
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl(), memberId: String? = nil) {
        self.repository = repository
        self.memberId = memberId ?? UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
    }
    
    func loadRecords() async {
        loading = true
        error = nil
        
        do {
            let fetchedRecords = try await repository.getRecords(memberId: memberId)
            records = fetchedRecords
            
            let cardIds = Array(Set(fetchedRecords.map { $0.trelloCardId }))
            if !cardIds.isEmpty {
                cardNames = try await repository.getCardNames(cardIds: cardIds)
            }
        } catch {
            print("Records load error: \(error)")
            self.error = "Failed to load records"
        }
        
        loading = false
    }
    
    func deleteRecord(_ record: TimeRecord) async {
        do {
            try await repository.deleteRecord(id: record.id)
            records.removeAll { $0.id == record.id }
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
