import Foundation
import SwiftUI

@MainActor
@Observable
class TimerViewModel {
    private let repository: TimeTrackerRepository
    private var memberId: String
    
    var activeTimer: ActiveTimer?
    var elapsed: Int = 0
    var loading = false
    var error: String?
    var conflictInfo: TimerConflict?
    var activeCardName: String = ""
    
    private var timer: Timer?
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl(), memberId: String? = nil) {
        self.repository = repository
        self.memberId = memberId ?? UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
    }
    
    func checkActiveTimer() async {
        do {
            let timer = try await repository.getActiveTimer(memberId: memberId)
            if let timer = timer {
                activeTimer = timer
                startElapsedTimer()
                await fetchCardName(cardId: timer.trelloCardId)
            } else {
                activeTimer = nil
                stopElapsedTimer()
                activeCardName = ""
            }
        } catch {
            activeTimer = nil
            activeCardName = ""
        }
    }
    
    func startTimer(cardId: String) async {
        loading = true
        error = nil
        conflictInfo = nil
        
        do {
            let timer = try await repository.startTimer(memberId: memberId, cardId: cardId)
            activeTimer = timer
            startElapsedTimer()
            await fetchCardName(cardId: cardId)
        } catch APIError.conflict(let conflict) {
            conflictInfo = conflict
        } catch {
            self.error = "Failed to start timer"
        }
        
        loading = false
    }
    
    func stopTimer() async {
        loading = true
        error = nil
        conflictInfo = nil
        
        do {
            try await repository.stopTimer(memberId: memberId)
            activeTimer = nil
            stopElapsedTimer()
            elapsed = 0
            activeCardName = ""
        } catch {
            self.error = "Failed to stop timer"
        }
        
        loading = false
    }
    
    func stopAndStart(cardId: String) async {
        await stopTimer()
        await startTimer(cardId: cardId)
    }
    
    private func fetchCardName(cardId: String) async {
        do {
            let info = try await repository.getCardInfo(cardId: cardId)
            activeCardName = info.name
        } catch {
            activeCardName = ""
        }
    }
    
    private func startElapsedTimer() {
        stopElapsedTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let startTime = self.activeTimer?.startedAt else { return }
            self.elapsed = Int(Date().timeIntervalSince(startTime))
        }
    }
    
    private func stopElapsedTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func formattedTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
    
    func updateElapsed() {
        guard let startTime = activeTimer?.startedAt else { return }
        elapsed = Int(Date().timeIntervalSince(startTime))
    }
}
