//
//  ViewController.swift
//  UIPiPView
//
//  Created by Akihiro Urushiara on 12/12/2021.
//  Copyright (c) 2021 Akihiro Urushiara. All rights reserved.
//

import UIKit
import UIPiPView

class ViewController: UIViewController {

    private let pipView = UIPiPView()
    private let startButton = UIButton()
    private let timeLabel = UILabel()

    private var timer: Timer!
    private let formatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let width = CGFloat(240)

        /// Start Button
        let margin = ((self.view.bounds.width - width) / 2)
        startButton.frame = .init(x: margin, y: 80, width: width, height: 40)
        startButton.addTarget(self, action: #selector(ViewController.toggle), for: .touchUpInside)
        startButton.setTitle("Toggle PiP", for: .normal)
        startButton.setTitleColor(.black, for: .normal)
        startButton.backgroundColor = .white
        startButton.layer.cornerRadius = 10
        self.view.addSubview(startButton)

        /// PiP View
        pipView.frame = .init(x: margin, y: 160, width: width, height: 40)
        pipView.backgroundColor = .black
        self.view.addSubview(pipView)

        /// Time Label on PiPView
        timeLabel.frame = .init(x: 10, y: 0, width: width - 20, height: 40)
        timeLabel.textColor = .white
        pipView.addSubview(timeLabel)

        if #available(iOS 13.0, *) {
            timeLabel.font = .monospacedSystemFont(ofSize: 30, weight: .medium)
            timeLabel.adjustsFontSizeToFitWidth = true
        }

        /// Time Label  shows now.
        formatter.dateFormat = "y-MM-dd H:mm:ss.SSSS"
        timer = Timer(timeInterval: (0.1 / 60.0), repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeLabel.text = self.formatter.string(from: Date())
        }
        RunLoop.main.add(timer, forMode: .default)
    }

    @objc func toggle() {
        if (!pipView.isPictureInPictureActive()) {
            pipView.startPictureInPicture(withRefreshInterval: (0.1 / 60.0))
        } else {
            pipView.stopPictureInPicture()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

