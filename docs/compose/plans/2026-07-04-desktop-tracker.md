# Desktop Time Tracker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use compose:subagent (recommended) or compose:execute to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a native macOS desktop application for time tracking with full analytics and Trello integration.

**Architecture:** SwiftUI app using MVVM + Clean Architecture, connecting to existing FastAPI backend via REST API. Menu bar utility with standalone window mode.

**Tech Stack:** Swift 5.9+, SwiftUI, Swift Charts, async/await, URLSession

---

## File Structure

```
desktop-tracker/
├── DesktopTracker.xcodeproj
├── DesktopTracker/
│   ├── App/
│   │   ├── DesktopTrackerApp.swift
│   │   └── MenuBarView.swift
│   ├── Presentation/
│   │   ├── Views/
│   │   │   ├── Timer/
│   │   │   │   └── TimerView.swift
│   │   │   ├── Dashboard/
│   │   │   │   ├── DashboardView.swift
│   │   │   │   ├── StatsCard.swift
│   │   │   │   ├── RecentRecords.swift
│   │   │   │   └── Charts/
│   │   │   │       ├── DailyChart.swift
│   │   │   │       ├── WeeklyChart.swift
│   │   │   │       └── MonthlyChart.swift
│   │   │   ├── Records/
│   │   │   │   ├── RecordsView.swift
│   │   │   │   ├── RecordRow.swift
│   │   │   │   └── RecordDetail.swift
│   │   │   ├── ManualEntry/
│   │   │   │   └── ManualEntryView.swift
│   │   │   ├── Settings/
│   │   │   │   └── SettingsView.swift
│   │   │   └── Components/
│   │   │       ├── CardPicker.swift
│   │   │       └── LoadingView.swift
│   │   └── ViewModels/
│   │       ├── TimerViewModel.swift
│   │       ├── DashboardViewModel.swift
│   │       ├── RecordsViewModel.swift
│   │       ├── ManualEntryViewModel.swift
│   │       └── SettingsViewModel.swift
│   ├── Domain/
│   │   ├── UseCases/
│   │   │   ├── TimerUseCases.swift
│   │   │   ├── DashboardUseCases.swift
│   │   │   ├── RecordsUseCases.swift
│   │   │   └── ExportUseCases.swift
│   │   ├── Models/
│   │   │   ├── Timer.swift
│   │   │   ├── Record.swift
│   │   │   ├── Dashboard.swift
│   │   │   └── Card.swift
│   │   └── Repositories/
│   │       └── TimeTrackerRepository.swift
│   ├── Data/
│   │   ├── Network/
│   │   │   ├── APIClient.swift
│   │   │   ├── APIError.swift
│   │   │   └── Endpoints/
│   │   │       ├── TimerEndpoint.swift
│   │   │       ├── RecordsEndpoint.swift
│   │   │       ├── DashboardEndpoint.swift
│   │   │       ├── ExportEndpoint.swift
│   │   │       ├── BoardsEndpoint.swift
│   │   │       └── EstimatesEndpoint.swift
│   │   └── Repositories/
│   │       └── TimeTrackerRepositoryImpl.swift
│   └── Resources/
│       ├── Assets.xcassets/
│       └── Preview Content/
├── docs/
│   └── compose/
│       ├── specs/
│       └── plans/
└── README.md
```

---

### Task 1: Project Setup and Configuration

**Covers:** [S8]

**Files:**
- Create: `DesktopTracker.xcodeproj` (Xcode project)
- Create: `DesktopTracker/App/DesktopTrackerApp.swift`
- Create: `DesktopTracker/Resources/Assets.xcassets`

- [ ] **Step 1: Create Xcode project**

Create new Xcode project:
- Product Name: DesktopTracker
- Organization Identifier: com.teamsight
- Interface: SwiftUI
- Language: Swift
- Location: `/Users/cogersum/PycharmProjects/desktop-tracker`

- [ ] **Step 2: Configure project settings**

Set deployment target to macOS 14.0+ in project settings.

- [ ] **Step 3: Create basic app structure**

```swift
// DesktopTracker/App/DesktopTrackerApp.swift
import SwiftUI

@main
struct DesktopTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

- [ ] **Step 4: Create placeholder ContentView**

```swift
// DesktopTracker/Presentation/Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Desktop Tracker")
            .frame(minWidth: 800, minHeight: 600)
    }
}
```

- [ ] **Step 5: Verify project builds**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: initialize Xcode project with basic structure"
```

---

### Task 2: Domain Models

**Covers:** [S4, S7]

**Files:**
- Create: `DesktopTracker/Domain/Models/Timer.swift`
- Create: `DesktopTracker/Domain/Models/Record.swift`
- Create: `DesktopTracker/Domain/Models/Dashboard.swift`
- Create: `DesktopTracker/Domain/Models/Card.swift`

- [ ] **Step 1: Create Timer model**

```swift
// DesktopTracker/Domain/Models/Timer.swift
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
```

- [ ] **Step 2: Create Record model**

```swift
// DesktopTracker/Domain/Models/Record.swift
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
```

- [ ] **Step 3: Create Dashboard model**

```swift
// DesktopTracker/Domain/Models/Dashboard.swift
import Foundation

struct DashboardData: Codable {
    let todaySec: Int
    let weekSec: Int
    let monthSec: Int
    let recentRecords: [TimeRecord]
    
    enum CodingKeys: String, CodingKey {
        case todaySec = "today_sec"
        case weekSec = "week_sec"
        case monthSec = "month_sec"
        case recentRecords = "recent_records"
    }
}

struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let totalSeconds: Int
}

struct WeeklyStats: Identifiable {
    let id = UUID()
    let weekStart: Date
    let totalSeconds: Int
}
```

- [ ] **Step 4: Create Card model**

```swift
// DesktopTracker/Domain/Models/Card.swift
import Foundation

struct CardInfo: Codable {
    let name: String
    let boardName: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case boardName = "board_name"
    }
}
```

