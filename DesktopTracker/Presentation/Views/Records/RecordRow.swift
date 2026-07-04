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
                Text(record.recordDate ?? record.createdAt, style: .date)
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
}
