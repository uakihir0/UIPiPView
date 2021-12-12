//
//  Data+.swift
//  UIPiPView
//
//  Created by Akihiro Urushihara on 2021/12/13.
//


import Foundation
import AVKit
import AVFoundation

extension Data {

    func toCMBlockBuffer() throws -> CMBlockBuffer {
        
        /// This block source is a manually retained pointer to our data instance.
        /// The passed FreeBlock function manually releases it when the block buffer gets deallocated.
        let data = NSMutableData(data: self)
        var source = CMBlockBufferCustomBlockSource()
        source.refCon = Unmanaged.passRetained(data).toOpaque()
        source.FreeBlock = freeBlock

        var blockBuffer: CMBlockBuffer?
        let result = CMBlockBufferCreateWithMemoryBlock(
            allocator: kCFAllocatorDefault,
            memoryBlock: data.mutableBytes,
            blockLength: data.length,
            blockAllocator: kCFAllocatorNull,
            customBlockSource: &source,
            offsetToData: 0,
            dataLength: data.length,
            flags: 0,
            blockBufferOut: &blockBuffer)
        
        if OSStatus(result) != kCMBlockBufferNoErr {
            throw CMEncodingError.cmBlockCreationFailed
        }

        guard let buffer = blockBuffer else {
            throw CMEncodingError.cmBlockCreationFailed
        }

        assert(CMBlockBufferGetDataLength(buffer) == data.length)
        return buffer
    }
}

private func freeBlock(
    _ refCon: UnsafeMutableRawPointer?,
    doomedMemoryBlock: UnsafeMutableRawPointer,
    sizeInBytes: Int
) -> Void {
    let unmanagedData = Unmanaged<NSData>.fromOpaque(refCon!)
    unmanagedData.release()
}

enum CMEncodingError: Error {
    case cmBlockCreationFailed
}