- [ ] **Step 5: Verify models compile**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Commit**

```bash
git add DesktopTracker/Domain/Models/
git commit -m "feat: add domain models for Timer, Record, Dashboard, Card"
```

---

### Task 3: API Client and Endpoints

**Covers:** [S7]

**Files:**
- Create: `DesktopTracker/Data/Network/APIClient.swift`
- Create: `DesktopTracker/Data/Network/APIError.swift`
- Create: `DesktopTracker/Data/Network/Endpoints/TimerEndpoint.swift`
- Create: `DesktopTracker/Data/Network/Endpoints/RecordsEndpoint.swift`
- Create: `DesktopTracker/Data/Network/Endpoints/DashboardEndpoint.swift`
- Create: `DesktopTracker/Data/Network/Endpoints/ExportEndpoint.swift`
- Create: `DesktopTracker/Data/Network/Endpoints/BoardsEndpoint.swift`
- Create: `DesktopTracker/Data/Network/Endpoints/EstimatesEndpoint.swift`

- [ ] **Step 1: Create APIError**

```swift
// DesktopTracker/Data/Network/APIError.swift
import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int, String?)
    case conflict(TimerConflict?)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error \(code): \(message ?? "Unknown")"
        case .conflict(let conflict):
            if let conflict = conflict {
                return "Timer already active on: \(conflict.activeCardName)"
            }
            return "Timer conflict"
        }
    }
}
```

- [ ] **Step 2: Create APIClient**

```swift
// DesktopTracker/Data/Network/APIClient.swift
import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    
    private init() {
        self.baseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? "http://localhost:8000"
        self.session = URLSession.shared
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let url = try endpoint.url(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = endpoint.body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidURL
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
```

- [ ] **Step 3: Create TimerEndpoint**

```swift
// DesktopTracker/Data/Network/Endpoints/TimerEndpoint.swift
import Foundation

enum TimerEndpoint: Endpoint {
    case getActive(memberId: String)
    case start(memberId: String, cardId: String)
    case stop(memberId: String)
    
    var path: String {
        switch self {
        case .getActive(let memberId):
            return "/api/timers/\(memberId)/active"
        case .start(let memberId, _):
            return "/api/timers/\(memberId)/start"
        case .stop(let memberId):
            return "/api/timers/\(memberId)/stop"
        }
    }
    
    var method: String {
        switch self {
        case .getActive:
            return "GET"
        case .start, .stop:
            return "POST"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .start(_, let cardId):
            return ["trello_card_id": cardId]
        case .stop:
            return nil
        case .getActive:
            return nil
        }
    }
}
```

- [ ] **Step 4: Create RecordsEndpoint**

```swift
// DesktopTracker/Data/Network/Endpoints/RecordsEndpoint.swift
import Foundation

enum RecordsEndpoint: Endpoint {
    case list(memberId: String)
    case create(memberId: String, cardId: String, duration: Int, comment: String?, date: String?)
    case update(id: String, duration: Int?, comment: String?)
    case delete(id: String)
    
    var path: String {
        switch self {
        case .list(let memberId):
            return "/api/records/\(memberId)"
        case .create(let memberId, _, _, _, _):
            return "/api/records/\(memberId)"
        case .update(let id, _, _):
            return "/api/records/\(id)"
        case .delete(let id):
            return "/api/records/\(id)"
        }
    }
    
    var method: String {
        switch self {
        case .list:
            return "GET"
        case .create:
            return "POST"
        case .update:
            return "PUT"
        case .delete:
            return "DELETE"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .create(_, let cardId, let duration, let comment, let date):
            var dict: [String: Any] = [
                "trello_card_id": cardId,
                "duration_sec": duration
            ]
            if let comment = comment { dict["comment"] = comment }
            if let date = date { dict["record_date"] = date }
            return dict
        case .update(_, let duration, let comment):
            var dict: [String: Any] = [:]
            if let duration = duration { dict["duration_sec"] = duration }
            if let comment = comment { dict["comment"] = comment }
            return dict
        case .delete, .list:
            return nil
        }
    }
}
```

- [ ] **Step 5: Create DashboardEndpoint**

```swift
// DesktopTracker/Data/Network/Endpoints/DashboardEndpoint.swift
import Foundation

enum DashboardEndpoint: Endpoint {
    case get(memberId: String)
    case dailyStats(memberId: String, startDate: String, endDate: String)
    case weeklyStats(memberId: String, startDate: String, endDate: String)
    
    var path: String {
        switch self {
        case .get(let memberId):
            return "/api/dashboard/\(memberId)"
        case .dailyStats(let memberId, _, _):
            return "/api/dashboard/\(memberId)/daily"
        case .weeklyStats(let memberId, _, _):
            return "/api/dashboard/\(memberId)/weekly"
        }
    }
    
    var method: String { "GET" }
    
    var body: [String: Any]? { nil }
}
```

- [ ] **Step 6: Create ExportEndpoint**

```swift
// DesktopTracker/Data/Network/Endpoints/ExportEndpoint.swift
import Foundation

enum ExportEndpoint: Endpoint {
    case csv(memberId: String)
    case json(memberId: String)
    
    var path: String {
        switch self {
        case .csv(let memberId):
            return "/api/export/\(memberId)/csv"
        case .json(let memberId):
            return "/api/export/\(memberId)/json"
        }
    }
    
    var method: String { "GET" }
    var body: [String: Any]? { nil }
}
```

- [ ] **Step 7: Create BoardsEndpoint**

```swift
// DesktopTracker/Data/Network/Endpoints/BoardsEndpoint.swift
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
```

- [ ] **Step 8: Create EstimatesEndpoint**

