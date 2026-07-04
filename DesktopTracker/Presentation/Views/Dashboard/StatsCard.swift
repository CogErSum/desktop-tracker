import SwiftUI

struct StatsCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.tmst.textSecondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.tmst.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.tmst.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tmst.stroke, lineWidth: 1)
        )
    }
}
