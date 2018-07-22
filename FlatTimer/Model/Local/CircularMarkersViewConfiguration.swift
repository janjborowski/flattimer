//
//  CircularMarkersViewConfiguration.swift
//  FlatTimer
//
//  Created by Jan Borowski on 21.07.2018.
//  Copyright © 2018 Jan Borowski. All rights reserved.
//

import UIKit

struct CircularMarkersViewConfiguration {

    var markerIndentation: CGFloat
    var markerWidth: CGFloat
    var markerSize: CGFloat
    var selectionWidth: CGFloat
    
    var numberOfMarkers: Int

    var color: UIColor

    static var empty: CircularMarkersViewConfiguration {
        return CircularMarkersViewConfiguration(
            markerIndentation: 0,
            markerWidth: 0,
            markerSize: 0,
            selectionWidth: 0,
            numberOfMarkers: 0,
            color: .clear
        )
    }

}