```swift
// DesktopTracker/Data/Network/Endpoints/EstimatesEndpoint.swift
import Foundation

enum EstimatesEndpoint: Endpoint {
    case get(cardId: String)
    case set(cardId: String, estimateMinutes: Int)
    
    var path: String {
        switch self {
        case .get(let cardId):
            return "/api/estimates/\(cardId)"
        case .set(let cardId, _):
            return "/api/estimates/\(cardId)"
        }
    }
    
    var method: String {
        switch self {
        case .get:
            return "GET"
        case .set:
            return "POST"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .set(_, let minutes):
            return ["estimate_minutes": minutes]
        case .get:
            return nil
        }
    }
}
```

- [ ] **Step 9: Verify network layer compiles**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 10: Commit**

```bash
git add DesktopTracker/Data/Network/
git commit -m "feat: add API client and endpoint definitions"
```

---

### Task 4: Repository Layer

**Covers:** [S7]

**Files:**
- Create: `DesktopTracker/Domain/Repositories/TimeTrackerRepository.swift`
- Create: `DesktopTracker/Data/Repositories/TimeTrackerRepositoryImpl.swift`

- [ ] **Step 1: Create repository protocol**

```swift
// DesktopTracker/Domain/Repositories/TimeTrackerRepository.swift
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
    
    func getEstimate(cardId: String) async throws -> Int?
    func setEstimate(cardId: String, minutes: Int) async throws
    
    func exportCSV(memberId: String) async throws -> Data
    func exportJSON(memberId: String) async throws -> Data
}
```

- [ ] **Step 2: Create repository implementation**

```swift
// DesktopTracker/Data/Repositories/TimeTrackerRepositoryImpl.swift
import Foundation

class TimeTrackerRepositoryImpl: TimeTrackerRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func getActiveTimer(memberId: String) async throws -> ActiveTimer? {
        do {
            return try await apiClient.request(TimerEndpoint.getActive(memberId: memberId))
        } catch APIError.serverError(404, _) {
            return nil
        }
    }
    
    func startTimer(memberId: String, cardId: String) async throws -> ActiveTimer {
        let response: [String: ActiveTimer] = try await apiClient.request(
            TimerEndpoint.start(memberId: memberId, cardId: cardId)
        )
        guard let timer = response["timer"] else {
            throw APIError.decodingError(NSError(domain: "", code: -1))
        }
        return timer
    }
    
    func stopTimer(memberId: String) async throws {
        let _: [String: String] = try await apiClient.request(TimerEndpoint.stop(memberId: memberId))
    }
    
    func getRecords(memberId: String) async throws -> [TimeRecord] {
        return try await apiClient.request(RecordsEndpoint.list(memberId: memberId))
    }
    
    func createRecord(memberId: String, cardId: String, duration: Int, comment: String?, date: String?) async throws -> TimeRecord {
        return try await apiClient.request(
            RecordsEndpoint.create(memberId: memberId, cardId: cardId, duration: duration, comment: comment, date: date)
        )
    }
    
    func updateRecord(id: String, duration: Int?, comment: String?) async throws -> TimeRecord {
        return try await apiClient.request(RecordsEndpoint.update(id: id, duration: duration, comment: comment))
    }
    
    func deleteRecord(id: String) async throws {
        let _: [String: String] = try await apiClient.request(RecordsEndpoint.delete(id: id))
    }
    
    func getDashboard(memberId: String) async throws -> DashboardData {
        return try await apiClient.request(DashboardEndpoint.get(memberId: memberId))
    }
    
    func getDailyStats(memberId: String, startDate: String, endDate: String) async throws -> [DailyStats] {
        return try await apiClient.request(
            DashboardEndpoint.dailyStats(memberId: memberId, startDate: startDate, endDate: endDate)
        )
    }
    
    func getWeeklyStats(memberId: String, startDate: String, endDate: String) async throws -> [WeeklyStats] {
        return try await apiClient.request(
            DashboardEndpoint.weeklyStats(memberId: memberId, startDate: startDate, endDate: endDate)
        )
    }
    
    func getCardNames(cardIds: [String]) async throws -> [String: String] {
        return try await apiClient.request(BoardsEndpoint.cardNames(cardIds: cardIds))
    }
    
    func getCardInfo(cardId: String) async throws -> CardInfo {
        return try await apiClient.request(BoardsEndpoint.cardInfo(cardId: cardId))
    }
    
    func getEstimate(cardId: String) async throws -> Int? {
        let response: [String: Int?] = try await apiClient.request(EstimatesEndpoint.get(cardId: cardId))
        return response["estimate_minutes"] ?? nil
    }
    
    func setEstimate(cardId: String, minutes: Int) async throws {
        let _: [String: String] = try await apiClient.request(
            EstimatesEndpoint.set(cardId: cardId, estimateMinutes: minutes)
        )
    }
    
    func exportCSV(memberId: String) async throws -> Data {
        let url = try URL(string: "http://localhost:8000/api/export/\(memberId)/csv")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    func exportJSON(memberId: String) async throws -> Data {
        let url = try URL(string: "http://localhost:8000/api/export/\(memberId)/json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
```

- [ ] **Step 3: Verify repository compiles**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add DesktopTracker/Domain/Repositories/ DesktopTracker/Data/Repositories/
git commit -m "feat: add repository layer with protocol and implementation"
```

---

### Task 5: Timer ViewModel and View

**Covers:** [S4]

**Files:**
- Create: `DesktopTracker/Presentation/ViewModels/TimerViewModel.swift`
- Create: `DesktopTracker/Presentation/Views/Timer/TimerView.swift`

- [ ] **Step 1: Create TimerViewModel**

```swift
// DesktopTracker/Presentation/ViewModels/TimerViewModel.swift
import Foundation
import SwiftUI

@Observable
class TimerViewModel {
    private let repository: TimeTrackerRepository
    private let memberId: String
    
    var activeTimer: ActiveTimer?
    var elapsed: Int = 0
    var loading = false
    var error: String?
    var conflictInfo: TimerConflict?
    
