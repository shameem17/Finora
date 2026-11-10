//
//  WaveView.swift
//  Finora
//
//  Created by Shameem on 11/10/26.
//

import SwiftUI


struct WaveShape: Shape {
    var amplitude: CGFloat = 20     // height of the curves
    var frequency: CGFloat = 1.5    // number of full waves across the width
    var phase: CGFloat = 0          // horizontal shift (animatable)
    var baseline: CGFloat = 0.5     // vertical position, 0 = top, 1 = bottom

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.height * baseline

        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: midY))

        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / rect.width
            let angle = relativeX * frequency * 2 * .pi + phase
            let y = midY + sin(angle) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

