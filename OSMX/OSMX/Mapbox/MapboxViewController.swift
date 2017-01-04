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

class MapboxViewController: UIViewController, MGLMapViewDelegate {

    private var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        zoom()
        annotate()
        direct()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK:- Private
    
    private func setup() {
        guard mapView == nil else { return }
        let styleURL = MGLStyle.lightStyleURL(withVersion: 9)
        mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
        view.addSubview(mapView)
        mapView.snp.makeConstraints { $0.edges.equalTo(self.view) }
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    private func zoom() {
        mapView.centerCoordinate = Constants.NagoyoTVTower.coordinate
        mapView.zoomLevel = Constants.MapSetting.zoomLevel
    }
    
    private func annotate() {
        let source = MGLPointAnnotation()
        source.coordinate = Constants.NagoyoTVTower.coordinate
        source.title = Constants.NagoyoTVTower.name
        
        let destination = MGLPointAnnotation()
        destination.coordinate = Constants.Oasys21.coordinate
        destination.title = Constants.Oasys21.name
        mapView.addAnnotations([source, destination])
    }
    
    private func direct() {
        
    }

}

