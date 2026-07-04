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
