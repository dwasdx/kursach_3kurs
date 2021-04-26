//
//  LocationCoordinates.swift
//  Messager
//
//  Created by Андрей Журавлев on 21.04.2021.
//

import Foundation
import CoreLocation

struct LocationCoordinates: Hashable, Codable {
    let lat: Double
    let lon: Double
    
    init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }
    
    init(coordinates: CLLocationCoordinate2D) {
        self.lat = coordinates.latitude
        self.lon = coordinates.longitude
    }
}
