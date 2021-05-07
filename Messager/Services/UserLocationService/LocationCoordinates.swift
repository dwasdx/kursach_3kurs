//
//  LocationCoordinates.swift
//  Messager
//
//  Created by Андрей Журавлев on 21.04.2021.
//

import Foundation
import CoreLocation
import protocol MessageKit.LocationItem
import struct UIKit.CGSize

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

extension LocationCoordinates: LocationItem {
    var location: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }
    
    var size: CGSize {
        CGSize(width: 200, height: 100)
    }
    
}
