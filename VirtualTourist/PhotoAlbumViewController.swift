//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Osifeso Adeyemi on 20/08/2020.
//  Copyright © 2020 Osifeso Adeyemi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewCell {
    @IBOutlet weak var map: MKMapView!
    
    var dataController: DataController!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!

    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        let annotation = MKPointAnnotation()
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.coordinate = location
        map.addAnnotation(annotation)
        let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
        map.setRegion(viewRegion, animated: true)
        map.reloadInputViews()
        
    }


}
