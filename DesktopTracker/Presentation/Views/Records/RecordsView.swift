import SwiftUI

struct RecordsView: View {
    @State private var viewModel = RecordsViewModel()
    @State private var selectedRecord: TimeRecord?
    @State private var displayedCount = 10
    
    private var displayedRecords: ArraySlice<TimeRecord> {
        let filtered = viewModel.filteredRecords()
        let end = min(displayedCount, filtered.count)
        return filtered[0..<end]
    }
    
    private var hasMore: Bool {
        displayedCount < viewModel.filteredRecords().count
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search records...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
                    .onChange(of: viewModel.searchText) { _, _ in
                        displayedCount = 10
                    }
                
                Spacer()
                
                Text("\(viewModel.filteredRecords().count) records")
                    .foregroundColor(Color.tmst.textSecondary)
                    .font(.caption)
                
                Button("Refresh") {
                    displayedCount = 10
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
                        ForEach(Array(displayedRecords)) { record in
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
                        
                        if hasMore {
                            ProgressView()
                                .padding()
                                .task {
                                    try? await Task.sleep(for: .milliseconds(200))
                                    displayedCount += 10
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
