# UIPiPView

<!--
[![Version](https://img.shields.io/cocoapods/v/UIPiPView.svg?style=flat)](https://cocoapods.org/pods/UIPiPView)
[![License](https://img.shields.io/cocoapods/l/UIPiPView.svg?style=flat)](https://cocoapods.org/pods/UIPiPView)
[![Platform](https://img.shields.io/cocoapods/p/UIPiPView.svg?style=flat)](https://cocoapods.org/pods/UIPiPView)
-->

<img src="./Document/image.gif" width="200px">

**このライブラリは iOS でピクチャーインピクチャー (PiP) することが可能な UIView です。**

このライブラリを使用することで、リアルタイムに更新される情報 (例えば株価など) を、アプリがバックグラウンドであっても、PiP を使用して画面上に表示することが可能になります。このライブラリを使用して、様々なアイデアが実現されることを楽しみにしています。

## 動作要件

`iOS15` 以上の環境であることが必要です。このライブラリでは `iOS12` 以上であれば導入自体は可能ですが、`iOS15` 以上でなければ PiP の実行はできません。

また、開発の際における注意点として、**PiP は実機でないと動作しません。** シミュレーターで動作はしない点に注意してください。また、本ライブラリは `AVKit` と `AVFoundation` に依存しています。

本ライブラリをアプリに組み込む場合、`Backgroound Models` の `Audio, AirPlay and Picture in Picture` を有効にする必要があります。詳しくは [Apple のページ](https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/creating_a_basic_video_player_ios_and_tvos/enabling_background_audio) を参照してください。

## インストール

UIPiPView は [CocoaPods](https://cocoapods.org). を使用してインストールすることができます。`Podfile` に以下のように記述して `$ pod install` を実行することによってインストールすることができます。

```ruby
pod 'UIPiPView', :git => 'https://github.com/uakihir0/UIPiPView/', :branch => 'main'
```

## 例

`UIPiPView` を使用できる環境かどうかを必ず開始前に確認することをお勧めします。以下のコードから確認することができます。

```swift
uiPipView.isUIPiPViewSupported()
```

### 開始

`UIPiPView` は `UIView` を継承しているので、`UIView` と同じように使用することができます。`UIPiPView` 上に `addSubview` した `UIView` についても PiP 上で表示されるので、普通の `UIView` と同じように使用してください。PiP を実行するためには以下の関数を実行します。

```swift
uiPipView.startPictureInPicture(withRefreshInterval: (0.1 / 60.0))
```

上記の関数は、秒間 60 回 PiP の画面を更新します。画面更新は `UIView` を `UIImage` を経由して`CMSampleBuffer` に変換しているため、比較的重い処理になっています。 そのため、`UIView` が複雑な場合、更新処理が追いつかない、または別の処理に影響を及ぼす可能性があります。その場合は、上記のコードの引数を変更して、更新頻度を下げたり、または以下のコードで PiP を実行してください。

```swift
uiPipView.startPictureInPictureWithManualCallRender()
```

上記の関数では、初回の画面更新以外は自動で画面の更新を行いません。画面の更新を行う場合は、以下のコードを追加で実行します。

```swift
uiPipView.render()
```

上記の関数を実行すると、そのスレッドが完了したタイミングでの `UIPiPView` の状態がレンダリングされます。この関数を用いることによって、画面の更新タイミング毎に描画を実行し、最小限のレンダリングコストで抑えることができます。

### 終了

PiP を終了する場合は以下のコードを実行します。

```swift
uiPipView.stopPictureInPicture()
```

## 作者

Akihiro Urushihara  
Mail: [a.urusihara@gmail.com](a.urusihara@gmail.com)  
Twitter: [@uakihir0](https://twitter.com/uakihir0)

## ライセンス

MIT
