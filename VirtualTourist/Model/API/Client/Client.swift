//
//  Client.swift
//  VirtualTourist
//
//  Created by Osifeso Adeyemi on 22/08/2020.
//  Copyright © 2020 Osifeso Adeyemi. All rights reserved.
//

import Foundation
import UIKit

class Client {
    
    static let APIKey = "6705fd435352f4a72b472fd31a25ebeb"
    static let APISecret = "1b7cfa436e8e7d25"
    static let numberOfImagesReturnedPerPage = 50
    static var imageDownloadCount = 0
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let api_key = "&api_key=\(Client.APIKey)"
        static let format = "&format=json&nojsoncallback=1"
        static let base2 = ".staticflickr.com/"
        static let numberPerPage = "&per_page=\(numberOfImagesReturnedPerPage)"
        
        case search(Double,Double)
        case fetchImage(Int,String,String,String)
        
        var stringValue: String {
            switch self {
            case .search(let lat, let lon):
                return Endpoints.base + Endpoints.api_key + "&lat=\(lat)&lon=\(lon)" + Endpoints.numberPerPage + Endpoints.format + "&page=\(Int.random(in: 1..<10))"
            case .fetchImage(let farmId, let serverId,let id,let secret):
                return "https://farm\(farmId)" + Endpoints.base2 + "\(serverId)/\(id)_\(secret).jpg"
            }
        }
        
        var url: URL {
            return  URL(string: stringValue)!
        }
    }
    
    class func taskForGetRequest(url:URL, completion: @escaping (Error?,Data?) -> Void){
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(error,nil)
                }
                return
            }
            guard let data = data else { return }
            DispatchQueue.main.async {
                completion(nil,data)
            }
        }
        task.resume()
    }
    
    class func downloadPhotoImage(photoUrl: URL, completion: @escaping (Error?,Data?,Int) -> Void) {
        taskForGetRequest(url: photoUrl) { (error, data) in
           if error != nil {
                DispatchQueue.main.async {
                    completion(error,nil,imageDownloadCount)
                }
                return
            }
            imageDownloadCount += 1
            guard let data = data else { return }
            DispatchQueue.main.async {
                completion(nil,data,imageDownloadCount)
            }
        }
    }
    
    class func getPhotoUrl(photo: Foto) -> URL {
        return Endpoints.fetchImage(photo.farm, photo.server, photo.id, photo.secret).url
    }
    
    class func getPictureDetails(lat: Double,lon: Double, completion: @escaping (Error?,[Foto]?) -> Void) {
        taskForGetRequest(url: Endpoints.search(lat, lon).url) { (error, data) in
            print("URL STRING: --> \(Endpoints.search(lat, lon).stringValue)")
            if error != nil {
                DispatchQueue.main.async {
                    completion(error,nil)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(PhotoDetails.self, from: data!)
                let images: [Foto] = responseObject.photos.photo
                DispatchQueue.main.async {
                    completion(nil,images)
                }
            }catch {
                DispatchQueue.main.async {
                    completion(error,nil)
                }
            }
            
        }
    }
}
