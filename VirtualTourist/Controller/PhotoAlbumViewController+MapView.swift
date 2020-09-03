//
//  PhotoAlbumViewController+MapView.swift
//  VirtualTourist
//
//  Created by Osifeso Adeyemi on 03/09/2020.
//  Copyright © 2020 Osifeso Adeyemi. All rights reserved.
//

import UIKit
import MapKit

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func setUpAnnotationOnMap() {
           let annotation = MKPointAnnotation()
           let lat = CLLocationDegrees(pin.value(forKey: "latitude") as! Double)
           let lon = CLLocationDegrees(pin.value(forKey: "longitude") as! Double)
           let annotationCoordination = CLLocationCoordinate2D(latitude: lat, longitude: lon)
           annotation.coordinate = annotationCoordination
           map.addAnnotation(annotation)
           let viewRegion = MKCoordinateRegion(center: annotationCoordination, latitudinalMeters: 2000, longitudinalMeters: 2000)
           map.setRegion(viewRegion, animated: true)
           map.isScrollEnabled = false
       }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            pinView?.pinTintColor = .brown
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
}
