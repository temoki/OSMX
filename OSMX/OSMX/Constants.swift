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
        static let zoomLevel = 16.0
        static let zoomSpanDelta = 0.004
    }

    struct NagoyoTVTower {
        static let name = "Nagoya TV Tower"
        static let latitude = 35.172338
        static let longitude = 136.908335
        static let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    struct Oasys21 {
        static let name = "Oasys21"
        static let latitude = 35.171028
        static let longitude = 136.909678
        static let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
