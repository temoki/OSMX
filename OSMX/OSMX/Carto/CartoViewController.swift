//
//  CartoViewController.swift
//  OSMX
//
//  Created by temoki on 2017/01/31.
//  Copyright © 2017年 temoki. All rights reserved.
//

import UIKit

class CartoViewController: UIViewController {
    
    private var mapView: NTMapView!
    private let mapProjection = NTEPSG3857()!
    private let mapLayer = NTCartoOnlineVectorTileLayer(style: .CARTO_BASEMAP_STYLE_DEFAULT)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        zoom()
        annotate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- Private
    
    private func setup() {
        guard mapView == nil else { return }
        mapView = NTMapView(frame: view.bounds)
        mapView.getLayers().add(mapLayer)
        mapView.getOptions().setBaseProjection(NTEPSG3857())
        view.addSubview(mapView)
        mapView.snp.makeConstraints { $0.edges.equalTo(self.view) }
        //mapView.delegate = self
        //mapView.showsUserLocation = true
    }

    private func zoom() {
        mapView.getOptions().setBaseProjection(mapProjection)
        let source = mapProjection.fromWgs84(NTMapPos(x: Constants.RootFrom.longitude, y: Constants.RootFrom.latitude))
        mapView.setZoom(Float(13), targetPos: source, durationSeconds: 0)
        mapView.setFocus(source, durationSeconds: 0)
    }
    
    private func annotate() {
        // Source
        let srcBuilder = NTMarkerStyleBuilder()
        srcBuilder?.setSize(30)
        srcBuilder?.setColor(NTColor(r: .min, g: .min, b: .max, a: .max))
        let srcStyle = srcBuilder?.buildStyle()
        let srcPos = mapProjection.fromWgs84(NTMapPos(x: Constants.RootFrom.longitude, y: Constants.RootFrom.latitude))
        let srcMarker = NTMarker(pos: srcPos, style: srcStyle)
        
        let dstBuilder = NTMarkerStyleBuilder()
        dstBuilder?.setSize(30)
        dstBuilder?.setColor(NTColor(r: .max, g: .min, b: .min, a: .max))
        let dstStyle = dstBuilder?.buildStyle()
        let dstPos = mapProjection.fromWgs84(NTMapPos(x: Constants.RootTo.longitude, y: Constants.RootTo.latitude))
        let dstMarker = NTMarker(pos: dstPos, style: dstStyle)
        
        let dataSource = NTLocalVectorDataSource(projection: mapProjection)
        let vectorLayer = NTVectorLayer(dataSource: dataSource)
        mapView.getLayers().add(vectorLayer)
        dataSource?.add(srcMarker)
        dataSource?.add(dstMarker)
    }

}
