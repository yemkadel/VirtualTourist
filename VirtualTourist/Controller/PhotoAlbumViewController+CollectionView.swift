//
//  PhotoAlbumViewController+CollectionView.swift
//  VirtualTourist
//
//  Created by Osifeso Adeyemi on 03/09/2020.
//  Copyright © 2020 Osifeso Adeyemi. All rights reserved.
//

import UIKit

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for: indexPath) as! PhotoViewCell
        cell.photo.image = UIImage(named: "VirtualTourist_76")
        let indicator = cell.activityIndicator
        cell.photo.contentMode = .scaleAspectFill
        if let imageData = fetchedResultController.object(at: indexPath).imageData {
            cell.photo.image = UIImage(data: imageData)
            self.setUpActivityIndicator(status: false, activityIndicator: indicator!)
            self.newCollectionButton.isEnabled = true
        }
        else {
            let imageObject = fetchedResultController.object(at: indexPath)
            self.setUpActivityIndicator(status: true, activityIndicator: indicator!)
            if let url = imageObject.imageUrl {
                Client.downloadPhotoImage(photoUrl: url) { (error, data, imageDownloadCount) in
                    if error != nil {
                        print("Fatal Error: \(error?.localizedDescription ?? "Something Bad Occurred")")
                        return
                    }
                    guard let data = data else { return }
                    imageObject.imageData = data
                    cell.photo.image = UIImage(data: data)
                    self.setUpActivityIndicator(status: false, activityIndicator: indicator!)
                    if imageDownloadCount == self.fetchedResultController.fetchedObjects?.count {
                        self.newCollectionButton.isEnabled = true
                    }
                    try? self.dataController.viewContext.save()
                }
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
}
