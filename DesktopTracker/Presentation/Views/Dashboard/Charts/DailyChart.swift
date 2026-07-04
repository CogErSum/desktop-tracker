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
            }
        }
        .frame(height: 200)
    }
}
