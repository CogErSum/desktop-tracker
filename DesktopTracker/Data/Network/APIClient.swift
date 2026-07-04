import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    
    private init() {
        self.session = URLSession.shared
    }
    
    private var baseURL: String {
        UserDefaults.standard.string(forKey: "apiBaseURL") ?? "https://timetracker.karkach.tech"
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint, memberId: String? = nil) async throws -> T {
        let url = try endpoint.url(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let memberId = memberId {
            request.setValue(memberId, forHTTPHeaderField: "X-Trello-Member-Id")
        }
        
        if let body = endpoint.body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 409 {
            let conflict = try? JSONDecoder().decode(TimerConflict.self, from: data)
            throw APIError.conflict(conflict)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode, String(data: data, encoding: .utf8))
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func requestData(_ endpoint: Endpoint, memberId: String? = nil) async throws -> Data {
        let url = try endpoint.url(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let memberId = memberId {
            request.setValue(memberId, forHTTPHeaderField: "X-Trello-Member-Id")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode, String(data: data, encoding: .utf8))
        }
        
        return data
    }
}

protocol Endpoint {
    var path: String { get }
    var method: String { get }
    var body: [String: Any]? { get }
    func url(baseURL: String) throws -> URL
}

extension Endpoint {
    var method: String { "GET" }
    var body: [String: Any]? { nil }
    
    func url(baseURL: String) throws -> URL {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        return url
    }
}
