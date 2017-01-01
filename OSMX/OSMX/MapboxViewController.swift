//
//  MapboxViewController.swift
//  OSMX
//
//  Created by temoki on 2017/01/01.
//  Copyright © 2017年 temoki. All rights reserved.
//

import UIKit
import Mapbox
import SnapKit

class MapboxViewController: UIViewController {

    private var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup map view
        let styleURL = MGLStyle.lightStyleURL(withVersion: 9)
        mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
        view.addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

