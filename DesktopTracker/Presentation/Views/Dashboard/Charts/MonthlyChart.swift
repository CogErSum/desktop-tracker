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
