# Desktop Time Tracker - Design Spec

## [S1] Problem
Create a native macOS desktop application for time tracking that provides the same functionality as the existing web application (Trello Time Tracker) plus enhanced analytics and dashboards with charts and detailed statistics.

## [S2] Solution Overview
Build a SwiftUI-based macOS application using MVVM + Clean Architecture that connects to the existing FastAPI backend. The app will run as both a menu bar utility and a standalone window, providing full time tracking capabilities with native macOS UX.

## [S3] Architecture

### MVVM + Clean Architecture Layers

**Presentation Layer:**
- SwiftUI Views with declarative UI
- ViewModels handling UI state and business logic coordination
- Reusable UI components following macOS design patterns

**Domain Layer:**
- Use cases encapsulating business logic
- Repository interfaces defining data contracts
- Domain models independent of data sources

**Data Layer:**
- APIClient for HTTP communication with backend
- Repository implementations bridging domain and data
- Codable models for JSON serialization

### Project Structure
```
desktop-tracker/
├── DesktopTracker/
│   ├── App/
│   │   ├── DesktopTrackerApp.swift
│   │   └── MenuBarView.swift
│   ├── Presentation/
│   │   ├── Views/
│   │   │   ├── Timer/
│   │   │   ├── Dashboard/
│   │   │   ├── Records/
│   │   │   ├── Settings/
│   │   │   └── Components/
│   │   └── ViewModels/
│   ├── Domain/
│   │   ├── UseCases/
│   │   └── Models/
│   ├── Data/
│   │   ├── Network/
│   │   │   ├── APIClient.swift
│   │   │   └── Endpoints/
│   │   └── Repositories/
│   └── Resources/
│       ├── Assets.xcassets/
│       └── Preview Content/
```

## [S4] Core Features

### Timer Functionality
- Start/stop timer for Trello cards
- Conflict detection (active timer on another card)
- Stop & start on conflict resolution
- Real-time elapsed time display
- Trello badge refresh on timer events

### Dashboard
- Today/Week/Month summary cards
- Recent activity table
- Quick stats at a glance

### Records Management
- Complete history with filtering
- Edit/delete records
- Date range selection

### Manual Entry
- Add time records manually
- Select card, duration, date, comment

### Estimates
- Set time estimates for cards
- View estimate vs actual comparison

### Export
- CSV export of time records
- JSON export for integrations

### Trello Integration
- Card name resolution
- Board information
- Comment posting
- Badge refresh

## [S5] Extended Analytics

### Charts (Swift Charts)
- Daily time distribution (bar chart)
- Weekly trends (line chart)
- Monthly overview (area chart)

### Breakdowns
- Time by project/board
- Time by card
- Time by day of week

### Comparisons
- Week over week
- Month over month
- Custom date ranges

### Productivity Insights
- Most productive hours
- Average session length
- Focus time metrics

## [S6] UI Design

### Menu Bar Mode
- Timer icon in menu bar
- Dropdown showing current timer
- Quick start/stop controls
- Recent activity list

### Standalone Window
- Full dashboard view
- Navigation sidebar
- Records table with sorting
- Settings panel

### macOS Native Experience
- Follows system appearance (light/dark)
- Native menus and dialogs
- Keyboard shortcuts
- Drag and drop support

## [S7] Data Flow

### API Communication
- Connect to existing FastAPI backend
- RESTful API calls
- JSON responses
- Error handling with user feedback

### State Management
- @Observable ViewModels (iOS 17+)
- Published properties for UI updates
- Async/await for network calls

## [S8] Technical Requirements

- macOS 14.0+ (Sonoma)
- Swift 5.9+
- SwiftUI
- Swift Charts
- async/await concurrency

## [S9] Non-Goals

- No offline mode (requires backend connection)
- No Trello OAuth (reuse existing auth)
- No data migration (fresh start)

## [S10] Success Criteria

- App launches and connects to backend
- Timer starts/stops correctly
- Dashboard shows accurate statistics
- Charts render properly
- Export generates valid files
- Menu bar mode works
- Window mode works
