//
//  UIColor+FlatTimer.swift
//  FlatTimer
//
//  Created by Jan Borowski on 15.07.2018.
//  Copyright © 2018 Jan Borowski. All rights reserved.
//

import UIKit

extension UIColor {

    static var darkOrange: UIColor {
        return UIColor(red255: 234.0, green: 99.0, blue: 93.0, alpha: 1)
    }

    static var lightOrange: UIColor {
        return UIColor(red255: 250.0, green: 169.0, blue: 73.0, alpha: 1)
    }

    static var darkBlue: UIColor {
        return UIColor(red255: 38.0, green: 53.0, blue: 71.0, alpha: 1)
    }

    static var paleWhite: UIColor {
        return UIColor.white.withAlphaComponent(0.5)
    }

    convenience init(red255: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(red: red255/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
    }

}
