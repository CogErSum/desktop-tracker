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
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(records) { record in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(cardNames[record.trelloCardId] ?? String(record.trelloCardId.prefix(8)))
                                        .font(.body)
                                        .foregroundColor(.accentColor)
                                    Text(formatDate(record.recordDate ?? record.createdAt))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(formatDuration(record.durationSec))
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    if let comment = record.comment {
                                        Text(comment)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                            
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString) else {
            return String(dateString.prefix(10))
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd MMM HH:mm"
        return displayFormatter.string(from: date)
    }
}
