//
//  TravelLocationsMapView.swift
//  VirtualTourist
//
//  Created by Osifeso Adeyemi on 16/08/2020.
//  Copyright © 2020 Osifeso Adeyemi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var map: MKMapView!
    var dataController: DataController!
    var fetchedResultController: NSFetchedResultsController<Location>!
    var locations: [NSManagedObject] = []
    
    fileprivate func setUpFetchedResultController() {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        locations = fetchedResultController.fetchedObjects ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        //creating longTap gesture
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        map.addGestureRecognizer(longTap)
        setUpFetchedResultController()
        addAnnotations()
    }
    
    //action for longtap Gesture
    @objc func longPress(sender: UIGestureRecognizer) {
        if sender.state == .began {
            let locationInView = sender.location(in: map)
            let locationOnMap = map.convert(locationInView, toCoordinateFrom: map)
            let newPin = Location(context: dataController.viewContext)
            newPin.latitude = locationOnMap.latitude
            newPin.longitude = locationOnMap.longitude
            newPin.creationDate = Date()
            try? dataController.viewContext.save()
            setUpFetchedResultController()
            addAnnotations()
        }
        
    }
        
        
    func addAnnotations(){
        
        for location in locations {
            let latitude = CLLocationDegrees((location.value(forKey: "latitude") as? Double) ?? 0.0)
            let longitude = CLLocationDegrees((location.value(forKey: "longitude") as? Double) ?? 0.0)
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            map.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoLibraryVC = storyboard?.instantiateViewController(identifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        photoLibraryVC.dataController = dataController
        photoLibraryVC.latitude = view.annotation?.coordinate.latitude ?? 0.0
        photoLibraryVC.longitude = view.annotation?.coordinate.longitude ?? 0.0
        print("lat: \(photoLibraryVC.latitude ?? 0 )")
        print("lon: \(photoLibraryVC.longitude ?? 0)")
        present(photoLibraryVC, animated: true, completion: nil)
        
    }
    

}

