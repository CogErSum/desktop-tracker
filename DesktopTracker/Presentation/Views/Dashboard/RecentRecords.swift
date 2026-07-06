import SwiftUI

struct RecentRecords: View {
    let records: [TimeRecord]
    let cardNames: [String: String]
    let formatDuration: (Int) -> String
    
    var body: some View {
        if records.isEmpty {
            emptyState
        } else {
            recordsList
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundColor(Color.tmst.stroke)
            Text("No records yet")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.tmst.textSecondary)
            Text("Start tracking time on a card!")
                .font(.system(size: 12))
                .foregroundColor(Color.tmst.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
    
    private var recordsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(records.prefix(10).enumerated()), id: \.element.id) { index, record in
                recordRow(record)
                if index < min(records.count, 10) - 1 {
                    Divider()
                        .background(Color.tmst.stroke)
                }
            }
        }
    }
    
    private func recordRow(_ record: TimeRecord) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(cardNames[record.trelloCardId] ?? String(record.trelloCardId.prefix(8)))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.tmst.textPrimary)
                    .lineLimit(1)
                Text(formatDate(record.recordDate ?? record.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(Color.tmst.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatDuration(record.durationSec))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.tmst.accent)
                if let comment = record.comment {
                    Text(comment)
                        .font(.system(size: 11))
                        .foregroundColor(Color.tmst.textSecondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString) else {
            return String(dateString.prefix(10))
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd MMM, HH:mm"
        return displayFormatter.string(from: date)
    }
}
