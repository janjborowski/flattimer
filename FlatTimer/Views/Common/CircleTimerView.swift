//
//  CircleTimerView.swift
//  FlatTimer
//
//  Created by Jan Borowski on 15.07.2018.
//  Copyright © 2018 Jan Borowski. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CircleTimerView: UIView {

    private let circleThickness: CGFloat = 42
    private let markerIndentation: CGFloat = 3
    private let markerWidth: CGFloat = 5

    private let fullAngle = 2 * CGFloat.pi
    private let angleOffset = -CGFloat.pi / 2

    private weak var paleCircleLayer: CircularLayer?
    private weak var orangeCircleLayer: CircularLayer?
    private weak var animatedLayer: CAShapeLayer?

    private let currentPart = PublishSubject<Int>()
    let isBlocked = BehaviorRelay<Bool>(value: true)

    var part: Observable<Int> {
        return currentPart.asObservable()
    }

    var markerColor: UIColor = .darkOrange
    var numberOfMarkers = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        addGestureRecognizer(recognizer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if paleCircleLayer == nil,
            orangeCircleLayer == nil {
            paleCircleLayer = addCircularLayer(with: .paleWhite, in: bounds)
            orangeCircleLayer = addCircularLayer(with: .lightOrange, in: bounds)
        }
    }

    private func addCircularLayer(with color: UIColor, in rect: CGRect) -> CircularLayer {
        let shapeLayer = CircularLayer(color: color, rect: rect, angleOffset: angleOffset, lineWidth: circleThickness)
        shapeLayer.showCircle(startAngle: 0, endAngle: fullAngle)
        layer.addSublayer(shapeLayer)
        return shapeLayer
    }

    private func createAnimatedLayer(duration: TimeInterval) -> CAShapeLayer {
        let shapeLayer = CircularLayer(color: .lightOrange, rect: bounds, angleOffset: angleOffset, lineWidth: circleThickness)
        shapeLayer.path = orangeCircleLayer?.path?.copy()

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

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        guard !isBlocked.value, numberOfMarkers > 0 else {
            return
        }

        let angle = computeAngleBetweenStart(and: recognizer)
        let fullAnglePercentage = angle / fullAngle
        let partNumber = round(fullAnglePercentage * CGFloat(numberOfMarkers))

        currentPart.onNext(Int(partNumber))
        let partPercentage = partNumber / CGFloat(numberOfMarkers)
        let finalAngle = partPercentage * fullAngle

        orangeCircleLayer?.showCircle(startAngle: 0, endAngle: finalAngle)
    }

    private func computeAngleBetweenStart(and recognizer: UIPanGestureRecognizer) -> CGFloat {
        let topMiddlePoint = CGPoint(x: bounds.midX, y: 0)
        let translation = recognizer.location(in: self)

        let centerBounds = CGPoint(x: bounds.midX, y: bounds.midY)
        let vectorA = topMiddlePoint.vector(with: centerBounds)
        let vectorB = translation.vector(with: centerBounds)

        let preCosAngle = (vectorA.x * vectorB.x + vectorA.y * vectorB.y) / ( vectorA.vectorLength * vectorB.vectorLength )

        if vectorB.x < 0 {
            return fullAngle - acos(preCosAngle)
        }
        else {
            return acos(preCosAngle)
        }
    }

}

extension CircleTimerView: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }

}
