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
                        .foregroundColor(Color.tmst.error)
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
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
