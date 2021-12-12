//
//  UIView+.swift
//  UIPiPView
//
//  Created by Akihiro Urushihara on 2021/12/13.
//

import UIKit
import Foundation


extension UIView {

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

    /// toUIImage
    func toUIImage() -> UIImage {
        let imageRenderer = UIGraphicsImageRenderer.init(size: bounds.size)
        return imageRenderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
