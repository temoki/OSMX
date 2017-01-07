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
import ReachabilitySwift

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
    
    
    // MARK:- Action
    
    @IBAction func action(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Action", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Download offline pack", style: .default) { [weak self] action in
            self?.downloadOfflinePack()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func downloadOfflinePack() {
        guard let reachability = Reachability.init(), reachability.isReachableViaWiFi else {
            showAlertDialog(title: "WiFi is not available."); return
        }
        guard MGLOfflineStorage.shared().packs?.first == nil else {
            showAlertDialog(title: "Offline pack is already downloaded."); return
        }
        startOfflinePackDownload()
    }
    
    private func showAlertDialog(title: String?, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    // MARK:- MGLMapViewDelegate
    
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
        let regionDelta = Constants.OfflineMapSetting.regionDelta
        let levelRange = Constants.OfflineMapSetting.zoomLevelRange
        let sw = CLLocationCoordinate2D(latitude: center.latitude - regionDelta, longitude: center.longitude - regionDelta)
        let ne = CLLocationCoordinate2D(latitude: center.latitude + regionDelta, longitude: center.longitude + regionDelta)
        let bounds = MGLCoordinateBounds(sw: sw, ne: ne)
        print(bounds)
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: bounds,
                                                 fromZoomLevel: levelRange.min, toZoomLevel: levelRange.max)
        
        let userInfo = ["name": "Mapbox Offline Pack"]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
        
        MGLOfflineStorage.shared().addPack(for: region, withContext: context) { [weak self] pack, error in
            if let e = error {
                self?.showAlertDialog(title: "Error", message: e.localizedDescription)
                return
            }
            // Start Downloading
            self?.preDownloadOfflinePack()
            pack?.resume()
        }
    }
    
    func preDownloadOfflinePack() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        navigationItem.title = "Downloading..."
    }
    
    func updateDownloadOfflinePackProgress(_ progress: Float) {
        navigationItem.title = "Downloading... (\(Int(progress * 100))%)"
    }
    
    func postDownloadOfflinePack() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        navigationItem.title = "Mapbox"
    }

    // MARK:- MGLOfflinePack notification handlers
    
    func offlinePackProgressDidChange(notification: NSNotification) {
        guard let pack = notification.object as? MGLOfflinePack else { return }

        let progress = pack.progress
        let completedResources = progress.countOfResourcesCompleted
        let expectedResources = progress.countOfResourcesExpected
        
        // Calculate current progress percentage.
        let progressPercentage = Float(completedResources) / Float(expectedResources)
        
        // If this pack has finished, print its size and resource count.
        if completedResources == expectedResources {
            let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted), countStyle: ByteCountFormatter.CountStyle.memory)
            postDownloadOfflinePack()
            showAlertDialog(title: "Completed", message: "\(byteCount), \(completedResources) resources")
        } else {
            // Otherwise, print download/verification progress.
            updateDownloadOfflinePackProgress(progressPercentage)
            print("Offline pack has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.")
        }
        
    }
    
    func offlinePackDidReceiveError(notification: NSNotification) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        if let e = notification.userInfo?[MGLOfflinePackErrorUserInfoKey] as? Error {
            showAlertDialog(title: "Error", message: e.localizedDescription)
        }
    }
    
    func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if let maximumCount = notification.userInfo?[MGLOfflinePackMaximumCountUserInfoKey] as? UInt64 {
            showAlertDialog(title: "Error", message: "reached limit of \(maximumCount) tiles.")
        }
    }
}

