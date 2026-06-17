//
//  DataExportSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/17/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct DataExportSection: View {
    @EnvironmentObject var workoutData: WorkoutData
    @StateObject private var exporter = WorkoutDataExporter()

    @State private var showingShareSheet = false
    @State private var showingImporter = false
    @State private var showingImportResultAlert = false
    @State private var showingErrorAlert = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                exporter.prepareExport(entries: workoutData.entries)
                showingShareSheet = exporter.exportURL != nil
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Workouts (CSV)")
                    Spacer()
                }
                .foregroundStyle(.blue)
                .font(.subheadline)
            }
            .padding(.bottom, 10)

            Divider()

            Button {
                showingImporter = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import Workouts (CSV)")
                    Spacer()
                }
                .foregroundStyle(.blue)
                .font(.subheadline)
            }
            .padding(.top, 10)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exporter.exportURL {
                ShareSheet(items: [url])
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                exporter.importCSV(from: url, into: workoutData)
                if exporter.importError != nil {
                    showingErrorAlert = true
                } else {
                    showingImportResultAlert = true
                }
            case .failure(let error):
                exporter.importError = error.localizedDescription
                showingErrorAlert = true
            }
        }
        .alert("Import Complete", isPresented: $showingImportResultAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(exporter.lastImportSummary ?? "")
        }
        .alert("Import Failed", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(exporter.importError ?? "Unknown error")
        }
    }
}

/// Thin wrapper exposing UIActivityViewController to SwiftUI for the export share sheet.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) { }
}

#Preview {
    DataExportSection()
        .environmentObject(WorkoutData())
}
