import Foundation
import SwiftUI

@MainActor
@Observable
class StartTimerViewModel {
    private let repository: TimeTrackerRepository
    private var memberId: String
    
    var searchText = ""
    var searchResults: [SearchResult] = []
    var selectedCard: SearchResult?
    var searching = false
    var loading = false
    var error: String?
    var timerStarted = false
    
    private var searchTask: Task<Void, Never>?
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl(), memberId: String? = nil) {
        self.repository = repository
        self.memberId = memberId ?? UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
    }
    
    func debounceSearch(query: String) {
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await searchCards(query: query)
        }
    }
    
    func searchCards(query: String) async {
        searching = true
        error = nil
        
        do {
            searchResults = try await repository.searchCards(query: query)
        } catch {
            print("Search error: \(error)")
            self.error = "Search failed"
        }
        
        searching = false
    }
    
    func selectCard(_ card: SearchResult) {
        selectedCard = card
        searchText = card.name
        searchResults = []
    }
    
    func startTimer() async {
        guard let card = selectedCard else { return }
        
        loading = true
        error = nil
        
        do {
            _ = try await repository.startTimer(memberId: memberId, cardId: card.id)
            timerStarted = true
        } catch APIError.conflict(let conflict) {
            if let conflict = conflict {
                self.error = "Timer already active on: \(conflict.activeCardName)"
            } else {
                self.error = "Timer conflict"
            }
        } catch {
            self.error = "Failed to start timer: \(error.localizedDescription)"
        }
        
        loading = false
    }
}