    private var timer: Timer?
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl(), memberId: String = "test-user-1") {
        self.repository = repository
        self.memberId = memberId
    }
    
    func checkActiveTimer() async {
        do {
            let timer = try await repository.getActiveTimer(memberId: memberId)
            if let timer = timer {
                activeTimer = timer
                startElapsedTimer()
            } else {
                activeTimer = nil
                stopElapsedTimer()
            }
        } catch {
            activeTimer = nil
        }
    }
    
    func startTimer(cardId: String) async {
        loading = true
        error = nil
        conflictInfo = nil
        
        do {
            let timer = try await repository.startTimer(memberId: memberId, cardId: cardId)
            activeTimer = timer
            startElapsedTimer()
        } catch APIError.conflict(let conflict) {
            conflictInfo = conflict
        } catch {
            self.error = "Failed to start timer"
        }
        
        loading = false
    }
    
    func stopTimer() async {
        loading = true
        error = nil
        conflictInfo = nil
        
        do {
            try await repository.stopTimer(memberId: memberId)
            activeTimer = nil
            stopElapsedTimer()
            elapsed = 0
        } catch {
            self.error = "Failed to stop timer"
        }
        
        loading = false
    }
    
    func stopAndStart(cardId: String) async {
        await stopTimer()
        await startTimer(cardId: cardId)
    }
    
    private func startElapsedTimer() {
        stopElapsedTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let startTime = self.activeTimer?.startedAt else { return }
            self.elapsed = Int(Date().timeIntervalSince(startTime))
        }
    }
    
    private func stopElapsedTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func formattedTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
```

- [ ] **Step 2: Create TimerView**

```swift
// DesktopTracker/Presentation/Views/Timer/TimerView.swift
import SwiftUI

struct TimerView: View {
    @State private var viewModel = TimerViewModel()
    let cardId: String
    
