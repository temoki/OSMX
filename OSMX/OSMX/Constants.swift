//
//  Constants.swift
//  OSMX
//
//  Created by temoki on 2017/01/04.
//  Copyright © 2017 temoki. All rights reserved.
//

import Foundation
import CoreLocation

struct Constants {

    struct MapSetting {
        static let zoomLevel = 12.0
        static let zoomSpanDelta = 0.063
        static let offlineRegionDelta = 0.008 / 2.0 // ymt is 0.08 / 2.0
    }
    
    struct RootFrom {
        static let name = "Nagoya Station"
        static let latitude = 35.170954
        static let longitude = 136.881575
        static let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    struct RootTo {
        static let name = "Nagoya Castle"
        static let latitude = 35.183850
        static let longitude = 136.900261
        static let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
