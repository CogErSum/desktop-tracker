import SwiftUI

struct ExportButton: View {
    let memberId: String
    @State private var exporting = false
    @State private var error: String?
    
    private let exportUseCases = ExportUseCases()
    
    var body: some View {
        Menu {
            Button("Export CSV") {
                Task { await export(format: .csv) }
            }
            Button("Export JSON") {
                Task { await export(format: .json) }
            }
        } label: {
            Label("Export", systemImage: "square.and.arrow.up")
        }
        .disabled(exporting)
        .alert("Export Error", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error ?? "")
        }
    }
    
    private func export(format: ExportFormat) async {
        exporting = true
        error = nil
        
        do {
            let fileURL: URL
            switch format {
            case .csv:
                fileURL = try await exportUseCases.exportCSV(memberId: memberId)
            case .json:
                fileURL = try await exportUseCases.exportJSON(memberId: memberId)
            }
            
            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        } catch {
            self.error = "Export failed: \(error.localizedDescription)"
        }
        
        exporting = false
    }
    
    private enum ExportFormat {
        case csv, json
    }
}