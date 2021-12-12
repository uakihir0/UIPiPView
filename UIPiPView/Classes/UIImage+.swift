//
//  UIImage+.swift
//  UIPiPView
//
//  Created by Akihiro Urushihara on 2021/12/13.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

extension UIImage {

    /// toCMSampleBuffer
    /// Fix the performance problem once it is through the jpeg format.
    func toCMSampleBuffer() -> CMSampleBuffer? {
        guard let jpegData = jpegData(compressionQuality: 1) else { return nil }
        return sampleBufferFromJPEGData(jpegData)
    }

    private func sampleBufferFromJPEGData(_ jpegData: Data) -> CMSampleBuffer? {
        guard let cgImage = cgImage else { return nil }

        var format: CMFormatDescription? = nil
        let _ = CMVideoFormatDescriptionCreate(
            allocator: kCFAllocatorDefault,
            codecType: kCMVideoCodecType_JPEG,
            width: Int32(cgImage.width),
            height: Int32(cgImage.height),
            extensions: nil,
            formatDescriptionOut: &format)

        do {
            let cmBlockBuffer = try jpegData.toCMBlockBuffer()
            var size = jpegData.count
            let nowTime = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: 60)
            let _1_60_s = CMTime(value: 1, timescale: 60)

            var timingInfo = CMSampleTimingInfo(
                duration: _1_60_s,
                presentationTimeStamp: nowTime,
                decodeTimeStamp: .invalid)
            
            var sampleBuffer: CMSampleBuffer? = nil
            let _ = CMSampleBufferCreateReady(
                allocator: kCFAllocatorDefault,
                dataBuffer: cmBlockBuffer,
                formatDescription: format,
                sampleCount: 1,
                sampleTimingEntryCount: 1,
                sampleTimingArray: &timingInfo,
                sampleSizeEntryCount: 1,
                sampleSizeArray: &size,
                sampleBufferOut: &sampleBuffer)

            if sampleBuffer != nil {
                return sampleBuffer

            } else {
                print("[UIPiPView] CMSampleBuffer creation error. (be nil)")
                return nil
            }
            
        } catch {
            print("[UIPiPView] CMSampleBuffer creation throw error.", error)
            return nil
        }
    }
}
