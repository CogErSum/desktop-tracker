import Foundation

struct TimeRecord: Identifiable, Codable, Hashable {
    let id: String
    let trelloCardId: String
    let durationSec: Int
    let comment: String?
    let recordDate: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case trelloCardId = "trello_card_id"
        case durationSec = "duration_sec"
        case comment
        case recordDate = "record_date"
        case createdAt = "created_at"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TimeRecord, rhs: TimeRecord) -> Bool {
        lhs.id == rhs.id
    }
}
}
