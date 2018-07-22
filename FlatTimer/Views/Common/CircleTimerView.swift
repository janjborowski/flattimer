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
    private let angleOffset = -CGFloat.pi / 2

    private let markersView = CircularMarkersView()
    private weak var paleCircleLayer: CircularLayer?
    private weak var orangeCircleLayer: CircularLayer?
    private weak var animatedLayer: CAShapeLayer?

    private var configuration = CircleTimerViewConfiguration.default
    
    private let currentPart = PublishSubject<Int>()
    let isBlocked = BehaviorRelay<Bool>(value: true)

    var part: Observable<Int> {
        return currentPart.asObservable()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addPanGestureRecognizer()
        addMarkersView()
    }

    private func addPanGestureRecognizer() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        addGestureRecognizer(recognizer)
    }

    private func addMarkersView() {
        addSubview(markersView)

        markersView.translatesAutoresizingMaskIntoConstraints = false
        markersView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        markersView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        markersView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        markersView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if paleCircleLayer == nil,
            orangeCircleLayer == nil {
            paleCircleLayer = addCircularLayer(with: .paleWhite, in: bounds)
            orangeCircleLayer = addCircularLayer(with: .lightOrange, in: bounds)

            let markerSize = circleThickness - 2 * markerIndentation
            markersView.configuration = CircularMarkersViewConfiguration(
                markerIndentation: markerIndentation,
                markerWidth: markerWidth,
                markerSize: markerSize,
                numberOfMarkers: configuration.numberOfMarkers,
                color: configuration.markerStillColor
            )
            bringSubview(toFront: markersView)
        }
    }

    private func addCircularLayer(with color: UIColor, in rect: CGRect) -> CircularLayer {
        let shapeLayer = CircularLayer(color: color, rect: rect, angleOffset: angleOffset, lineWidth: circleThickness)
        shapeLayer.showCircle(startAngle: 0, endAngle: Constants.fullAngle)
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

        bringSubview(toFront: markersView)
        markersView.configuration.color = configuration.markerAnimatedColor
    }

    func stopAnimation() {
        animatedLayer?.removeFromSuperlayer()
        animatedLayer = nil
        orangeCircleLayer?.isHidden = false
        markersView.configuration.color = configuration.markerStillColor
    }

    func update(numberOfMarkers: Int) {
        configuration.numberOfMarkers = numberOfMarkers
    }

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        guard !isBlocked.value, configuration.numberOfMarkers > 0 else {
            return
        }
        let numberOfMarkers = configuration.numberOfMarkers

        let angle = computeAngleBetweenStart(and: recognizer)
        let fullAnglePercentage = angle / Constants.fullAngle
        let partNumber = round(fullAnglePercentage * CGFloat(numberOfMarkers))

        currentPart.onNext(Int(partNumber))
        let partPercentage = partNumber / CGFloat(numberOfMarkers)
        let finalAngle = partPercentage * Constants.fullAngle

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
            return Constants.fullAngle - acos(preCosAngle)
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
