//
//  Mapbox.swift
//  OSMX
//
//  Created by temoki on 2017/01/01.
//  Copyright © 2017年 temoki. All rights reserved.
//

import Mapbox

class Mapbox {
    
    static let token = // access_token
    
    static func setup() {
        MGLAccountManager.setAccessToken(token)
    }
    
}
