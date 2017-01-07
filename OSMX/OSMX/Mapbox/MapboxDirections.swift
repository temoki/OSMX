//
//  MapboxDirections.swift
//  OSMX
//
//  Created by temoki on 2017/01/06.
//  Copyright © 2017 temoki. All rights reserved.
//

import Mapbox

class MapboxDirections {
    
    enum Profile: String {
        case driving
        case walking
        case cycling
    }
    
    let profile: Profile
    let source: CLLocationCoordinate2D
    let destination: CLLocationCoordinate2D
    
    init(profile: Profile, source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        self.profile = profile
        self.source = source
        self.destination = destination
    }
    
    func calculate(completion: @escaping ([CLLocationCoordinate2D]) -> Void) {
        var requestURLString = "https://api.mapbox.com/directions/v5/mapbox"
        requestURLString += "/" + profile.rawValue
        requestURLString += "/" + "\(source.longitude),\(source.latitude)"
        requestURLString += ";" + "\(destination.longitude),\(destination.latitude)"
        requestURLString += "?" + "steps=true"
        requestURLString += "&" + "access_token=" + MGLAccountManager.accessToken()!
        guard let URL = URL(string: requestURLString) else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: URL) { data, response, error in
            var coordinates: [CLLocationCoordinate2D] = []
            defer {
                DispatchQueue.main.async { completion(coordinates) }
            }
            
            if let e = error {
                print("ERROR=\(e)"); return
            }
            
            guard let r = response as? HTTPURLResponse, r.statusCode == 200 else {
                print("RESPONSE=\(response)"); return
            }
            
            guard let data = data else {
                print("DATA=nil"); return
            }
            
            if let jsonStr = String(data: data, encoding: .utf8) {
                print(jsonStr)
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                return
            }
            
            guard let root = jsonObject as? [String: Any] else { return }
            guard let routes = root["routes"] as? [Any] else { return }
            guard let route = routes.first as? [String: Any] else { return }
            guard let legs = route["legs"] as? [Any] else { return }
            guard let leg = legs.first as? [String: Any] else { return }
            guard let steps = leg["steps"] as? [[String: Any]] else { return }
            for step in steps {
                guard let maneuver = step["maneuver"] as? [String: Any] else { return }
                guard let location = maneuver["location"] as? [Double] else { return }
                guard location.count >= 2 else { return }
                let coordinate = CLLocationCoordinate2D(latitude: location[1], longitude: location[0])
                coordinates.append(coordinate)
            }
        }
        task.resume()
    }
    
    
}
