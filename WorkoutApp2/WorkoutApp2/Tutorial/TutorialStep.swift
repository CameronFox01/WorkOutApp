//
//  TutorialStep.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/16/26.
//


import SwiftUI

// MARK: - Model

struct TutorialStep: Identifiable {
    let id: String  // matches the .tutorialHighlight(id:) tag
    let title: String
    let description: String
}

// MARK: - Anchor Preference Plumbing

struct TutorialAnchorPreferenceKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    /// Tag any view so the tutorial overlay can find and highlight it.
    func tutorialHighlight(_ id: String) -> some View {
        anchorPreference(key: TutorialAnchorPreferenceKey.self, value: .bounds) { anchor in
            [id: anchor]
        }
    }

    /// Cuts a transparent hole out of `self` shaped like `mask`.
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask(
            ZStack {
                Rectangle()
                mask().blendMode(.destinationOut)
            }
            .compositingGroup()
        )
    }
}

// MARK: - Overlay View

struct TutorialOverlayView: View {
    let steps: [TutorialStep]
    let anchors: [String: Anchor<CGRect>]
    @Binding var currentIndex: Int
    let onFinish: () -> Void

    var body: some View {
        GeometryReader { geo in
            let step = steps[currentIndex]
            let rawRect = anchors[step.id].map { geo[$0] } ?? .zero
            let highlightRect = rawRect.insetBy(dx: -8, dy: -8)
            let containerSize = geo.size

            ZStack {
                Color.black.opacity(0.78)
                    .reverseMask {
                        RoundedRectangle(cornerRadius: 18)
                            .frame(width: highlightRect.width, height: highlightRect.height)
                            .position(x: highlightRect.midX, y: highlightRect.midY)
                    }

                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: highlightRect.width, height: highlightRect.height)
                    .position(x: highlightRect.midX, y: highlightRect.midY)
                    .shadow(color: .white.opacity(0.5), radius: 8)

                tooltip(for: step, near: highlightRect, in: containerSize)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: currentIndex)
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func tooltip(for step: TutorialStep, near rect: CGRect, in containerSize: CGSize) -> some View {
        let placeBelow = rect.midY < containerSize.height / 2
        let cardWidth = min(containerSize.width - 40, 340)

        VStack(alignment: .leading, spacing: 14) {
            Text(step.title)
                .font(.headline)
                .foregroundStyle(.black)

            Text(step.description)
                .font(.subheadline)
                .foregroundStyle(.black.opacity(0.8))

            HStack {
                Button("Skip") { onFinish() }
                    .font(.subheadline)
                    .foregroundStyle(.black.opacity(0.6))

                Spacer()

                Text("\(currentIndex + 1) of \(steps.count)")
                    .font(.caption)
                    .foregroundStyle(.black.opacity(0.5))

                Spacer()

                Button(currentIndex == steps.count - 1 ? "Done" : "Next") {
                    if currentIndex == steps.count - 1 {
                        onFinish()
                    } else {
                        currentIndex += 1
                    }
                }
                .fontWeight(.semibold)
                .foregroundStyle(.green)
            }
        }
        .padding(18)
        .frame(width: cardWidth)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6).opacity(0.98)))
        .position(
            x: containerSize.width / 2,
            y: placeBelow
                ? min(rect.maxY + 110, containerSize.height - 100)
                : max(rect.minY - 110, 100)
        )
    }
}

// MARK: - Attach Modifier

struct TutorialOverlayModifier: ViewModifier {
    @Binding var isPresented: Bool
    let steps: [TutorialStep]
    let onFinish: () -> Void

    @State private var currentIndex = 0

    func body(content: Content) -> some View {
        content.overlayPreferenceValue(TutorialAnchorPreferenceKey.self) { anchors in
            if isPresented, !steps.isEmpty {
                TutorialOverlayView(
                    steps: steps,
                    anchors: anchors,
                    currentIndex: $currentIndex,
                    onFinish: {
                        isPresented = false
                        currentIndex = 0
                        onFinish()
                    }
                )
                .transition(.opacity)
            }
        }
    }
}

extension View {
    func tutorialOverlay(
        isPresented: Binding<Bool>,
        steps: [TutorialStep],
        onFinish: @escaping () -> Void
    ) -> some View {
        modifier(TutorialOverlayModifier(isPresented: isPresented, steps: steps, onFinish: onFinish))
    }
}
