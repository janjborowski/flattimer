//
//  CircularLayer.swift
//  FlatTimer
//
//  Created by Jan Borowski on 21.07.2018.
//  Copyright © 2018 Jan Borowski. All rights reserved.
//

import UIKit

class CircularLayer: CAShapeLayer {

    private let angleOffset: CGFloat
    private let rect: CGRect

    init(color: UIColor, rect: CGRect, angleOffset: CGFloat, lineWidth: CGFloat) {
        self.angleOffset = angleOffset
        self.rect = rect
        super.init()
        strokeColor = color.cgColor
        fillColor = UIColor.clear.cgColor
        self.lineWidth = lineWidth
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showCircle(startAngle: CGFloat, endAngle: CGFloat) {
        path = createBezierPath(rect: rect, startAngle: startAngle, endAngle: endAngle).cgPath
    }

    private func createBezierPath(rect: CGRect, startAngle: CGFloat, endAngle: CGFloat) -> UIBezierPath {
        let center = CGPoint(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
        let radius: CGFloat = max(rect.width, rect.height)

        return UIBezierPath(
            arcCenter: center,
            radius: radius/2 - lineWidth/2,
            startAngle: startAngle + angleOffset,
            endAngle: endAngle + angleOffset,
            clockwise: true
        )
    }

}
