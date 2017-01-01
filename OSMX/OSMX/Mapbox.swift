//
//  Mapbox.swift
//  OSMX
//
//  Created by temoki on 2017/01/01.
//  Copyright © 2017年 temoki. All rights reserved.
//

import Mapbox

class Mapbox {
    
    class func setup() {
        let token = "pk.eyJ1IjoidGVtb2tpIiwiYSI6ImNpeGUzN3F5ZzAwZmkydG54cnJyOW5kMnQifQ.leKufbiDSotosa7XwjG81g"
        MGLAccountManager.setAccessToken(token)
    }
    
}
