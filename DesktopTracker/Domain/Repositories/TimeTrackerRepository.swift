import Foundation

protocol TimeTrackerRepository {
    func getActiveTimer(memberId: String) async throws -> ActiveTimer?
    func startTimer(memberId: String, cardId: String) async throws -> ActiveTimer
    func stopTimer(memberId: String) async throws
    
    func getRecords(memberId: String) async throws -> [TimeRecord]
    func createRecord(memberId: String, cardId: String, duration: Int, comment: String?, date: String?) async throws -> TimeRecord
    func updateRecord(id: String, duration: Int?, comment: String?) async throws -> TimeRecord
    func deleteRecord(id: String) async throws
    
    func getDashboard(memberId: String) async throws -> DashboardData
    func getDailyStats(memberId: String, startDate: String, endDate: String) async throws -> [DailyStats]
    func getWeeklyStats(memberId: String, startDate: String, endDate: String) async throws -> [WeeklyStats]
    
    func getCardNames(cardIds: [String]) async throws -> [String: String]
    func getCardInfo(cardId: String) async throws -> CardInfo
    func searchCards(query: String) async throws -> [SearchResult]
    func getBoardCards(boardId: String) async throws -> [BoardCard]
    func getBoards(memberId: String) async throws -> [Board]
    
    func getEstimate(cardId: String) async throws -> Int?
    func setEstimate(cardId: String, minutes: Int) async throws
    
    func exportCSV(memberId: String) async throws -> Data
    func exportJSON(memberId: String) async throws -> Data
}
