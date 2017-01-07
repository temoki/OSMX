//
//  GetYourMapViewController.swift
//  OSMX
//
//  Created by temoki on 2017/01/07.
//  Copyright © 2017 temoki. All rights reserved.
//

import GLMap
import SnapKit
import ReachabilitySwift

class GetYourMapViewController: UIViewController {
    
    private var mapView: GLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        zoom()
        //annotate()
        //direct()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK:- Private
    
    private func setup() {
        guard mapView == nil else { return }
        mapView = GLMapView(frame: view.bounds)
        view.addSubview(mapView)
        mapView.snp.makeConstraints { $0.edges.equalTo(self.view) }
        mapView.showUserLocation = true
    }
    
    private func zoom() {
        let center = GLMapGeoPoint(lat: Constants.RootFrom.latitude, lon: Constants.RootFrom.longitude)
        let level = CGFloat(Constants.MapSetting.zoomLevel)
        mapView.move(to: center, zoomLevel: level)
    }

}
