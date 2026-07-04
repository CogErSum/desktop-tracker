import Foundation

class ExportUseCases {
    private let repository: TimeTrackerRepository
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl()) {
        self.repository = repository
    }
    
    func exportCSV(memberId: String) async throws -> URL {
        let data = try await repository.exportCSV(memberId: memberId)
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("time_records_\(Date().timeIntervalSince1970).csv")
        try data.write(to: fileURL)
        return fileURL
    }
    
    func exportJSON(memberId: String) async throws -> URL {
        let data = try await repository.exportJSON(memberId: memberId)
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("time_records_\(Date().timeIntervalSince1970).json")
        try data.write(to: fileURL)
        return fileURL
    }
}