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

class PhotoAlbumViewController: UIViewController,UICollectionViewDataSource,NSFetchedResultsControllerDelegate {
    
    //MARK:- Properties
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var pictureCell: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var dataController: DataController!
    var pin: NSManagedObject!
    var fetchedResultController: NSFetchedResultsController<Photo>!
    var photoObjects: [NSManagedObject] = []
    
    //MARK:- View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        setupCollectionViewLayout()
        self.newCollectionButton.isEnabled = false
        setUpAnnotationOnMap()
        setUpCollectionView()
        setUpFetchedResultController()
        if photoObjects.isEmpty {
            fetchImageUrls()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultController = nil
    }
    
    //MARK:- CollectionView
    @IBAction func newCollectionPressed(_ sender: UIButton) {
        photoObjects.removeAll()
        Client.imageDownloadCount = 0
        self.newCollectionButton.isEnabled = false
        guard let imageObjects = fetchedResultController.fetchedObjects else { return }
        
        for imageObject in imageObjects {
            dataController.viewContext.performAndWait {
                dataController.viewContext.delete(imageObject)
                try? dataController.viewContext.save()
            }
        }
        fetchImageUrls()
        pictureCell.reloadData()
    }
    
    func setupCollectionViewLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        let numberOfImagesPerRow = CGFloat(3)
        let spaceBetweenItems = flowLayout.minimumInteritemSpacing * (numberOfImagesPerRow - 1.0)
        var imageSize = flowLayout.itemSize
        imageSize.width = (pictureCell.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - spaceBetweenItems) / numberOfImagesPerRow
        
        if flowLayout.itemSize.height > 0 {
            let imageAspectRatio = flowLayout.itemSize.width / flowLayout.itemSize.height
            imageSize.height = imageSize.width / imageAspectRatio
        }
        flowLayout.itemSize = imageSize
        pictureCell.isScrollEnabled = true
        pictureCell.collectionViewLayout = flowLayout
    }
    
    func setUpCollectionView() {
        pictureCell.delegate = self
        pictureCell.dataSource = self
    }
    
    //MARK:- Fetching Data
    func setUpFetchedResultController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        photoObjects = fetchedResultController.fetchedObjects ?? []
    }
    
    func fetchImageUrls() {
        Client.getPictureDetails(lat: CLLocationDegrees(pin.value(forKey: "latitude") as! Double), lon: CLLocationDegrees(pin.value(forKey: "longitude") as! Double)) { (error, photos) in
            if error != nil {
                print("Fatal Error: \(error?.localizedDescription ?? "Something Bad Occurred")")
                return
            }
            guard let photos = photos else { return }
            for photo in  photos {
                let photoUrl = Client.getPhotoUrl(photo: photo)
                let newImage = Photo(context: self.dataController.viewContext)
                newImage.imageUrl = photoUrl
                newImage.pin = self.pin as? Pin
                try? self.dataController.viewContext.save()
                self.setUpFetchedResultController()
                self.pictureCell.reloadData()
            }
           
        }
    }
    
    func setUpActivityIndicator(status: Bool, activityIndicator: UIActivityIndicatorView) {
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = !status
        if status {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

}

