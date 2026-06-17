//
//  CodableColor.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/16/26.
//


import SwiftUI

struct CodableColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double

    init(_ color: Color) {
        let components = color.resolve(in: EnvironmentValues())
        red = Double(components.red)
        green = Double(components.green)
        blue = Double(components.blue)
        opacity = Double(components.opacity)
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}