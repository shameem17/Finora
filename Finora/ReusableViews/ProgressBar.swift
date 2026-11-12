//
//  ProgressBar.swift
//  Finora
//
//  Created by Shameem on 11/12/26.
//

import SwiftUI


struct ProgressBar: View {
    let fraction: Double
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(color.opacity(0.15))
                Capsule()
                    .fill(color)
                    .frame(width: max(geo.size.width * fraction, 6))
            }
        }
        .frame(height: 6)
    }
}

