import Foundation
import SwiftUI

@Observable
class ManualEntryViewModel {
    private let repository: TimeTrackerRepository
    private let memberId: String
    
    var cardId = ""
    var durationHours = 0
    var durationMinutes = 30
    var comment = ""
    var recordDate = Date()
    var loading = false
    var error: String?
    var success = false
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl(), memberId: String = "test-user-1") {
        self.repository = repository
        self.memberId = memberId
    }
    
    func submit() async {
        guard !cardId.isEmpty else {
            error = "Card ID is required"
            return
        }
        
        let totalSeconds = durationHours * 3600 + durationMinutes * 60
        guard totalSeconds > 0 else {
            error = "Duration must be greater than 0"
            return
        }
        
        loading = true
        error = nil
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: recordDate)
        
        do {
            _ = try await repository.createRecord(
                memberId: memberId,
                cardId: cardId,
                duration: totalSeconds,
                comment: comment.isEmpty ? nil : comment,
                date: dateString
            )
            success = true
            resetForm()
        } catch {
            self.error = "Failed to create record"
        }
        
        loading = false
    }
    
    func resetForm() {
        cardId = ""
        durationHours = 0
        durationMinutes = 30
        comment = ""
        recordDate = Date()
    }
}