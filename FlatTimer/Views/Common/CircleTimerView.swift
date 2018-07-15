//
//  CircleTimerView.swift
//  FlatTimer
//
//  Created by Jan Borowski on 15.07.2018.
//  Copyright © 2018 Jan Borowski. All rights reserved.
//

import UIKit

class CircleTimerView: UIView {

    private let circleThickness: CGFloat = 42

    private let markerIndentation: CGFloat = 3
    private let markerWidth: CGFloat = 5

    private let numberOfMarkers = 12

    private weak var paleCircleLayer: CAShapeLayer?

    var markerColor: UIColor = .darkOrange

    private func createCirclePath(with color: UIColor, in rect: CGRect, endAngle: CGFloat) -> UIBezierPath {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius: CGFloat = max(rect.width, rect.height)

        let path = UIBezierPath(arcCenter: center,
                                radius: radius/2 - circleThickness/2,
                                startAngle: -1 * .pi / 2,
                                endAngle: endAngle,
                                clockwise: true)

        path.lineWidth = circleThickness
        return path
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        addPaleCirle(in: bounds)
    }

    private func addPaleCirle(in rect: CGRect) {
        guard paleCircleLayer == nil else {
            return
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.paleWhite.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = circleThickness

        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius: CGFloat = max(rect.width, rect.height)

        let startAngle: CGFloat = 0
        let endAngle: CGFloat = 2 * .pi

        shapeLayer.path = UIBezierPath(arcCenter: center,
                                radius: radius/2 - circleThickness/2,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true).cgPath

        layer.addSublayer(shapeLayer)
        paleCircleLayer = shapeLayer
    }

}
