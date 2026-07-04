import SwiftUI

struct StartTimerView: View {
    @State private var viewModel = StartTimerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Start Timer")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Search for a Trello card:")
                    .foregroundColor(.secondary)
                
                TextField("Type card name...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.searchText) { _, newValue in
                        viewModel.debounceSearch(query: newValue)
                    }
                
                if viewModel.searching {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity)
                }
                
                if !viewModel.searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.searchResults) { card in
                                Button {
                                    viewModel.selectCard(card)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(card.name)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .lineLimit(2)
                                            if !card.boardName.isEmpty {
                                                Text(card.boardName)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 4)
                                }
                                .buttonStyle(.plain)
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
            
            if let selected = viewModel.selectedCard {
                HStack {
                    Text("Selected:")
                        .foregroundColor(.secondary)
                    Text(selected.name)
                        .fontWeight(.medium)
                    Spacer()
                    Button("Clear") {
                        viewModel.selectedCard = nil
                        viewModel.searchText = ""
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
            }
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Button("Start Timer") {
                    Task {
                        await viewModel.startTimer()
                        if viewModel.timerStarted {
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.selectedCard == nil || viewModel.loading)
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
        .frame(minWidth: 450, minHeight: 400)
    }
}
