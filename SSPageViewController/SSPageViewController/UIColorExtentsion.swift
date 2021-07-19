//
//  UIColorExtentsion.swift
//  SSPageViewController
//
//  Created by Shuqy on 2021/7/10.
//

import Foundation
import UIKit
extension UIColor {
    static var random: UIColor {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
}
