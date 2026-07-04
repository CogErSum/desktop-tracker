import Foundation

struct ActiveTimer: Identifiable, Codable {
    let id: String
    let trelloCardId: String
    let startedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case trelloCardId = "trello_card_id"
        case startedAt = "started_at"
    }
}

struct TimerConflict: Codable {
    let activeCardId: String
    let activeCardName: String
    let activeBoardName: String
    
    enum CodingKeys: String, CodingKey {
        case activeCardId = "active_card_id"
        case activeCardName = "active_card_name"
        case activeBoardName = "active_board_name"
    }
}
