//
//  CardStyle.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/8/26.
//
import SwiftUI
import Foundation

struct CardStyle: ViewModifier {

    func body(content: Content) -> some View {

        content
            .frame(
                maxWidth: .infinity,
                minHeight: 120,
                alignment: .topLeading
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
                .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        Color.white.opacity(0.12),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: .black.opacity(0.08),
                radius: 12,
                x: 0,
                y: 5
            )
    }
}
