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
                detailRow(label: "Date", value: formatDate(record.recordDate ?? record.createdAt))
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
