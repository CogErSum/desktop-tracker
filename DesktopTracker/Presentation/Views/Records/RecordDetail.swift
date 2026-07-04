import SwiftUI

struct RecordDetail: View {
    let record: TimeRecord
    let cardName: String
    let formatDuration: (Int) -> String
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text(cardName)
                .font(.title2)
                .fontWeight(.bold)
            
            Group {
                detailRow(label: "Duration", value: formatDuration(record.durationSec))
                detailRow(label: "Date", value: formatDateString(record.recordDate ?? record.createdAt))
                if let comment = record.comment {
                    detailRow(label: "Comment", value: comment)
                }
            }
            
            Spacer()
            
            Button("Delete Record", role: .destructive) {
                onDelete()
                dismiss()
            }
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    private func formatDateString(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString) else {
            return String(dateString.prefix(10))
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .long
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}
