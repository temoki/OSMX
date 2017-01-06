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
        
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            return view
        }

        guard identifier == Constants.RootTo.name else { return nil }

        let view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.image = UIImage(named: "destination")
        return view
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
        mapView.region = MKCoordinateRegion(center: Constants.RootFrom.coordinate, span: span)
    }
    
    private func annotate() {
        let source = MKPointAnnotation()
        source.coordinate = Constants.RootFrom.coordinate
        source.title = Constants.RootFrom.name
        
        let destination = MKPointAnnotation()
        destination.coordinate = Constants.RootTo.coordinate
        destination.title = Constants.RootTo.name
        mapView.addAnnotations([source, destination])
    }
    
    private func direct() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: Constants.RootFrom.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: Constants.RootTo.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let firstRoute = response?.routes.first else { return }
            self?.mapView.add(firstRoute.polyline)
        }
    }
    
}
