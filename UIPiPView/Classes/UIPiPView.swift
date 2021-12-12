//
//  UIPiPView.swift
//  UIPiPView
//
//  Created by Akihiro Urushihara on 2021/12/12.
//

import UIKit
import AVKit
import AVFoundation

open class UIPiPView: UIView {

    /// Returns whether or not UIPiPView is supported.
    /// It depends on the iOS version, also note that it cannot be used with the iOS simulator.
    public func isUIPiPViewSupported() -> Bool {
        if AVPictureInPictureController.isPictureInPictureSupported(), #available(iOS 15.0, *) {
            return true }
        return false
    }

    public let pipController = AVPictureInPictureController()
    public let pipBufferDisplayLayer = AVSampleBufferDisplayLayer()

    private var pipPossibleObservation: NSKeyValueObservation?
    private var refreshIntervalTimer: Timer!

    /// Starts PinP.
    /// Also, this function should be called due to a user operation.
    /// (This is a violation of iOS app conventions).
    open func startPictureInPicture(
        withRefreshInterval: TimeInterval
    ) {
        initializeState()
        DispatchQueue.main.async { [weak self] in
            self?.startPictureInPictureSub(refreshInterval: withRefreshInterval)
        }
    }

    /// Starts PinP.
    /// Also, this function should be called due to a user operation.
    /// (This is a violation of iOS app conventions).
    open func startPictureInPictureWithManualCallRender() {
        initializeState()
        DispatchQueue.main.async {
            self.startPictureInPictureSub(refreshInterval: nil)
        }
    }

    private func initializeState() {
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(.playback, mode: .moviePlayback)
        try! session.setActive(true)
        setupVideoLayerView()
    }

    private func startPictureInPictureSub(
        refreshInterval: TimeInterval?
    ) {
        if isUIPiPViewSupported(), #available(iOS 15.0, *) {

            if (pipController.contentSource !== nil) {
                pipController.contentSource = .init(
                    sampleBufferDisplayLayer:
                        pipBufferDisplayLayer,
                    playbackDelegate: self)
                pipController.delegate = self
            }

            if (pipController.isPictureInPicturePossible) {
                pipController.startPictureInPicture()
                if let ti = refreshInterval {
                    setRenderInterval(ti)
                }

            } else {
                /// It will take some time for PiP to become available.
                pipPossibleObservation = pipController.observe(
                    \AVPictureInPictureController.isPictureInPicturePossible,
                    options: [.initial, .new]) { [weak self] _, change in
                    guard let self = self else { return }

                    if (change.newValue ?? false) {
                        self.pipController.startPictureInPicture()
                        self.pipPossibleObservation = nil
                        if let ti = refreshInterval {
                            self.setRenderInterval(ti)
                        }
                    }
                }
            }
        } else {
            print("[UIPiPView] UIPiPView cannot be used on this device or OS.")
        }
    }

    private let videoLayerView = UIView()

    /// Since PinP requires a layer with the video on the screen, prepare a View.
    private func setupVideoLayerView() {
        if (videoLayerView.superview == nil) {

            self.addSubview(videoLayerView)
            self.sendSubviewToBack(videoLayerView)
            videoLayerView.addFillConstraints(with: self)
            videoLayerView.alpha = 0 /// Hidden

            pipBufferDisplayLayer.frame = videoLayerView.bounds
            pipBufferDisplayLayer.videoGravity = .resizeAspect
            videoLayerView.layer.addSublayer(pipBufferDisplayLayer)
        }
    }

    /// Stop PiP.
    open func stopPictureInPicture() {
        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
        }
        if refreshIntervalTimer != nil {
            refreshIntervalTimer.invalidate()
            refreshIntervalTimer = nil
        }
    }

    /// Returns whether PiP is running or not.
    open func isPictureInPictureActive() -> Bool {
        return pipController.isPictureInPictureActive
    }

    // MARK: VideoProducer

    /// Draws the current UIView state as a video.
    /// Note that the PiP image will not change unless this function is called.
    open func render() {
        if (pipBufferDisplayLayer.status == .failed) {
            pipBufferDisplayLayer.flush()
        }
        guard let buffer = makeNextVieoBuffer() else { return }
        pipBufferDisplayLayer.enqueue(buffer)
    }

    ///
    private func setRenderInterval(
        _ interval: TimeInterval
    ) {
        refreshIntervalTimer = Timer(
            timeInterval: interval, repeats: true) {
            [weak self] _ in self?.render() }
        RunLoop.main.add(refreshIntervalTimer, forMode: .default)
    }

    /// Create and return a CMSampleBuffer.
    /// This function basically does not need to be called by UIPiPView users,
    ///  but if you want to create your own modified CMSampleBuffer, prepare an overwritten function.
    open func makeNextVieoBuffer() -> CMSampleBuffer? {
        return self.toUIImage().toCMSampleBuffer()
    }
}


// MARK: AVPictureInPictureControllerDelegate
extension UIPiPView: AVPictureInPictureControllerDelegate {

    open func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
    }

    open func pictureInPictureControllerWillStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
    }

    open func pictureInPictureControllerWillStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
    }
}

// MARK: AVPictureInPictureSampleBufferPlaybackDelegate
extension UIPiPView: AVPictureInPictureSampleBufferPlaybackDelegate {

    open func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        setPlaying playing: Bool
    ) {
    }

    open func pictureInPictureControllerTimeRangeForPlayback(
        _ pictureInPictureController: AVPictureInPictureController
    ) -> CMTimeRange {
        return CMTimeRange(
            start: .negativeInfinity,
            duration: .positiveInfinity
        )
    }

    open func pictureInPictureControllerIsPlaybackPaused(
        _ pictureInPictureController: AVPictureInPictureController
    ) -> Bool {
        return false
    }

    open func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        didTransitionToRenderSize newRenderSize: CMVideoDimensions
    ) {
    }

    open func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        skipByInterval skipInterval: CMTime,
        completion completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
