//
//  CGPoint+Vector.swift
//  FlatTimer
//
//  Created by Jan Borowski on 21.07.2018.
//  Copyright © 2018 Jan Borowski. All rights reserved.
//

import UIKit

extension CGPoint {

    var vectorLength: CGFloat {
        return sqrt(pow(x, 2) + pow(y, 2))
    }

    func vector(with point: CGPoint) -> CGPoint {
        return CGPoint(x: x - point.x, y: y - point.y)
    }

}
