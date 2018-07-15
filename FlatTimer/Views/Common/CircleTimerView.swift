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
    private weak var orangeCircleLayer: CAShapeLayer?
    private weak var animatedLayer: CAShapeLayer?

    var markerColor: UIColor = .darkOrange

    override func layoutSubviews() {
        super.layoutSubviews()
        addPaleCirle(in: bounds)
        addOrangeCircle(in: bounds)
    }

    private func addPaleCirle(in rect: CGRect) {
        guard paleCircleLayer == nil else {
            return
        }
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = 2 * .pi

        let shapeLayer = createCircularLayer(
            rect: rect,
            color: .paleWhite,
            startAngle: startAngle,
            endAngle: endAngle
        )

        layer.addSublayer(shapeLayer)
        paleCircleLayer = shapeLayer
    }

    private func addOrangeCircle(in rect: CGRect) {
        guard orangeCircleLayer == nil else {
            return
        }
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = 2 * .pi

        let shapeLayer = createCircularLayer(
            rect: rect,
            color: .lightOrange,
            startAngle: startAngle,
            endAngle: endAngle
        )

        layer.addSublayer(shapeLayer)
        orangeCircleLayer = shapeLayer
    }

    private func createCircularLayer(rect: CGRect, color: UIColor, startAngle: CGFloat, endAngle: CGFloat) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = circleThickness

        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius: CGFloat = max(rect.width, rect.height)

        shapeLayer.path = UIBezierPath(
            arcCenter: center,
            radius: radius/2 - circleThickness/2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        ).cgPath
        return shapeLayer
    }

    private func createAnimatedLayer(duration: TimeInterval) -> CAShapeLayer {
        let startAngle: CGFloat = -.pi / 2
        let endAngle: CGFloat = 3 * .pi / 2

        let shapeLayer = createCircularLayer(
            rect: bounds,
            color: .lightOrange,
            startAngle: startAngle,
            endAngle: endAngle
        )

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1.0
        animation.toValue = 0
        animation.duration = duration

        animation.fillMode = kCAFillModeRemoved
        animation.isRemovedOnCompletion = true
        animation.delegate = self

        shapeLayer.add(animation, forKey: "strokeEnd")
        return shapeLayer
    }

    func startAnimation(duration: TimeInterval) {
        guard self.animatedLayer == nil else {
            return
        }

        let animatedLayer = createAnimatedLayer(duration: duration)
        layer.addSublayer(animatedLayer)

        self.animatedLayer = animatedLayer

        orangeCircleLayer?.isHidden = true
    }

    func stopAnimation() {
        animatedLayer?.removeFromSuperlayer()
        animatedLayer = nil

        orangeCircleLayer?.isHidden = false
    }

}

extension CircleTimerView: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }

}
