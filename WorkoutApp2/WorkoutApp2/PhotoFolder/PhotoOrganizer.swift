//
//  SavedPhoto.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/15/26.
//


import Foundation
import SwiftUI

struct SavedPhoto: Identifiable {
    let id = UUID()
    let url: URL
    let creationDate: Date
}

struct PhotoSection: Identifiable {
    let id = UUID()
    let title: String
    let photos: [SavedPhoto]
}

enum PhotoOrganizer {

    static func loadPhotos() -> [SavedPhoto] {

        guard let directory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return []
        }

        do {

            let files = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.creationDateKey]
            )

            return files
                .filter { $0.pathExtension.lowercased() == "jpg" }
                .compactMap { url in

                    let values = try? url.resourceValues(
                        forKeys: [.creationDateKey]
                    )

                    return SavedPhoto(
                        url: url,
                        creationDate: values?.creationDate ?? .distantPast
                    )
                }
                .sorted {
                    $0.creationDate > $1.creationDate
                }

        } catch {
            print(error)
            return []
        }
    }

    static func groupedByMonth(
        photos: [SavedPhoto]
    ) -> [PhotoSection] {

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(
            grouping: photos
        ) { photo in

            let comps = Calendar.current.dateComponents(
                [.year, .month],
                from: photo.creationDate
            )

            return Calendar.current.date(from: comps)!
        }

        return grouped
            .sorted { $0.key > $1.key }
            .map { date, photos in

                PhotoSection(
                    title: formatter.string(from: date),
                    photos: photos.sorted {
                        $0.creationDate > $1.creationDate
                    }
                )
            }
    }
}

struct EmptyPhotoView: View {
    var body: some View {
        ContentUnavailableView(
            "No Photos Saved",
            systemImage: "photo.on.rectangle.angled",
            description: Text("Try taking a photo or checking your photo library.")
        )
    }
}
