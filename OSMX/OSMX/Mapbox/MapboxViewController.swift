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

    
    // MARK:- MGLMapViewDelegate
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        //startOfflinePackDownload()
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 1
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 3
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return .red
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        guard let title = annotation.title else { return nil }
        guard let identifier = title else { return nil }
        
        if let view = mapView.dequeueReusableAnnotationImage(withIdentifier:  identifier) {
            return view
        }
        
        guard identifier == Constants.RootTo.name else { return nil }
        
        return MGLAnnotationImage(image: UIImage(named: "destination")!, reuseIdentifier: identifier)
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    
    // MARK:- Private
    
    private func setup() {
        guard mapView == nil else { return }
        let styleURL = MGLStyle.streetsStyleURL(withVersion: 9)
        mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
        view.addSubview(mapView)
        mapView.snp.makeConstraints { $0.edges.equalTo(self.view) }
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Setup offline pack notification handlers.
        NotificationCenter.default.addObserver(
            self, selector:#selector(offlinePackProgressDidChange),
            name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(offlinePackDidReceiveError),
            name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles),
            name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
    }
    
    private func zoom() {
        mapView.centerCoordinate = Constants.RootFrom.coordinate
        mapView.zoomLevel = Constants.MapSetting.zoomLevel
    }
    
    private func annotate() {
        let source = MGLPointAnnotation()
        source.coordinate = Constants.RootFrom.coordinate
        source.title = Constants.RootFrom.name
        
        let destination = MGLPointAnnotation()
        destination.coordinate = Constants.RootTo.coordinate
        destination.title = Constants.RootTo.name
        mapView.addAnnotations([source, destination])
    }
    
    private func direct() {
        let directions = MapboxDirections(profile: .walking,
                                          source: Constants.RootFrom.coordinate,
                                          destination: Constants.RootTo.coordinate)
        directions.calculate { [weak self] coordinates in
            var coordinates = coordinates
            let polyline = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
            self?.mapView.addAnnotation(polyline)
        }
    }

    func startOfflinePackDownload() {
        let center = Constants.RootFrom.coordinate
        let delta = Constants.MapSetting.offlineRegionDelta*0.1
        let level = Constants.MapSetting.zoomLevel
        let sw = CLLocationCoordinate2D(latitude: center.latitude - delta, longitude: center.longitude - delta)
        let ne = CLLocationCoordinate2D(latitude: center.latitude + delta, longitude: center.longitude + delta)
        let bounds = MGLCoordinateBounds(sw: sw, ne: ne)
        print(bounds)
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: bounds, fromZoomLevel: level - 1, toZoomLevel: level + 1)
        
        let userInfo = ["name": "My Offline Pack"]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
        
        MGLOfflineStorage.shared().addPack(for: region, withContext: context) { (pack, error) in
            if let e = error {
                print("Error: \(e.localizedDescription)"); return
            }
            
            // Start Downloading
            pack?.resume()
        }
    }
    

    // MARK:- MGLOfflinePack notification handlers
    
    func offlinePackProgressDidChange(notification: NSNotification) {
        // Get the offline pack this notification is regarding,
        // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
            let progress = pack.progress
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage.
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            
            // If this pack has finished, print its size and resource count.
            if completedResources == expectedResources {
                let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted), countStyle: ByteCountFormatter.CountStyle.memory)
                print("Offline pack “\(userInfo["name"])” completed: \(byteCount), \(completedResources) resources")
            } else {
                // Otherwise, print download/verification progress.
                print("Offline pack “\(userInfo["name"])” has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.")
            }
        }
    }
    
    func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackErrorUserInfoKey] as? Error {
            print("Offline pack “\(userInfo["name"])” received error: \(error.localizedDescription)")
        }
    }
    
    func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let maximumCount = notification.userInfo?[MGLOfflinePackMaximumCountUserInfoKey] as? UInt64 {
            print("Offline pack “\(userInfo["name"])” reached limit of \(maximumCount) tiles.")
        }
    }
}

