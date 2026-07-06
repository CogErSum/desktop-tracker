import Foundation

struct AuthEndpoint: Endpoint {
    case start
    case status(memberId: String)
    case unlink(memberId: String)
    
    var path: String {
        switch self {
        case .start:
            return "/auth/trello/start"
        case .status(let memberId):
            return "/auth/trello/status?member_id=\(memberId)"
        case .unlink(let memberId):
            return "/auth/trello/unlink?member_id=\(memberId)"
        }
    }
    
    var method: String {
        switch self {
        case .start, .status:
            return "GET"
        case .unlink:
            return "POST"
        }
    }
    
    var body: [String: Any]? { nil }
}

struct AuthStatus: Codable {
    let authorized: Bool
}

struct AuthStartResponse: Codable {
    let authorizationUrl: String
    let requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case authorizationUrl = "authorization_url"
        case requestToken = "request_token"
    }
}
