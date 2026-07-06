import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                
                if viewModel.loading {
                    loadingView
                } else if let data = viewModel.dashboardData {
                    statsSection(data)
                    recentActivitySection(data)
                } else if let error = viewModel.error {
                    errorView(error)
                }
            }
            .padding(24)
        }
        .background(Color.tmst.surface.opacity(0.3))
        .task {
            await viewModel.loadDashboard()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Dashboard")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.tmst.textPrimary)
            Text("Overview of your time tracking activity")
                .font(.system(size: 14))
                .foregroundColor(Color.tmst.textSecondary)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading dashboard...")
                .font(.system(size: 14))
                .foregroundColor(Color.tmst.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(Color.tmst.error)
            Text(error)
                .font(.system(size: 14))
                .foregroundColor(Color.tmst.textSecondary)
            Button("Retry") {
                Task { await viewModel.loadDashboard() }
            }
            .buttonStyle(TMSTButtonStyle())
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private func statsSection(_ data: DashboardData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.tmst.textPrimary)
            
            HStack(spacing: 16) {
                StatsCard(
                    title: "Today",
                    value: viewModel.formatDuration(data.todaySec),
                    icon: "sun.max.fill",
                    color: .orange
                )
                StatsCard(
                    title: "This Week",
                    value: viewModel.formatDuration(data.weekSec),
                    icon: "calendar",
                    color: Color.tmst.accent
                )
                StatsCard(
                    title: "This Month",
                    value: viewModel.formatDuration(data.monthSec),
                    icon: "chart.bar.fill",
                    color: .green
                )
            }
        }
    }
    
    private func recentActivitySection(_ data: DashboardData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.tmst.textPrimary)
            
            RecentRecords(
                records: data.recentRecords,
                cardNames: viewModel.cardNames,
                formatDuration: viewModel.formatDuration
            )
            .tmstCard()
        }
    }
}
