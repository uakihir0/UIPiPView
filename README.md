[>> 日本語](./Document/README.ja.md)

# UIPiPView

<!--
[![Version](https://img.shields.io/cocoapods/v/UIPiPView.svg?style=flat)](https://cocoapods.org/pods/UIPiPView)
[![License](https://img.shields.io/cocoapods/l/UIPiPView.svg?style=flat)](https://cocoapods.org/pods/UIPiPView)
[![Platform](https://img.shields.io/cocoapods/p/UIPiPView.svg?style=flat)](https://cocoapods.org/pods/UIPiPView)
-->

<img src="./Document/image.gif" width=200>

**This library is a UIView that is capable of Picture-in-Picture (PiP) in iOS.**

Using this library, information that is updated in real time (e.g. stock prices) can be displayed on the screen using PiP, even when the app is in the background. We look forward to seeing many ideas come to fruition using this library.

## Requirements

You need to be running `iOS15` or higher. This library can be installed on `iOS12` or higher, but PiP cannot be executed without `iOS15` or higher.

Also, as a note for development, PiP will only work on **ACTUAL DEVICES**. Please note that PiP does not work with simulators. Also, this library depends on `AVKit` and `AVFoundation`.

If you want to include this library in your app, you need to enable `Audio, AirPlay and Picture in Picture` in `Background Modes`. For more information, see [Apple's page](https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/creating_a_basic_video_player_ios_and_tvos/enabling_background_audio).

## Installation

UIPiPView can be installed using [CocoaPods](https://cocoapods.org). You can install it using You can install it by writing the following to your `Podfile` and running `$ pod install`.

```ruby
pod 'UIPiPView', :git => 'https://github.com/uakihir0/UIPiPView/', :branch => 'main'
```

or can be installed using [SwiftPM](https://www.swift.org/package-manager/).

## Example

It is always a good idea to check if your environment is ready to use `UIPiPView` before you start. You can do this with the following code.

```swift
uiPipView.isUIPiPViewSupported()
```

### Start

Since `UIPiPView` inherits from `UIView`, it can be used in the same way as `UIView`. To run PiP, execute the following function. Run the following function to run PiP.

```swift
uiPipView.startPictureInPicture(withRefreshInterval: (0.1 / 60.0))
```

The above function will refresh the PiP screen 60 times per second. The screen refresh is a relatively heavy process because the `UIView` is converted to a `CMSampleBuffer` via a `UIImage`. Therefore, if the `UIView` is complex, the update processing may not be able to keep up, or it may affect other processing. In that case, change the arguments in the above code to reduce the update frequency, or run PiP with the following code.

```swift
uiPipView.startPictureInPictureWithManualCallRender()
```

The above function will not automatically refresh the screen except for the first screen refresh. If you want to update the screen, execute the following additional code.

```swift
uiPipView.render()
```

Running the above function will render the state of the `UIPiPView` at the time the thread completes. By using this function, we can perform rendering at each screen update timing and keep the rendering cost to a minimum.

### Exit

To exit PiP, execute the following code.

```swift
uiPipView.stopPictureInPicture()
```

## Author

Akihiro Urushihara  
Mail: [a.urusihara@gmail.com](a.urusihara@gmail.com)  
Twitter: [@uakihir0](https://twitter.com/uakihir0)

## License

UIPiPiPView is available under the MIT license. See the LICENSE file for more info.
