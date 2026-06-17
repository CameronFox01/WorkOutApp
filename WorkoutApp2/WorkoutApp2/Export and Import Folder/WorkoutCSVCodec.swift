//
//  WorkoutCSVCodec.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/17/26.
//
import Foundation

enum WorkoutCSVCodec {

    // MARK: - Export

    /// Converts entries into CSV text. Always emits all fields for full round-trip fidelity.
    static func encode(_ entries: [WorkoutEntry]) -> String {
        var lines = ["workoutType,weight,reps,sets,date,note"]

        let formatter = ISO8601DateFormatter()

        for entry in entries {
            let row = [
                csvEscape(entry.workoutType),
                csvEscape(entry.weight),
                csvEscape(entry.reps),
                csvEscape(entry.sets),
                formatter.string(from: entry.date),
                csvEscape(entry.note)
            ].joined(separator: ",")
            lines.append(row)
        }

        return lines.joined(separator: "\n")
    }

    /// Wraps a field in quotes and escapes internal quotes if it contains a comma, quote, or newline.
    private static func csvEscape(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else {
            return field
        }
        let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    // MARK: - Import (own format only — for now)

    struct ImportResult {
        let imported: [WorkoutEntry]
        let skippedDuplicates: Int
        let skippedInvalid: Int
    }

    /// Parses CSV text produced by `encode`, skipping rows that are malformed or duplicates
    /// of entries already present in `existing`.
    static func decode(_ csvText: String, existing: [WorkoutEntry]) -> ImportResult {
        let formatter = ISO8601DateFormatter()
        let calendar = Calendar.current

        // Build a lookup of existing entries' duplicate keys for fast skip-checking.
        var seenKeys = Set(existing.map { duplicateKey(for: $0, calendar: calendar) })

        var imported: [WorkoutEntry] = []
        var skippedDuplicates = 0
        var skippedInvalid = 0

        let rows = parseCSVRows(csvText)

        guard let header = rows.first else {
            return ImportResult(imported: [], skippedDuplicates: 0, skippedInvalid: 0)
        }

        let columnIndex = Dictionary(uniqueKeysWithValues: header.enumerated().map { ($1.lowercased(), $0) })

        guard let typeIdx = columnIndex["workouttype"],
              let weightIdx = columnIndex["weight"],
              let repsIdx = columnIndex["reps"],
              let setsIdx = columnIndex["sets"],
              let dateIdx = columnIndex["date"] else {
            // Header doesn't match expected schema at all.
            return ImportResult(imported: [], skippedDuplicates: 0, skippedInvalid: rows.count - 1)
        }
        let noteIdx = columnIndex["note"]

        for row in rows.dropFirst() {
            guard row.count > max(typeIdx, weightIdx, repsIdx, setsIdx, dateIdx) else {
                skippedInvalid += 1
                continue
            }

            guard let date = formatter.date(from: row[dateIdx]) else {
                skippedInvalid += 1
                continue
            }

            let entry = WorkoutEntry(
                workoutType: row[typeIdx],
                weight: row[weightIdx],
                reps: row[repsIdx],
                sets: row[setsIdx],
                date: date,
                note: noteIdx.flatMap { row[safe: $0] } ?? ""
            )

            let key = duplicateKey(for: entry, calendar: calendar)
            if seenKeys.contains(key) {
                skippedDuplicates += 1
                continue
            }

            seenKeys.insert(key)
            imported.append(entry)
        }

        return ImportResult(imported: imported, skippedDuplicates: skippedDuplicates, skippedInvalid: skippedInvalid)
    }

    /// Duplicate key: same day + workout type + reps + weight.
    private static func duplicateKey(for entry: WorkoutEntry, calendar: Calendar) -> String {
        let day = calendar.startOfDay(for: entry.date)
        return "\(day.timeIntervalSince1970)|\(entry.workoutType)|\(entry.reps)|\(entry.weight)"
    }

    /// Minimal CSV row parser that handles quoted fields containing commas/newlines.
    private static func parseCSVRows(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var insideQuotes = false

        var iterator = text.makeIterator()
        var chars: [Character] = []
        while let c = iterator.next() { chars.append(c) }

        var i = 0
        while i < chars.count {
            let c = chars[i]

            if insideQuotes {
                if c == "\"" {
                    if i + 1 < chars.count, chars[i + 1] == "\"" {
                        currentField.append("\"")
                        i += 1
                    } else {
                        insideQuotes = false
                    }
                } else {
                    currentField.append(c)
                }
            } else {
                switch c {
                case "\"":
                    insideQuotes = true
                case ",":
                    currentRow.append(currentField)
                    currentField = ""
                case "\n":
                    currentRow.append(currentField)
                    rows.append(currentRow)
                    currentRow = []
                    currentField = ""
                case "\r":
                    break // ignore, handled by \n
                default:
                    currentField.append(c)
                }
            }
            i += 1
        }

        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField)
            rows.append(currentRow)
        }

        return rows.filter { !($0.count == 1 && $0[0].isEmpty) }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
