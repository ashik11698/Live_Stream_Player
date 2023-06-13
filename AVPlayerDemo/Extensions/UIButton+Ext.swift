//
//  UIButton+Ext.swift
//  AVPlayerDemo
//
//  Created by Mac on 13/6/23.
//

import UIKit

extension UIButton {
    func createButton(tintColor: UIColor, title: String, imageName: String) -> UIButton {
        let button = UIButton()
        button.tintColor = tintColor
        button.setTitle(title, for: .normal)
        let image = UIImage(systemName: imageName)
        button.setImage(image, for: .normal)
        return button
    }
    
    func createButtonWithFrame(x: Int, y: Int, width: Int, height: Int, tintColor: UIColor, title: String, imageName: String) -> UIButton {
        let button:UIButton = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
        button.tintColor = tintColor
        button.setTitle(title, for: .normal)
        let image = UIImage(systemName: imageName)
        button.setImage(image, for: .normal)
        return button
    }
}
