//
//  MapKitViewController.swift
//  OSMX
//
//  Created by temoki on 2017/01/04.
//  Copyright © 2017年 temoki. All rights reserved.
//

import UIKit
import MapKit
import SnapKit

class MapKitViewController: UIViewController, MKMapViewDelegate {
    
    private var mapView: MKMapView!
    
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
    
    
    // MARK:- MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3
        renderer.strokeColor = UIColor.red
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let title = annotation.title else { return nil }
        guard let identifier = title else { return nil }
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            return annotationView
        }

        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView.image =  UIImage(named: (identifier == Constants.Oasys21.name ? "flag" : "place"))
        return annotationView
    }
    
    
    // MARK:- Private
    
    private func setup() {
        guard mapView == nil else { return }
        mapView = MKMapView(frame: view.bounds)
        view.addSubview(mapView)
        mapView.snp.makeConstraints { $0.edges.equalTo(self.view) }
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
    }
    
    private func zoom() {
        let delta = Constants.MapSetting.zoomSpanDelta
        let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        mapView.region = MKCoordinateRegion(center: Constants.NagoyoTVTower.coordinate, span: span)
    }
    
    private func annotate() {
        let source = MKPointAnnotation()
        source.coordinate = Constants.NagoyoTVTower.coordinate
        source.title = Constants.NagoyoTVTower.name
        
        let destination = MKPointAnnotation()
        destination.coordinate = Constants.Oasys21.coordinate
        destination.title = Constants.Oasys21.name
        mapView.addAnnotations([source, destination])
    }
    
    private func direct() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: Constants.NagoyoTVTower.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: Constants.Oasys21.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let firstRoute = response?.routes.first else { return }
            self?.mapView.add(firstRoute.polyline)
        }
    }
    
}
