import Foundation

enum BoardsEndpoint: Endpoint {
    case cardNames(cardIds: [String])
    case cardInfo(cardId: String)
    
    var path: String {
        switch self {
        case .cardNames:
            return "/api/boards/card-names"
        case .cardInfo(let cardId):
            return "/api/boards/card/\(cardId)/info"
        }
    }
    
    var method: String { "GET" }
    
    var body: [String: Any]? {
        switch self {
        case .cardNames(let cardIds):
            return ["card_ids": cardIds]
        case .cardInfo:
            return nil
        }
    }
}
