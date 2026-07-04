import Foundation

enum BoardsEndpoint: Endpoint {
    case cardNames(cardIds: [String])
    case cardInfo(cardId: String)
    
    var path: String {
        switch self {
        case .cardNames(let cardIds):
            return "/api/v1/boards/cards?card_ids=\(cardIds.joined(separator: ","))"
        case .cardInfo(let cardId):
            return "/api/v1/boards/card-info?card_id=\(cardId)"
        }
    }
    
    var method: String { "GET" }
    var body: [String: Any]? { nil }
}
