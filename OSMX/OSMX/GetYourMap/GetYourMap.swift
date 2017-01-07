//
//  GetYourMap.swift
//  OSMX
//
//  Created by temoki on 2017/01/07.
//  Copyright © 2017 temoki. All rights reserved.
//

import GLMap

class GetYourMap {
    
    class func setup() {
        if let key = Bundle.main.infoDictionary?["GetYourMapAPIKey"] as? String {
            GLMapManager.shared().apiKey = key
            GLMapManager.shared().tileDownloadingAllowed = true
        }
    }
    
}
