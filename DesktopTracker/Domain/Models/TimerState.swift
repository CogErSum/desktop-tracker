import Foundation

@MainActor
class TimerState: ObservableObject {
    static let shared = TimerState()
    
    @Published var activeTimer: ActiveTimer?
    @Published var elapsed: Int = 0
    @Published var activeCardName: String = ""
    @Published var loading = false
    @Published var error: String?
    @Published var conflictInfo: TimerConflict?
    
    private let repository: TimeTrackerRepository
    private let memberId: String
    private var timer: Timer?
    private var checkTimer: Timer?
    
    init() {
        self.repository = TimeTrackerRepositoryImpl()
        self.memberId = UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
        startAutoCheck()
    }
    
    private func startAutoCheck() {
        checkTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkActiveTimer(silent: true)
            }
        }
    }
    
    func checkActiveTimer(silent: Bool = false) async {
        do {
            let timer = try await repository.getActiveTimer(memberId: memberId)
            if let timer = timer {
                let changed = activeTimer?.id != timer.id
                activeTimer = timer
                startElapsedTimer()
                if changed {
                    await fetchCardName(cardId: timer.trelloCardId)
                }
            } else {
                activeTimer = nil
                stopElapsedTimer()
                elapsed = 0
                activeCardName = ""
            }
        } catch {
            if !silent {
                activeTimer = nil
                activeCardName = ""
            }
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
            let _ = try await repository.stopTimer(memberId: memberId)
        } catch APIError.serverError(404, _) {
            // Timer already stopped
        } catch {
            self.error = "Failed to stop timer"
        }
        
        activeTimer = nil
        stopElapsedTimer()
        elapsed = 0
        activeCardName = ""
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
            let newElapsed = Int(Date().timeIntervalSince(startTime))
            Task { @MainActor in
                self.elapsed = newElapsed
            }
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
}
