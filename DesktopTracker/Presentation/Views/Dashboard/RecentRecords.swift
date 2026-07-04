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
