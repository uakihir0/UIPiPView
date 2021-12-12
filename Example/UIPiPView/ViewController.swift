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

    override func viewDidLoad() {
        super.viewDidLoad()

        /// Start Button
        let margin = ((self.view.bounds.width - 200) / 2)
        startButton.frame = .init(x: margin, y: 80, width: 200, height: 30)
        startButton.addTarget(self, action: #selector(ViewController.toggle), for: .touchUpInside)
        startButton.setTitle("Start PiP", for: .normal)
        startButton.setTitleColor(.black, for: .normal)
        startButton.backgroundColor = .white
        startButton.layer.cornerRadius = 20
        self.view.addSubview(startButton)

        /// PiP View
        pipView.frame = .init(x: margin, y: 160, width: 200, height: 40)
        self.view.addSubview(pipView)

        /// Time Label on PiPView
        timeLabel.frame = .init(x: 0, y: 0, width: 200, height: 40)
        pipView.addSubview(timeLabel)

        /// Time Label  shows now.
        timer = Timer(timeInterval: (0.1 / 60.0), repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeLabel.text = "\(Date())"
        }
        RunLoop.main.add(timer, forMode: .default)
    }

    @objc
    func toggle() {
        if (pipView.isPictureInPictureActive()) {
            pipView.startPictureInPicture(withRefreshInterval: (0.1 / 60.0))
        } else {
            pipView.stopPictureInPicture()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

