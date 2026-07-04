import Foundation

class TimeTrackerRepositoryImpl: TimeTrackerRepository {
    private let apiClient: APIClient
    private let cache = APICache.shared
    
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
        await cache.invalidateAll()
        return timer
    }
    
    func stopTimer(memberId: String) async throws {
        do {
            let _: [String: String] = try await apiClient.request(TimerEndpoint.stop, memberId: memberId)
        } catch APIError.serverError(404, _) {
            // Timer already stopped
        }
        await cache.invalidateAll()
    }
    
    func getRecords(memberId: String) async throws -> [TimeRecord] {
        let key = "records_\(memberId)"
        if let cached: [TimeRecord] = await cache.get(key) {
            return cached
        }
        let records: [TimeRecord] = try await apiClient.request(RecordsEndpoint.list, memberId: memberId)
        await cache.set(key, data: records)
        return records
    }
    
    func createRecord(memberId: String, cardId: String, duration: Int, comment: String?, date: String?) async throws -> TimeRecord {
        let durationMin = duration / 60
        let record: TimeRecord = try await apiClient.request(
            RecordsEndpoint.create(cardId: cardId, durationMin: durationMin, date: date ?? "", comment: comment),
            memberId: memberId
        )
        await cache.invalidateAll()
        return record
    }
    
    func updateRecord(id: String, duration: Int?, comment: String?) async throws -> TimeRecord {
        let durationMin = duration.map { $0 / 60 }
        let record: TimeRecord = try await apiClient.request(
            RecordsEndpoint.update(id: id, durationMin: durationMin, date: nil, comment: comment)
        )
        await cache.invalidateAll()
        return record
    }
    
    func deleteRecord(id: String) async throws {
        let memberId = UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
        let _: [String: String] = try await apiClient.request(RecordsEndpoint.delete(id: id), memberId: memberId)
        await cache.invalidateAll()
    }
    
    func getDashboard(memberId: String) async throws -> DashboardData {
        let key = "dashboard_\(memberId)"
        if let cached: DashboardData = await cache.get(key) {
            return cached
        }
        let data: DashboardData = try await apiClient.request(DashboardEndpoint.get, memberId: memberId)
        await cache.set(key, data: data)
        return data
    }
    
    func getDailyStats(memberId: String, startDate: String, endDate: String) async throws -> [DailyStats] {
        return try await apiClient.request(DashboardEndpoint.get, memberId: memberId)
    }
    
    func getWeeklyStats(memberId: String, startDate: String, endDate: String) async throws -> [WeeklyStats] {
        return try await apiClient.request(DashboardEndpoint.get, memberId: memberId)
    }
    
    func getCardNames(cardIds: [String]) async throws -> [String: String] {
        let sorted = cardIds.sorted().joined(separator: ",")
        let key = "cardNames_\(sorted.hashValue)"
        if let cached: [String: String] = await cache.get(key) {
            return cached
        }
        let names: [String: String] = try await apiClient.request(BoardsEndpoint.cardNames(cardIds: cardIds))
        await cache.set(key, data: names)
        return names
    }
    
    func getCardInfo(cardId: String) async throws -> CardInfo {
        let key = "cardInfo_\(cardId)"
        if let cached: CardInfo = await cache.get(key) {
            return cached
        }
        let info: CardInfo = try await apiClient.request(BoardsEndpoint.cardInfo(cardId: cardId))
        await cache.set(key, data: info)
        return info
    }
    
    func searchCards(query: String) async throws -> [SearchResult] {
        let memberId = UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
        return try await apiClient.request(BoardsEndpoint.search(query: query), memberId: memberId)
    }
    
    func getBoardCards(boardId: String) async throws -> [BoardCard] {
        return try await apiClient.request(BoardsEndpoint.boardCards(boardId: boardId))
    }
    
    func getBoards(memberId: String) async throws -> [Board] {
        let key = "boards_\(memberId)"
        if let cached: [Board] = await cache.get(key) {
            return cached
        }
        let boards: [Board] = try await apiClient.request(BoardsEndpoint.list, memberId: memberId)
        await cache.set(key, data: boards)
        return boards
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
