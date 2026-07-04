import SwiftUI

struct ManualEntryView: View {
    @State private var viewModel = ManualEntryViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            TextField("Card ID", text: $viewModel.cardId)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Picker("Hours", selection: $viewModel.durationHours) {
                    ForEach(0..<24) { hour in
                        Text("\(hour)h").tag(hour)
                    }
                }
                .frame(width: 80)
                
                Picker("Minutes", selection: $viewModel.durationMinutes) {
                    ForEach(0..<60) { minute in
                        Text("\(minute)m").tag(minute)
                    }
                }
                .frame(width: 80)
            }
            
            DatePicker("Date", selection: $viewModel.recordDate, displayedComponents: .date)
            
            TextField("Comment (optional)", text: $viewModel.comment)
                .textFieldStyle(.roundedBorder)
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(Color.tmst.error)
            }
            
            if viewModel.success {
                Text("Record created!")
                    .foregroundColor(Color.tmst.accent)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Button("Add Record") {
                    Task { await viewModel.submit() }
                }
                .disabled(viewModel.loading)
                .buttonStyle(.borderedProminent)
                .tint(Color.tmst.accent)
            }
        }
        .padding()
        .frame(minWidth: 350, minHeight: 280)
        .navigationTitle("Manual Entry")
    }
}
