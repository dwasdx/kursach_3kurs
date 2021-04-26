//
//  UserLocationService.swift
//  Messager
//
//  Created by Андрей Журавлев on 21.04.2021.
//

import CoreLocation

protocol UserLocationServiceable: class {
    
    var isEnabled: Bool { get }
    
    func startUpdatingLocation() -> LocationServiceError?
    func stopUpdatingLocation()
    
    func askUserPermissionForWhenInUseAuthorizationIfNeeded()
    func getDistanceFromUserLocation(to coordinates: LocationCoordinates) -> Double?
    //    func askUserForPreciseLocationOnce() // maybe will be needed later
    var isUserPermissionForLocationTrackingGranted: Bool { get }
    var isUserPermissionForLocationTrackingDenied: Bool { get }
    var isFullAccuracyLocationEnabled: Bool { get }
    
    var currentLocation: Emitter<UserLocationService.Location?> { get }
}

enum LocationServiceError: Error {
    case notEnabled
    case needAskUserPermission
    case userDidNotAllowed
}

final class UserLocationService: NSObject {
    
    public struct Location: Equatable {
        let latitude: Double
        let longitude: Double
        let speedMetersPerSecond: Double
        let cource: Double
        let timestamp: Date
    }
    
    internal let locationManager = CLLocationManager()
    var currentLocation = Emitter<UserLocationService.Location?>(nil)
    
    static let shared = UserLocationService()
    private override init() {
        super.init()
        
        self.locationManager.activityType = .automotiveNavigation
        self.locationManager.allowsBackgroundLocationUpdates = false
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.delegate = self
    }
}

extension UserLocationService: UserLocationServiceable {
    
    func askUserPermissionForWhenInUseAuthorizationIfNeeded() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() -> LocationServiceError? {
        
        if !isEnabled {
            print("ERROR: location service is not enabled")
            return .notEnabled
        }
        
        let status = CLLocationManager.authorizationStatus()
        if (status == .denied || status == .restricted) {
            // show alert to user telling them they need to allow location data to use some feature of your app
            return .userDidNotAllowed
        }
        
        // if haven't show location permission dialog before, show it to user
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            
            // if you want the app to retrieve location data even in background, use requestAlwaysAuthorization
            // locationManager.requestAlwaysAuthorization()
            return .needAskUserPermission
        }
        
        locationManager.startUpdatingLocation()
        return nil
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func getDistanceFromUserLocation(to coordinates: LocationCoordinates) -> Double? {
        guard let userLocation = locationManager.location else {
            return nil
        }
        let clCoord = CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lon)
        let location = CLLocation(coordinate: clCoord,
                                  altitude: 0,
                                  horizontalAccuracy: kCLLocationAccuracyBest,
                                  verticalAccuracy: kCLLocationAccuracyBest,
                                  timestamp: Date())
        let distance = userLocation.distance(from: location)
        return distance
    }
    
    var isEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }
    
    var isUserPermissionForLocationTrackingGranted: Bool {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                return true
                
            default:
                return false
        }
    }
    
    var isUserPermissionForLocationTrackingDenied: Bool {
        CLLocationManager.authorizationStatus() == .denied
    }
    
    var isFullAccuracyLocationEnabled: Bool {
        if #available(iOS 14.0, *) {
            return locationManager.accuracyAuthorization == .fullAccuracy
        } else {
            return true
        }
    }
}

extension UserLocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // .requestLocation will only pass one location to the locations array
        if let clLocation = locations.first {
            //print("Location: \(locations.first?.description ?? "empty")")
            
            let location = Location(latitude: clLocation.coordinate.latitude,
                                    longitude: clLocation.coordinate.longitude,
                                    speedMetersPerSecond: clLocation.speed,
                                    cource: clLocation.course,
                                    timestamp: clLocation.timestamp)
            currentLocation.value = location
        }
    }
    
    // This delegate method (didChangeAuthorization status) will always be called after the line locationManager.delegate = self, even when the permission dialog haven't been shown to user before.
    @available(iOS, deprecated: 14.0)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationManagerDidChangeAuthorizationStatus(manager, status: status)
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.locationManagerDidChangeAuthorizationStatus(manager, status: manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: locationManager didFailWithError: \(error.localizedDescription)")
        // might be that user didn't enable location service on the device
        // or there might be no GPS signal inside a building
        
        // might be a good idea to show an alert to user to ask them to walk to a place with GPS signal
    }
}

extension UserLocationService {
    private func locationManagerDidChangeAuthorizationStatus(_ manager: CLLocationManager, status: CLAuthorizationStatus) {
        print("location manager authorization status changed")
        
        switch status {
            case .authorizedAlways:
                print("user allow app to get location data when app is active or in background")
                _ = startUpdatingLocation()
            case .authorizedWhenInUse:
                print("user allow app to get location data only when app is active")
                _ = startUpdatingLocation()
            case .denied:
                print("user tap 'disallow' on the permission dialog, cant get location data")
            case .restricted:
                print("parental control setting disallow location data")
            case .notDetermined:
                print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
            @unknown default:
                print("ERROR: Unhendeled CLLocationManager Authorization status")
        }
    }
}
