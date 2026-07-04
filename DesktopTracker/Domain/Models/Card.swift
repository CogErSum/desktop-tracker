import Foundation

struct CardInfo: Codable {
    let name: String
    let boardName: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case boardName = "board_name"
    }
}
