import Foundation

struct TimeRecord: Identifiable, Codable {
    let id: String
    let trelloCardId: String
    let durationSec: Int
    let comment: String?
    let recordDate: Date?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case trelloCardId = "trello_card_id"
        case durationSec = "duration_sec"
        case comment
        case recordDate = "record_date"
        case createdAt = "created_at"
    }
}
