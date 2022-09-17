//
//  UIView+.swift
//  UIPiPView
//
//  Created by Akihiro Urushihara on 2021/12/13.
//

import UIKit
import Foundation
import AVKit
import AVFoundation

public extension UIView {

    /// Make the UIView the same size
    func addFillConstraints(with superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            superView.topAnchor.constraint(equalTo: topAnchor),
            superView.leadingAnchor.constraint(equalTo: leadingAnchor),
            superView.trailingAnchor.constraint(equalTo: trailingAnchor),
            superView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }

    /// Make CMSampleBuffer from UIView
    /// https://soranoba.net/programming/uiview-to-cmsamplebuffer
    func makeSampleBuffer() -> CMSampleBuffer? {
        let scale = UIScreen.main.scale
        let size = CGSize(
            width: (bounds.width * scale),
            height: (bounds.height * scale))

        var pixelBuffer: CVPixelBuffer?
        var status = CVPixelBufferCreate(kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            [
                kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
                kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!,
                kCVPixelBufferIOSurfacePropertiesKey: [:] as CFDictionary,
            ] as CFDictionary, &pixelBuffer)

        if status != kCVReturnSuccess {
            assertionFailure("[UIPiPView] Failed to create CVPixelBuffer: \(status)")
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer!, []) }

        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer!),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!

        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: scale, y: -scale)
        layer.render(in: context)

        var formatDescription: CMFormatDescription?
        status = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer!,
            formatDescriptionOut: &formatDescription)

        if status != kCVReturnSuccess {
            assertionFailure("[UIPiPView] Failed to create CMFormatDescription: \(status)")
            return nil
        }

        let now = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: 60)
        let timingInfo = CMSampleTimingInfo(
            duration: .init(seconds: 1, preferredTimescale: 60),
            presentationTimeStamp: now,
            decodeTimeStamp: now)

        do {
            if #available(iOS 13.0, *) {
                return try CMSampleBuffer(
                    imageBuffer: pixelBuffer!,
                    formatDescription: formatDescription!,
                    sampleTiming: timingInfo)
            } else {
                assertionFailure("[UIPiPView] UIPiPView cannot be used on this device or OS.")
                return nil
            }
        } catch {
            assertionFailure("[UIPiPView] Failed to create CVSampleBuffer: \(error)")
            return nil
        }
    }
}
