//
//  LocationManager.swift
//  kobby
//
//  Created by Maxwell Anane on 8/31/24.
//


import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    @Published var lastKnownLocation: CLLocationCoordinate2D?
       @Published var currentPlaceName: String = "Unknown Location"
       
       var manager = CLLocationManager()
       private var geocoder = CLGeocoder()
       private var cachedLocation: CLLocation?
       private var cachedPlaceName: String?
    
    func checkLocationAuthorization() {
        
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined://The user choose allow or denny your app to get the location yet
            manager.requestWhenInUseAuthorization()
            
        case .restricted://The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
            print("Location restricted")
            
        case .denied://The user dennied your app to get location or disabled the services location or the phone is in airplane mode
            print("Location denied")
            
        case .authorizedAlways://This authorization allows you to use all location services and receive location events whether or not your app is in use.
            print("Location authorizedAlways")
            
        case .authorizedWhenInUse://This authorization allows you to use all location services and receive location events only when your app is in use
            print("Location authorized when in use")
            lastKnownLocation = manager.location?.coordinate
            
        @unknown default:
            print("Location service disabled")
        
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {//Trigged every time authorization status changes
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let location = locations.first else { return }
           
           // Check if the location is significantly different from the cached location
           if let cachedLocation = cachedLocation, location.distance(from: cachedLocation) < 50 {
               self.currentPlaceName = cachedPlaceName ?? "Unknown Place"
           } else {
               performReverseGeocoding(for: location)
           }
       }
       
       private func performReverseGeocoding(for location: CLLocation) {
           geocoder.cancelGeocode()
           geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
               guard let self = self else { return }
               if let placemark = placemarks?.first {
                   self.currentPlaceName = placemark.name ?? "Unknown Place"
                   // Cache the result
                   self.cachedLocation = location
                   self.cachedPlaceName = self.currentPlaceName
               } else {
                   self.currentPlaceName = "Unknown Place"
               }
           }
       }}
