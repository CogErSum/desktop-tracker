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
                
                Text("\(viewModel.records.count)/\(viewModel.totalRecords)")
                    .foregroundColor(Color.tmst.textSecondary)
                    .font(.caption)
                
                Button("Refresh") {
                    Task { await viewModel.loadRecords() }
                }
            }
            .padding()
            
            if viewModel.loading {
                ProgressView()
            } else if let error = viewModel.error {
                Text(error)
                    .foregroundColor(Color.tmst.error)
            } else if viewModel.filteredRecords().isEmpty {
                Text("No records found")
                    .foregroundColor(Color.tmst.textSecondary)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredRecords()) { record in
                            RecordRow(
                                record: record,
                                cardName: viewModel.cardName(for: record.trelloCardId),
                                formatDuration: viewModel.formatDuration
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRecord = record
                            }
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    Task { await viewModel.deleteRecord(record) }
                                }
                            }
                            Divider()
                        }
                        
                        if viewModel.records.count < viewModel.totalRecords {
                            ProgressView()
                                .padding()
                                .task {
                                    try? await Task.sleep(for: .milliseconds(200))
                                    await viewModel.loadMore()
                                }
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
                    selectedRecord = nil
                }
            )
        }
    }
}
