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
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var pictureCell: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var dataController: DataController!
    var location: NSManagedObject!
    var fetchedResultController: NSFetchedResultsController<Image>!
    var images: [NSManagedObject] = []
    var photoUrls: [URL] = []
    var imageDisplayCount = 0
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        // Always use an item count of at least 1 and convert it to a float to use in size calculations
        let numberOfItemsPerRow: Int = 3
        let itemsPerRow = CGFloat(max(numberOfItemsPerRow,1))
        
        // Calculate the sum of the spacing between cells
        let totalSpacing = layout.minimumInteritemSpacing * (itemsPerRow - 1.0)
        
        // Calculate how wide items should be
        var newItemSize = layout.itemSize
        
        newItemSize.width = (pictureCell.bounds.size.width - layout.sectionInset.left - layout.sectionInset.right - totalSpacing) / itemsPerRow
        
        // Use the aspect ratio of the current item size to determine how tall the items should be
        if layout.itemSize.height > 0 {
            let itemAspectRatio = layout.itemSize.width / layout.itemSize.height
            newItemSize.height = newItemSize.width / itemAspectRatio
        }
        
        layout.itemSize = newItemSize
        pictureCell.isScrollEnabled = true
        
      
        pictureCell.collectionViewLayout = layout
    }
    
    fileprivate func setUpFetchedResultController() {
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        let predicate = NSPredicate(format: "location == %@", location)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        images = fetchedResultController.fetchedObjects ?? []
    }

    fileprivate func setUpAnnotationOnMap() {
        let annotation = MKPointAnnotation()
        let lat = CLLocationDegrees(location.value(forKey: "latitude") as! Double)
        let lon = CLLocationDegrees(location.value(forKey: "longitude") as! Double)
        let annotationCoordination = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        annotation.coordinate = annotationCoordination
        map.addAnnotation(annotation)
        let viewRegion = MKCoordinateRegion(center: annotationCoordination, latitudinalMeters: 2000, longitudinalMeters: 2000)
        map.setRegion(viewRegion, animated: true)
    }
    
    fileprivate func setUpCollectionView() {
        pictureCell.delegate = self
        pictureCell.dataSource = self
    }
    
    func setUpActivityIndicator(status: Bool, activityIndicator: UIActivityIndicatorView) {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = !status
        if status {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    fileprivate func fetchImageUrls() {
        Client.getPictureDetails(lat: CLLocationDegrees(location.value(forKey: "latitude") as! Double), lon: CLLocationDegrees(location.value(forKey: "longitude") as! Double)) { (error, photos) in
            if error != nil {
                print("Fatal Error: \(error?.localizedDescription ?? "Something Bad Occurred")")
                return
            }
            guard let photos = photos else { return }
            for photo in  photos {
                let photoUrl = Client.getPhotoUrl(photo: photo)
                self.photoUrls.append(photoUrl)
                let newImage = Image(context: self.dataController.viewContext)
                newImage.imageUrl = photoUrl
                newImage.location = self.location as? Location
                try? self.dataController.viewContext.save()
            }
            self.pictureCell.reloadData()
            self.setUpFetchedResultController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let space:CGFloat = 3.0
//        let widthDimension = (view.frame.size.height - (2 * space)) / 3.0
//        let heightDimension = (view.frame.size.height - (2 * space)) / 2.0
//
//        flowLayout.minimumInteritemSpacing = space
//        flowLayout.minimumLineSpacing = space
//        flowLayout.itemSize = CGSize(width: widthDimension, height: widthDimension)
        setupCollectionViewLayout()
        
        self.newCollectionButton.isEnabled = false
        setUpAnnotationOnMap()
        setUpCollectionView()
        setUpFetchedResultController()
        if images.isEmpty {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for: indexPath) as! PhotoViewCell
        cell.photo.image = UIImage(named: "VirtualTourist_76")
        let indicator = cell.activityIndicator
        cell.photo.contentMode = .scaleAspectFill
        if photoUrls.count != 0 {
            setUpActivityIndicator(status: true, activityIndicator: indicator!)
            Client.downloadPhotoImage(photoUrl: photoUrls[indexPath.row]) { (error, data, imageDownloadCount) in
                if error != nil {
                    print("Fatal Error: \(error?.localizedDescription ?? "Something Bad Occurred")")
                    return
                }
                guard let data = data else { return }
                cell.photo.image = UIImage(data: data)
                cell.photo.contentMode = .scaleAspectFill
                self.fetchedResultController.object(at: indexPath).imageData = data
                try? self.dataController.viewContext.save()
                self.setUpActivityIndicator(status: false, activityIndicator: indicator!)
                if imageDownloadCount == self.fetchedResultController.fetchedObjects?.count {
                    self.newCollectionButton.isEnabled = true
                }
           }
        } else {
            if let imageData = fetchedResultController.object(at: indexPath).imageData {
                cell.photo.image = UIImage(data: imageData)
                self.setUpActivityIndicator(status: false, activityIndicator: indicator!)
                self.newCollectionButton.isEnabled = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataController.viewContext.performAndWait {
            dataController.viewContext.delete(fetchedResultController.object(at: indexPath))
            try? dataController.viewContext.save()
        }
        setUpFetchedResultController()
        collectionView.reloadData()
    }
    
    @IBAction func newCollectionPressed(_ sender: UIButton) {
        photoUrls.removeAll()
        self.newCollectionButton.isEnabled = false
        guard let imageObjects = fetchedResultController.fetchedObjects else { return }
        
        for imageObject in imageObjects {
            dataController.viewContext.performAndWait {
                dataController.viewContext.delete(imageObject)
                try? dataController.viewContext.save()
            }
        }
        fetchImageUrls()
        print("purl is : \(photoUrls.count)")
        pictureCell.reloadData()
    }
    

}
