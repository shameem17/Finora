//
//  LogoImageProcessor.swift
//  Finora
//

import UIKit

enum LogoImageProcessor {

    /// Shrinks a picked photo to a small PNG so logos stay light in memory.
    /// Decoding / downsampling happens off the main thread.
    static func makeLogo(from data: Data, maxDimension: CGFloat = 160) async -> Data? {
        guard let image = UIImage(data: data) else { return nil }

        let longestSide = max(image.size.width, image.size.height)
        guard longestSide > 0 else { return nil }
        let ratio = min(maxDimension / longestSide, 1)
        let target = CGSize(width: max((image.size.width * ratio).rounded(), 1),
                            height: max((image.size.height * ratio).rounded(), 1))

        let prepared = await image.byPreparingThumbnail(ofSize: target) ?? image

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        return UIGraphicsImageRenderer(size: target, format: format).pngData { _ in
            prepared.draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
