//
//  WorkoutDataExporter.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/17/26.
//
import Foundation
import UniformTypeIdentifiers

@MainActor
final class WorkoutDataExporter: ObservableObject {

    @Published var exportURL: URL?
    @Published var lastImportSummary: String?
    @Published var importError: String?

    /// Writes the CSV to a temp file and returns its URL, ready for a share sheet.
    func prepareExport(entries: [WorkoutEntry]) {
        let csv = WorkoutCSVCodec.encode(entries)
        let filename = "IronFox-Export-\(Self.dateStampFormatter.string(from: Date())).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            exportURL = url
        } catch {
            importError = "Couldn't prepare export file: \(error.localizedDescription)"
        }
    }

    /// Reads a picked file URL, decodes it, and merges new entries into workoutData.
    func importCSV(from url: URL, into workoutData: WorkoutData) {
        // Security-scoped resource access is required for files picked via UIDocumentPickerViewController.
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing { url.stopAccessingSecurityScopedResource() }
        }

        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            let result = WorkoutCSVCodec.decode(text, existing: workoutData.entries)

            for entry in result.imported {
                workoutData.add(entry: entry)
            }

            lastImportSummary = "Imported \(result.imported.count) workouts. Skipped \(result.skippedDuplicates) duplicate\(result.skippedDuplicates == 1 ? "" : "s"), \(result.skippedInvalid) invalid row\(result.skippedInvalid == 1 ? "" : "s")."
        } catch {
            importError = "Couldn't read file: \(error.localizedDescription)"
        }
    }

    private static let dateStampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
