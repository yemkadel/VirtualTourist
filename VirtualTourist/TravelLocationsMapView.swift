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
            let newLocation = Location(context: dataController.viewContext)
            newLocation.latitude = locationOnMap.latitude
            newLocation.longitude = locationOnMap.longitude
            newLocation.creationDate = Date()
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            pinView?.pinTintColor = .blue
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("enter 1")
        let photoLibraryVC = storyboard?.instantiateViewController(identifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        photoLibraryVC.dataController = dataController
        for mapLocation in locations {
            let locationLatitude = CLLocationDegrees((mapLocation.value(forKey: "latitude") as? Double) ?? 0.0)
            let locationLongitude = CLLocationDegrees((mapLocation.value(forKey: "longitude") as? Double) ?? 0.0)
            let annotationLatitude = view.annotation?.coordinate.latitude
            let annotationLongitude = view.annotation?.coordinate.longitude
            
            if locationLatitude == annotationLatitude, locationLongitude == annotationLongitude {
                photoLibraryVC.location = mapLocation
            }
        }
        print("enter 2")
        navigationController?.pushViewController(photoLibraryVC, animated: true)
        //present(photoLibraryVC, animated: true, completion: nil)
    }
    

}

