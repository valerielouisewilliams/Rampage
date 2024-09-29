//
//  LocationManager.swift
//  Rampage
//
//  Created by Valerie Williams on 9/28/24.
//

import Foundation
import CoreLocation
import Foundation
import MapKit

class LocationManager: NSObject,CLLocationManagerDelegate, ObservableObject {

    @Published var region = MKCoordinateRegion()
    
    private let manager = CLLocationManager()
    
    override init() {
            super.init()
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        if let lastKnownLocation = locations.last?.coordinate {
            
            region = MKCoordinateRegion(center: lastKnownLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        }
    }
}

