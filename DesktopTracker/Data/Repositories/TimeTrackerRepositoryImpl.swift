import Foundation

class TimeTrackerRepositoryImpl: TimeTrackerRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func getActiveTimer(memberId: String) async throws -> ActiveTimer? {
        do {
            return try await apiClient.request(TimerEndpoint.getActive, memberId: memberId)
        } catch APIError.serverError(404, _) {
            return nil
        }
    }
    
    func startTimer(memberId: String, cardId: String) async throws -> ActiveTimer {
        let response: [String: ActiveTimer] = try await apiClient.request(
            TimerEndpoint.start(cardId: cardId),
            memberId: memberId
        )
        guard let timer = response["timer"] else {
            throw APIError.decodingError(NSError(domain: "", code: -1))
        }
        return timer
    }
    
    func stopTimer(memberId: String) async throws {
        let _: [String: String] = try await apiClient.request(TimerEndpoint.stop, memberId: memberId)
    }
    
    func getRecords(memberId: String) async throws -> [TimeRecord] {
        return try await apiClient.request(RecordsEndpoint.list, memberId: memberId)
    }
    
    func createRecord(memberId: String, cardId: String, duration: Int, comment: String?, date: String?) async throws -> TimeRecord {
        let durationMin = duration / 60
        return try await apiClient.request(
            RecordsEndpoint.create(cardId: cardId, durationMin: durationMin, date: date ?? "", comment: comment),
            memberId: memberId
        )
    }
    
    func updateRecord(id: String, duration: Int?, comment: String?) async throws -> TimeRecord {
        let durationMin = duration.map { $0 / 60 }
        return try await apiClient.request(
            RecordsEndpoint.update(id: id, durationMin: durationMin, date: nil, comment: comment)
        )
    }
    
    func deleteRecord(id: String) async throws {
        let _: [String: String] = try await apiClient.request(RecordsEndpoint.delete(id: id))
    }
    
    func getDashboard(memberId: String) async throws -> DashboardData {
        return try await apiClient.request(DashboardEndpoint.get, memberId: memberId)
    }
    
    func getDailyStats(memberId: String, startDate: String, endDate: String) async throws -> [DailyStats] {
        return try await apiClient.request(DashboardEndpoint.get, memberId: memberId)
    }
    
    func getWeeklyStats(memberId: String, startDate: String, endDate: String) async throws -> [WeeklyStats] {
        return try await apiClient.request(DashboardEndpoint.get, memberId: memberId)
    }
    
    func getCardNames(cardIds: [String]) async throws -> [String: String] {
        return try await apiClient.request(BoardsEndpoint.cardNames(cardIds: cardIds))
    }
    
    func getCardInfo(cardId: String) async throws -> CardInfo {
        return try await apiClient.request(BoardsEndpoint.cardInfo(cardId: cardId))
    }
    
    func searchCards(query: String) async throws -> [SearchResult] {
        let memberId = UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
        return try await apiClient.request(BoardsEndpoint.search(query: query), memberId: memberId)
    }
    
    func getBoardCards(boardId: String) async throws -> [BoardCard] {
        return try await apiClient.request(BoardsEndpoint.boardCards(boardId: boardId))
    }
    
    func getBoards(memberId: String) async throws -> [Board] {
        return try await apiClient.request(BoardsEndpoint.list, memberId: memberId)
    }
    
    func getEstimate(cardId: String) async throws -> Int? {
        let response: EstimateResponse = try await apiClient.request(EstimatesEndpoint.get(cardId: cardId))
        return response.estimatedMin
    }
    
    func setEstimate(cardId: String, minutes: Int) async throws {
        let _: [String: String] = try await apiClient.request(
            EstimatesEndpoint.set(cardId: cardId, estimatedMin: minutes, comment: nil)
        )
    }
    
    func exportCSV(memberId: String) async throws -> Data {
        return try await apiClient.requestData(ExportEndpoint.csv, memberId: memberId)
    }
    
    func exportJSON(memberId: String) async throws -> Data {
        return try await apiClient.requestData(ExportEndpoint.json, memberId: memberId)
    }
}