    var body: some View {
        VStack(spacing: 16) {
            if let timer = viewModel.activeTimer {
                activeTimerView(timer)
            } else if let conflict = viewModel.conflictInfo {
                conflictView(conflict)
            } else {
                idleView
            }
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .task {
            await viewModel.checkActiveTimer()
        }
    }
    
    private func activeTimerView(_ timer: ActiveTimer) -> some View {
        HStack {
            Text(viewModel.formattedTime(viewModel.elapsed))
                .font(.system(.title, design: .monospaced))
                .foregroundColor(.green)
            
            Button("Stop") {
                Task { await viewModel.stopTimer() }
            }
            .disabled(viewModel.loading)
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
    }
    
    private func conflictView(_ conflict: TimerConflict) -> some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                VStack(alignment: .leading) {
                    Text(conflict.activeCardName)
                        .font(.headline)
                    Text(conflict.activeBoardName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button("Stop & Start Here") {
                Task { await viewModel.stopAndStart(cardId: cardId) }
            }
            .disabled(viewModel.loading)
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
    }
    
    private var idleView: some View {
        HStack {
            Text("No active timer")
                .foregroundColor(.secondary)
            
            Button("Start") {
                Task { await viewModel.startTimer(cardId: cardId) }
            }
            .disabled(viewModel.loading)
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }
}
```

- [ ] **Step 3: Verify TimerView compiles**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add DesktopTracker/Presentation/ViewModels/TimerViewModel.swift DesktopTracker/Presentation/Views/Timer/
git commit -m "feat: add TimerViewModel and TimerView with conflict handling"
```

---

### Task 6: Dashboard ViewModel and View

**Covers:** [S4, S5]

**Files:**
- Create: `DesktopTracker/Presentation/ViewModels/DashboardViewModel.swift`
- Create: `DesktopTracker/Presentation/Views/Dashboard/DashboardView.swift`
- Create: `DesktopTracker/Presentation/Views/Dashboard/StatsCard.swift`
- Create: `DesktopTracker/Presentation/Views/Dashboard/RecentRecords.swift`

- [ ] **Step 1: Create DashboardViewModel**

```swift
// DesktopTracker/Presentation/ViewModels/DashboardViewModel.swift
import Foundation
import SwiftUI

@Observable
class DashboardViewModel {
    private let repository: TimeTrackerRepository
    private let memberId: String
    
    var dashboardData: DashboardData?
    var dailyStats: [DailyStats] = []
    var weeklyStats: [WeeklyStats] = []
    var cardNames: [String: String] = [:]
    var loading = false
    var error: String?
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl(), memberId: String = "test-user-1") {
        self.repository = repository
        self.memberId = memberId
    }
    
    func loadDashboard() async {
        loading = true
        error = nil
        
        do {
            dashboardData = try await repository.getDashboard(memberId: memberId)
            
            if let records = dashboardData?.recentRecords {
                let cardIds = Array(Set(records.map { $0.trelloCardId }))
                if !cardIds.isEmpty {
                    cardNames = try await repository.getCardNames(cardIds: cardIds)
                }
            }
        } catch {
            self.error = "Failed to load dashboard"
        }
        
        loading = false
    }
    
    func loadDailyStats(startDate: Date, endDate: Date) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        do {
            dailyStats = try await repository.getDailyStats(
                memberId: memberId,
                startDate: formatter.string(from: startDate),
                endDate: formatter.string(from: endDate)
            )
        } catch {
            print("Failed to load daily stats: \(error)")
        }
    }
    
    func loadWeeklyStats(startDate: Date, endDate: Date) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        do {
            weeklyStats = try await repository.getWeeklyStats(
                memberId: memberId,
                startDate: formatter.string(from: startDate),
                endDate: formatter.string(from: endDate)
            )
        } catch {
            print("Failed to load weekly stats: \(error)")
        }
    }
    
    func cardName(for cardId: String) -> String {
        cardNames[cardId] ?? String(cardId.prefix(8)) + "..."
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }
}
```

- [ ] **Step 2: Create StatsCard**

```swift
// DesktopTracker/Presentation/Views/Dashboard/StatsCard.swift
import SwiftUI

struct StatsCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }
}
```

- [ ] **Step 3: Create RecentRecords**

```swift
// DesktopTracker/Presentation/Views/Dashboard/RecentRecords.swift
import SwiftUI

struct RecentRecords: View {
    let records: [TimeRecord]
    let cardNames: [String: String]
    let formatDuration: (Int) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Activity")
                .font(.headline)
            
            if records.isEmpty {
                Text("No records yet. Start tracking time on a card!")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Table(records) {
                    TableColumn("Date") { record in
                        Text(formatDate(record.recordDate ?? record.createdAt))
                    }
                    .width(min: 80, ideal: 100)
                    
                    TableColumn("Duration") { record in
                        Text(formatDuration(record.durationSec))
                            .fontWeight(.semibold)
                    }
                    .width(min: 60, ideal: 80)
                    
                    TableColumn("Card") { record in
                        Text(cardNames[record.trelloCardId] ?? String(record.trelloCardId.prefix(8)))
                            .foregroundColor(.accentColor)
                    }
                    
                    TableColumn("Note") { record in
                        Text(record.comment ?? "—")
                            .foregroundColor(record.comment != nil ? .primary : .secondary)
                            .italic(record.comment == nil)
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
}
```

- [ ] **Step 4: Create DashboardView**

```swift
// DesktopTracker/Presentation/Views/Dashboard/DashboardView.swift
import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.loading {
                    ProgressView()
                } else if let data = viewModel.dashboardData {
                    statsSection(data)
                    RecentRecords(
                        records: data.recentRecords,
                        cardNames: viewModel.cardNames,
                        formatDuration: viewModel.formatDuration
                    )
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .task {
            await viewModel.loadDashboard()
        }
    }
    
    private func statsSection(_ data: DashboardData) -> some View {
        HStack(spacing: 16) {
            StatsCard(title: "Today", value: viewModel.formatDuration(data.todaySec))
            StatsCard(title: "This Week", value: viewModel.formatDuration(data.weekSec))
            StatsCard(title: "This Month", value: viewModel.formatDuration(data.monthSec))
        }
    }
}
```

- [ ] **Step 5: Verify DashboardView compiles**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Commit**

```bash
git add DesktopTracker/Presentation/ViewModels/DashboardViewModel.swift DesktopTracker/Presentation/Views/Dashboard/
git commit -m "feat: add DashboardViewModel and DashboardView with stats cards"
```

---

### Task 7: Charts for Analytics

**Covers:** [S5]

**Files:**
- Create: `DesktopTracker/Presentation/Views/Dashboard/Charts/DailyChart.swift`
- Create: `DesktopTracker/Presentation/Views/Dashboard/Charts/WeeklyChart.swift`
- Create: `DesktopTracker/Presentation/Views/Dashboard/Charts/MonthlyChart.swift`

- [ ] **Step 1: Create DailyChart**

```swift
// DesktopTracker/Presentation/Views/Dashboard/Charts/DailyChart.swift
import SwiftUI
import Charts

struct DailyChart: View {
    let data: [DailyStats]
    
    var body: some View {
        Chart(data) { stat in
            BarMark(
                x: .value("Date", stat.date, unit: .day),
                y: .value("Hours", Double(stat.totalSeconds) / 3600.0)
            )
            .foregroundStyle(.blue.gradient)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisValueLabel { value in
                    Text("\(value, format: .number.precision(.fractionLength(1)))h")
                }
            }
        }
        .frame(height: 200)
    }
}
```

- [ ] **Step 2: Create WeeklyChart**

```swift
// DesktopTracker/Presentation/Views/Dashboard/Charts/WeeklyChart.swift
import SwiftUI
import Charts

struct WeeklyChart: View {
    let data: [WeeklyStats]
    
    var body: some View {
        Chart(data) { stat in
            LineMark(
                x: .value("Week", stat.weekStart, unit: .weekOfYear),
                y: .value("Hours", Double(stat.totalSeconds) / 3600.0)
            )
            .foregroundStyle(.green)
            .symbol(.circle)
            .symbolSize(60)
            
            AreaMark(
                x: .value("Week", stat.weekStart, unit: .weekOfYear),
                y: .value("Hours", Double(stat.totalSeconds) / 3600.0)
            )
            .foregroundStyle(.green.opacity(0.1))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekOfYear().month(.abbreviated))
            }
        }
        .frame(height: 200)
    }
}
```

- [ ] **Step 3: Create MonthlyChart**

```swift
// DesktopTracker/Presentation/Views/Dashboard/Charts/MonthlyChart.swift
import SwiftUI
import Charts

struct MonthlyChart: View {
    let data: [DailyStats]
    
    var body: some View {
        Chart(data) { stat in
            AreaMark(
                x: .value("Date", stat.date, unit: .day),
                y: .value("Hours", Double(stat.totalSeconds) / 3600.0)
            )
            .foregroundStyle(.purple.gradient)
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfMonth)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .frame(height: 200)
    }
}
```

- [ ] **Step 4: Verify Charts compile**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 5: Commit**

```bash
git add DesktopTracker/Presentation/Views/Dashboard/Charts/
git commit -m "feat: add Swift Charts for daily, weekly, monthly analytics"
```

---

### Task 8: Records Management View

**Covers:** [S4]

**Files:**
- Create: `DesktopTracker/Presentation/ViewModels/RecordsViewModel.swift`
- Create: `DesktopTracker/Presentation/Views/Records/RecordsView.swift`
- Create: `DesktopTracker/Presentation/Views/Records/RecordRow.swift`
- Create: `DesktopTracker/Presentation/Views/Records/RecordDetail.swift`

- [ ] **Step 1: Create RecordsViewModel**

```swift
// DesktopTracker/Presentation/ViewModels/RecordsViewModel.swift
import Foundation
import SwiftUI

@Observable
class RecordsViewModel {
    private let repository: TimeTrackerRepository
    private let memberId: String
    
    var records: [TimeRecord] = []
    var cardNames: [String: String] = [:]
    var loading = false
    var error: String?
    var selectedRecord: TimeRecord?
    var searchText = ""
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl(), memberId: String = "test-user-1") {
        self.repository = repository
        self.memberId = memberId
    }
    
    func loadRecords() async {
        loading = true
        error = nil
        
        do {
            records = try await repository.getRecords(memberId: memberId)
            let cardIds = Array(Set(records.map { $0.trelloCardId }))
            if !cardIds.isEmpty {
                cardNames = try await repository.getCardNames(cardIds: cardIds)
            }
        } catch {
            self.error = "Failed to load records"
        }
        
        loading = false
    }
    
    func deleteRecord(_ record: TimeRecord) async {
        do {
            try await repository.deleteRecord(id: record.id)
            records.removeAll { $0.id == record.id }
        } catch {
            self.error = "Failed to delete record"
        }
    }
    
    func filteredRecords() -> [TimeRecord] {
        if searchText.isEmpty { return records }
        return records.filter { record in
            let cardName = cardNames[record.trelloCardId] ?? ""
            return cardName.localizedCaseInsensitiveContains(searchText) ||
                   record.comment?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
    func cardName(for cardId: String) -> String {
        cardNames[cardId] ?? String(cardId.prefix(8)) + "..."
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
```

- [ ] **Step 2: Create RecordRow**

```swift
// DesktopTracker/Presentation/Views/Records/RecordRow.swift
import SwiftUI

struct RecordRow: View {
    let record: TimeRecord
    let cardName: String
    let formatDuration: (Int) -> String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(cardName)
                    .font(.headline)
                Text(record.recordDate ?? record.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(formatDuration(record.durationSec))
                    .font(.title3)
                    .fontWeight(.semibold)
                if let comment = record.comment {
                    Text(comment)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
```

- [ ] **Step 3: Create RecordDetail**

```swift
// DesktopTracker/Presentation/Views/Records/RecordDetail.swift
import SwiftUI

struct RecordDetail: View {
    let record: TimeRecord
    let cardName: String
    let formatDuration: (Int) -> String
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text(cardName)
                .font(.title2)
                .fontWeight(.bold)
            
            Group {
                detailRow(label: "Duration", value: formatDuration(record.durationSec))
                detailRow(label: "Date", value: formatDate(record.recordDate ?? record.createdAt))
                if let comment = record.comment {
                    detailRow(label: "Comment", value: comment)
                }
            }
            
            Spacer()
            
            Button("Delete Record", role: .destructive) {
                onDelete()
                dismiss()
            }
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
```

- [ ] **Step 4: Create RecordsView**

```swift
// DesktopTracker/Presentation/Views/Records/RecordsView.swift
import SwiftUI

struct RecordsView: View {
    @State private var viewModel = RecordsViewModel()
    @State private var selectedRecord: TimeRecord?
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search records...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
                
                Spacer()
                
                Button("Refresh") {
                    Task { await viewModel.loadRecords() }
                }
            }
            .padding()
            
            if viewModel.loading {
                ProgressView()
            } else if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
            } else {
                List(viewModel.filteredRecords(), selection: $selectedRecord) { record in
                    RecordRow(
                        record: record,
                        cardName: viewModel.cardName(for: record.trelloCardId),
                        formatDuration: viewModel.formatDuration
                    )
                    .tag(record)
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            Task { await viewModel.deleteRecord(record) }
                        }
                    }
                }
            }
        }
        .navigationTitle("Records")
        .task {
            await viewModel.loadRecords()
        }
        .sheet(item: $selectedRecord) { record in
            RecordDetail(
                record: record,
                cardName: viewModel.cardName(for: record.trelloCardId),
                formatDuration: viewModel.formatDuration,
                onDelete: {
                    Task { await viewModel.deleteRecord(record) }
                }
            )
        }
    }
}
```

- [ ] **Step 5: Verify RecordsView compiles**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Commit**

```bash
git add DesktopTracker/Presentation/ViewModels/RecordsViewModel.swift DesktopTracker/Presentation/Views/Records/
git commit -m "feat: add RecordsView with search, delete, and detail sheet"
```

---

### Task 9: Manual Entry View

**Covers:** [S4]

**Files:**
- Create: `DesktopTracker/Presentation/ViewModels/ManualEntryViewModel.swift`
- Create: `DesktopTracker/Presentation/Views/ManualEntry/ManualEntryView.swift`

- [ ] **Step 1: Create ManualEntryViewModel**

```swift
// DesktopTracker/Presentation/ViewModels/ManualEntryViewModel.swift
import Foundation
import SwiftUI

@Observable
class ManualEntryViewModel {
    private let repository: TimeTrackerRepository
    private let memberId: String
    
    var cardId = ""
    var durationHours = 0
    var durationMinutes = 30
    var comment = ""
    var recordDate = Date()
    var loading = false
    var error: String?
    var success = false
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl(), memberId: String = "test-user-1") {
        self.repository = repository
        self.memberId = memberId
    }
    
    func submit() async {
        guard !cardId.isEmpty else {
            error = "Card ID is required"
            return
        }
        
        let totalSeconds = durationHours * 3600 + durationMinutes * 60
        guard totalSeconds > 0 else {
            error = "Duration must be greater than 0"
            return
        }
        
        loading = true
        error = nil
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: recordDate)
        
        do {
            _ = try await repository.createRecord(
                memberId: memberId,
                cardId: cardId,
                duration: totalSeconds,
                comment: comment.isEmpty ? nil : comment,
                date: dateString
            )
            success = true
            resetForm()
        } catch {
            self.error = "Failed to create record"
        }
        
        loading = false
    }
    
    func resetForm() {
        cardId = ""
        durationHours = 0
        durationMinutes = 30
        comment = ""
        recordDate = Date()
    }
}
```

- [ ] **Step 2: Create ManualEntryView**

```swift
// DesktopTracker/Presentation/Views/ManualEntry/ManualEntryView.swift
import SwiftUI

struct ManualEntryView: View {
    @State private var viewModel = ManualEntryViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            TextField("Card ID", text: $viewModel.cardId)
            
            HStack {
                Picker("Hours", selection: $viewModel.durationHours) {
                    ForEach(0..<24) { hour in
                        Text("\(hour)h").tag(hour)
                    }
                }
                .frame(width: 80)
                
                Picker("Minutes", selection: $viewModel.durationMinutes) {
                    ForEach(0..<60) { minute in
                        Text("\(minute)m").tag(minute)
                    }
                }
                .frame(width: 80)
            }
            
            DatePicker("Date", selection: $viewModel.recordDate, displayedComponents: .date)
            
            TextField("Comment (optional)", text: $viewModel.comment)
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }
            
            if viewModel.success {
                Text("Record created!")
                    .foregroundColor(.green)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Button("Add Record") {
                    Task { await viewModel.submit() }
                }
                .disabled(viewModel.loading)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(minWidth: 350, minHeight: 280)
        .navigationTitle("Manual Entry")
    }
}
```

- [ ] **Step 3: Verify ManualEntryView compiles**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add DesktopTracker/Presentation/ViewModels/ManualEntryViewModel.swift DesktopTracker/Presentation/Views/ManualEntry/
git commit -m "feat: add ManualEntryView with form validation"
```

---

### Task 10: Settings View

**Covers:** [S6]

**Files:**
- Create: `DesktopTracker/Presentation/ViewModels/SettingsViewModel.swift`
- Create: `DesktopTracker/Presentation/Views/Settings/SettingsView.swift`

- [ ] **Step 1: Create SettingsViewModel**

```swift
// DesktopTracker/Presentation/ViewModels/SettingsViewModel.swift
import Foundation
import SwiftUI

@Observable
class SettingsViewModel {
    var apiBaseURL: String
    var memberId: String
    var showMenuBarIcon: Bool
    
    init() {
        self.apiBaseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? "http://localhost:8000"
        self.memberId = UserDefaults.standard.string(forKey: "memberId") ?? "test-user-1"
        self.showMenuBarIcon = UserDefaults.standard.bool(forKey: "showMenuBarIcon")
    }
    
    func save() {
        UserDefaults.standard.set(apiBaseURL, forKey: "apiBaseURL")
        UserDefaults.standard.set(memberId, forKey: "memberId")
        UserDefaults.standard.set(showMenuBarIcon, forKey: "showMenuBarIcon")
    }
}
```

- [ ] **Step 2: Create SettingsView**

```swift
// DesktopTracker/Presentation/Views/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var saved = false
    
    var body: some View {
        Form {
            Section("API Configuration") {
                TextField("API Base URL", text: $viewModel.apiBaseURL)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Member ID", text: $viewModel.memberId)
                    .textFieldStyle(.roundedBorder)
            }
            
            Section("Appearance") {
                Toggle("Show Menu Bar Icon", isOn: $viewModel.showMenuBarIcon)
            }
            
            if saved {
                Text("Settings saved!")
                    .foregroundColor(.green)
            }
            
            HStack {
                Spacer()
                Button("Save") {
                    viewModel.save()
                    saved = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        saved = false
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 250)
        .navigationTitle("Settings")
    }
}
```

- [ ] **Step 3: Verify SettingsView compiles**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add DesktopTracker/Presentation/ViewModels/SettingsViewModel.swift DesktopTracker/Presentation/Views/Settings/
git commit -m "feat: add SettingsView with API and appearance configuration"
```

---

### Task 11: Main App and Navigation

**Covers:** [S6]

**Files:**
- Modify: `DesktopTracker/App/DesktopTrackerApp.swift`
- Create: `DesktopTracker/Presentation/Views/ContentView.swift`

- [ ] **Step 1: Update DesktopTrackerApp**

```swift
// DesktopTracker/App/DesktopTrackerApp.swift
import SwiftUI

@main
struct DesktopTrackerApp: App {
    @State private var showingWindow = false
    
    var body: some Scene {
        MenuBarExtra("TeamSight", systemImage: "timer") {
            MenuBarView()
        }
        
        WindowGroup("TeamSight Tracker") {
            ContentView()
        }
        .defaultSize(width: 1000, height: 700)
    }
}
```

- [ ] **Step 2: Create MenuBarView**

```swift
// DesktopTracker/App/MenuBarView.swift
import SwiftUI

struct MenuBarView: View {
    @State private var timerViewModel = TimerViewModel()
    
    var body: some View {
        if let timer = timerViewModel.activeTimer {
            Text("Active: \(timer.trelloCardId)")
            Text(timerViewModel.formattedTime(timerViewModel.elapsed))
            Divider()
            Button("Stop Timer") {
                Task { await timerViewModel.stopTimer() }
            }
        } else {
            Text("No active timer")
        }
        
        Divider()
        
        Button("Open Dashboard") {
            NSApp.activate(ignoringOtherApps: true)
            if let window = NSApp.windows.first(where: { $0.title == "TeamSight Tracker" }) {
                window.makeKeyAndOrderFront(nil)
            }
        }
        
        Divider()
        
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
```

- [ ] **Step 3: Create ContentView with Navigation**

```swift
// DesktopTracker/Presentation/Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: String = "dashboard"
    
    var body: some View {
        NavigationSplitView {
            List {
                Section("Tracking") {
                    NavigationLink(value: "dashboard") {
                        Label("Dashboard", systemImage: "chart.bar")
                    }
                    NavigationLink(value: "records") {
                        Label("Records", systemImage: "list.bullet")
                    }
                    NavigationLink(value: "manual") {
                        Label("Manual Entry", systemImage: "plus.circle")
                    }
                }
                
                Section("Settings") {
                    NavigationLink(value: "settings") {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("TeamSight")
            .navigationDestination(for: String.self) { tab in
                switch tab {
                case "dashboard":
                    DashboardView()
                case "records":
                    RecordsView()
                case "manual":
                    ManualEntryView()
                case "settings":
                    SettingsView()
                default:
                    Text("Unknown")
                }
            }
        } detail: {
            DashboardView()
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}
```

- [ ] **Step 4: Verify app structure compiles**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 5: Commit**

```bash
git add DesktopTracker/App/ DesktopTracker/Presentation/Views/ContentView.swift
git commit -m "feat: add main app structure with menu bar and navigation"
```

---

### Task 12: Export Functionality

**Covers:** [S4]

**Files:**
- Create: `DesktopTracker/Domain/UseCases/ExportUseCases.swift`
- Create: `DesktopTracker/Presentation/Views/Components/ExportButton.swift`

- [ ] **Step 1: Create ExportUseCases**

```swift
// DesktopTracker/Domain/UseCases/ExportUseCases.swift
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
```

- [ ] **Step 2: Create ExportButton**

```swift
// DesktopTracker/Presentation/Views/Components/ExportButton.swift
import SwiftUI

struct ExportButton: View {
    let memberId: String
    @State private var exporting = false
    @State private var error: String?
    
    private let exportUseCases = ExportUseCases()
    
    var body: some View {
        Menu {
            Button("Export CSV") {
                Task { await export(format: .csv) }
            }
            Button("Export JSON") {
                Task { await export(format: .json) }
            }
        } label: {
            Label("Export", systemImage: "square.and.arrow.up")
        }
        .disabled(exporting)
        .alert("Export Error", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error ?? "")
        }
    }
    
    private func export(format: ExportFormat) async {
        exporting = true
        error = nil
        
        do {
            let fileURL: URL
            switch format {
            case .csv:
                fileURL = try await exportUseCases.exportCSV(memberId: memberId)
            case .json:
                fileURL = try await exportUseCases.exportJSON(memberId: memberId)
            }
            
            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        } catch {
            self.error = "Export failed: \(error.localizedDescription)"
        }
        
        exporting = false
    }
    
    private enum ExportFormat {
        case csv, json
    }
}
```

- [ ] **Step 3: Verify ExportButton compiles**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add DesktopTracker/Domain/UseCases/ExportUseCases.swift DesktopTracker/Presentation/Views/Components/ExportButton.swift
git commit -m "feat: add export functionality with CSV and JSON support"
```

---

### Task 13: Card Picker Component

**Covers:** [S4]

**Files:**
- Create: `DesktopTracker/Presentation/Views/Components/CardPicker.swift`

- [ ] **Step 1: Create CardPicker**

```swift
// DesktopTracker/Presentation/Views/Components/CardPicker.swift
import SwiftUI

struct CardPicker: View {
    @Binding var selectedCardId: String
    let memberId: String
    
    @State private var searchText = ""
    @State private var recentCards: [(id: String, name: String)] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Search or paste Card ID...", text: $searchText)
                .textFieldStyle(.roundedBorder)
            
            if !recentCards.isEmpty {
                Text("Recent Cards")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(recentCards, id: \.id) { card in
                    Button(card.name) {
                        selectedCardId = card.id
                        searchText = card.name
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                }
            }
        }
        .task {
            await loadRecentCards()
        }
    }
    
    private func loadRecentCards() async {
        let repository = TimeTrackerRepositoryImpl()
        do {
            let records = try await repository.getRecords(memberId: memberId)
            let uniqueCards = Array(Set(records.map { ($0.trelloCardId, $0.trelloCardId) }))
            recentCards = Array(uniqueCards.prefix(5))
        } catch {
            // Silent fail
        }
    }
}
```

- [ ] **Step 2: Verify CardPicker compiles**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add DesktopTracker/Presentation/Views/Components/CardPicker.swift
git commit -m "feat: add CardPicker component with recent cards"
```

---

### Task 14: Loading and Error Components

**Covers:** [S7]

**Files:**
- Create: `DesktopTracker/Presentation/Views/Components/LoadingView.swift`

- [ ] **Step 1: Create LoadingView**

```swift
// DesktopTracker/Presentation/Views/Components/LoadingView.swift
import SwiftUI

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text(message)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text(message)
                .foregroundColor(.secondary)
            
            if let retryAction = retryAction {
                Button("Retry") {
                    retryAction()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

- [ ] **Step 2: Verify LoadingView compiles**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add DesktopTracker/Presentation/Views/Components/LoadingView.swift
git commit -m "feat: add LoadingView and ErrorView components"
```

---

### Task 15: Final Integration and Testing

**Covers:** [S10]

**Files:**
- Modify: Various files for final integration

- [ ] **Step 1: Update ContentView with all views**

Ensure ContentView properly routes to all views.

- [ ] **Step 2: Verify full app builds**

Run: `xcodebuild -project DesktopTracker.xcodeproj -scheme DesktopTracker build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Run app and verify basic functionality**

Launch app and verify:
- App opens in menu bar
- Dashboard loads
- Navigation works
- Settings save/load

- [ ] **Step 4: Commit final changes**

```bash
git add -A
git commit -m "feat: complete desktop tracker implementation"
```

---

### Task 16: Documentation

**Covers:** [S10]

**Files:**
- Create: `README.md`

- [ ] **Step 1: Create README**

```markdown
# Desktop Time Tracker

Native macOS application for time tracking with Trello integration.

## Features

- Timer with conflict detection
- Dashboard with daily/weekly/monthly stats
- Records management with search
- Manual time entry
- CSV/JSON export
- Menu bar quick access
- Settings configuration

## Requirements

- macOS 14.0+ (Sonoma)
- Swift 5.9+
- Backend API running

## Setup

1. Open `DesktopTracker.xcodeproj` in Xcode
2. Configure API URL in Settings
3. Build and run

## Architecture

- MVVM + Clean Architecture
- SwiftUI with Swift Charts
- async/await concurrency
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with setup instructions"
```

---

**Plan complete. Ready for execution.**