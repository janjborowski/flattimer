//
//  CircularMarkersView.swift
//  FlatTimer
//
//  Created by Jan Borowski on 21.07.2018.
//  Copyright © 2018 Jan Borowski. All rights reserved.
//

import UIKit

final class CircularMarkersView: UIView {

    var configuration = CircularMarkersViewConfiguration.empty {
        didSet {
            setNeedsDisplay()
        }
    }

    var selectedMarker = 0  {
        didSet {
            setNeedsDisplay()
        }
    }

    var selectedMarkerHidden = false {
        didSet {
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        guard configuration.numberOfMarkers > 0 else {
            return
        }
        let context = UIGraphicsGetCurrentContext()!
        context.clear(rect)
        
        context.saveGState()
        configuration.color.setFill()

        let markerArc = Constants.fullAngle / CGFloat(configuration.numberOfMarkers)
        let bezierRect = CGRect(
            x: -configuration.markerWidth / 2,
            y: -configuration.markerIndentation,
            width: configuration.markerWidth,
            height: configuration.markerSize
        )
        let markerPath = UIBezierPath(rect: bezierRect)

        let extendedRect = bezierRect.insetBy(dx: -configuration.selectionWidth, dy: -configuration.selectionWidth)
        let selectedBezier = UIBezierPath(rect: extendedRect)

        context.translateBy(x: rect.width / 2, y: rect.height / 2)
        context.scaleBy(x: 1, y: -1)

        for i in 1...configuration.numberOfMarkers {
            context.saveGState()
            let angle = -markerArc * CGFloat(i)
            context.rotate(by: angle)
            context.translateBy(x: 0, y: rect.height / 2 - configuration.markerSize)

            if selectedMarker == i, !selectedMarkerHidden {
                UIColor.lightOrange.setFill()
                selectedBezier.fill()
                configuration.color.setFill()
            }

            markerPath.fill()
            context.restoreGState()
        }

        context.restoreGState()
    }

}
