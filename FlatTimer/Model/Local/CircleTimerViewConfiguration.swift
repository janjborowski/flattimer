//
//  CircleTimerViewConfiguration.swift
//  FlatTimer
//
//  Created by Jan Borowski on 21.07.2018.
//  Copyright © 2018 Jan Borowski. All rights reserved.
//

import UIKit

struct CircleTimerViewConfiguration {

    var markerStillColor: UIColor
    var markerAnimatedColor: UIColor
    var numberOfMarkers: Int

    static var `default`: CircleTimerViewConfiguration {
        return CircleTimerViewConfiguration(markerStillColor: .darkOrange, markerAnimatedColor: .darkBlue, numberOfMarkers: 0)
    }

}
