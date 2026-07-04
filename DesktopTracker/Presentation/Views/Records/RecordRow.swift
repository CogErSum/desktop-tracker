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
                Text(formatDateString(record.recordDate ?? record.createdAt))
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
    
    private func formatDateString(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString) else {
            return String(dateString.prefix(10))
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}
