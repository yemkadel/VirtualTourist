//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Osifeso Adeyemi on 20/08/2020.
//  Copyright © 2020 Osifeso Adeyemi. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var pictureCell: UICollectionView!
    
    var dataController: DataController!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var fetchedResultController: NSFetchedResultsController<Image>!
    var images: [NSManagedObject] = []
    
    fileprivate func setUpFetchedResultController() {
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        images = fetchedResultController.fetchedObjects ?? []
    }

    fileprivate func setUpAnnotationOnMap() {
        let annotation = MKPointAnnotation()
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.coordinate = location
        map.addAnnotation(annotation)
        let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000)
        map.setRegion(viewRegion, animated: true)
    }
    
    fileprivate func setUpCollectionView() {
        pictureCell.delegate = self
        pictureCell.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAnnotationOnMap()
        setUpCollectionView()
        setUpFetchedResultController()
        
        Client.getPictureDetails(lat: latitude, lon: longitude) { (error, data) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
            guard let data = data else {return}
            let newImage = Image(context: self.dataController.viewContext)
            newImage.creationDate = Date()
            newImage.imageData = data
            try? self.dataController.viewContext.save()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numbe = \(fetchedResultController.fetchedObjects?.count ?? 0)")
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for: indexPath) as! PhotoViewCell
        return cell
    }

}
