//
//  LocationManager.swift
//  iOS Device Tracker
//
//  Created by patron on 11/25/26.
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var authorizatioStatus: CLAuthorizationStatus
    
    private let manager = CLLocationManager()
    
    override init(){
        authorizatioStatus = manager.authorizationStatus
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    private func startUpdatingIfAllowed() {
        guard authorizatioStatus == .authorizedWhenInUse ||
                authorizatioStatus == .authorizedAlways else {
            return
        }
        
        manager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor [weak self] in
            guard let self else {return }
            
            authorizatioStatus = manager.authorizationStatus
            startUpdatingIfAllowed()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocatios locations: [CLLocation]
    ) {
        Task { @MainActor [weak self] in
            self?.currentLocation = locations.last
        }
    }
}
