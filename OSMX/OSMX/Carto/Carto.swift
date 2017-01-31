//
//  Carto.swift
//  OSMX
//
//  Created by temoki on 2017/01/31.
//  Copyright © 2017年 temoki. All rights reserved.
//

import Foundation

class Carto {
    
    static func setup() {
        if let key = Bundle.main.infoDictionary?["CartoApiKey"] as? String {
            NTMapView.registerLicense(key)
        }
    }

}
