import SwiftUI

struct RecordsView: View {
    @State private var viewModel = RecordsViewModel()
    @State private var selectedRecord: TimeRecord?
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search records...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
                
                Spacer()
                
                Button("Refresh") {
                    Task { await viewModel.loadRecords() }
                }
                .tint(Color.tmst.accent)
            }
            .padding()
            
            if viewModel.loading {
                ProgressView()
            } else if let error = viewModel.error {
                Text(error)
                    .foregroundColor(Color.tmst.error)
            } else {
                List(viewModel.filteredRecords(), selection: $selectedRecord) { record in
                    RecordRow(
                        record: record,
                        cardName: viewModel.cardName(for: record.trelloCardId),
                        formatDuration: viewModel.formatDuration
                    )
                    .tag(record)
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            Task { await viewModel.deleteRecord(record) }
                        }
                    }
                }
            }
        }
        .navigationTitle("Records")
        .task {
            await viewModel.loadRecords()
        }
        .sheet(item: $selectedRecord) { record in
            RecordDetail(
                record: record,
                cardName: viewModel.cardName(for: record.trelloCardId),
                formatDuration: viewModel.formatDuration,
                onDelete: {
                    Task { await viewModel.deleteRecord(record) }
                }
            )
        }
    }
}
