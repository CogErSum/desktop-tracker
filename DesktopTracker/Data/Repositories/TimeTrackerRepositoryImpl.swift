import Foundation

class TimeTrackerRepositoryImpl: TimeTrackerRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func getActiveTimer(memberId: String) async throws -> ActiveTimer? {
        do {
            return try await apiClient.request(TimerEndpoint.getActive(memberId: memberId))
        } catch APIError.serverError(404, _) {
            return nil
        }
    }
    
    func startTimer(memberId: String, cardId: String) async throws -> ActiveTimer {
        let response: [String: ActiveTimer] = try await apiClient.request(
            TimerEndpoint.start(memberId: memberId, cardId: cardId)
        )
        guard let timer = response["timer"] else {
            throw APIError.decodingError(NSError(domain: "", code: -1))
        }
        return timer
    }
    
    func stopTimer(memberId: String) async throws {
        let _: [String: String] = try await apiClient.request(TimerEndpoint.stop(memberId: memberId))
    }
    
    func getRecords(memberId: String) async throws -> [TimeRecord] {
        return try await apiClient.request(RecordsEndpoint.list(memberId: memberId))
    }
    
    func createRecord(memberId: String, cardId: String, duration: Int, comment: String?, date: String?) async throws -> TimeRecord {
        return try await apiClient.request(
            RecordsEndpoint.create(memberId: memberId, cardId: cardId, duration: duration, comment: comment, date: date)
        )
    }
    
    func updateRecord(id: String, duration: Int?, comment: String?) async throws -> TimeRecord {
        return try await apiClient.request(RecordsEndpoint.update(id: id, duration: duration, comment: comment))
    }
    
    func deleteRecord(id: String) async throws {
        let _: [String: String] = try await apiClient.request(RecordsEndpoint.delete(id: id))
    }
    
    func getDashboard(memberId: String) async throws -> DashboardData {
        return try await apiClient.request(DashboardEndpoint.get(memberId: memberId))
    }
    
    func getDailyStats(memberId: String, startDate: String, endDate: String) async throws -> [DailyStats] {
        return try await apiClient.request(
            DashboardEndpoint.dailyStats(memberId: memberId, startDate: startDate, endDate: endDate)
        )
    }
    
    func getWeeklyStats(memberId: String, startDate: String, endDate: String) async throws -> [WeeklyStats] {
        return try await apiClient.request(
            DashboardEndpoint.weeklyStats(memberId: memberId, startDate: startDate, endDate: endDate)
        )
    }
    
    func getCardNames(cardIds: [String]) async throws -> [String: String] {
        return try await apiClient.request(BoardsEndpoint.cardNames(cardIds: cardIds))
    }
    
    func getCardInfo(cardId: String) async throws -> CardInfo {
        return try await apiClient.request(BoardsEndpoint.cardInfo(cardId: cardId))
    }
    
    func getEstimate(cardId: String) async throws -> Int? {
        let response: [String: Int?] = try await apiClient.request(EstimatesEndpoint.get(cardId: cardId))
        return response["estimate_minutes"] ?? nil
    }
    
    func setEstimate(cardId: String, minutes: Int) async throws {
        let _: [String: String] = try await apiClient.request(
            EstimatesEndpoint.set(cardId: cardId, estimateMinutes: minutes)
        )
    }
    
    func exportCSV(memberId: String) async throws -> Data {
        let url = try URL(string: "http://localhost:8000/api/export/\(memberId)/csv")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    func exportJSON(memberId: String) async throws -> Data {
        let url = try URL(string: "http://localhost:8000/api/export/\(memberId)/json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
