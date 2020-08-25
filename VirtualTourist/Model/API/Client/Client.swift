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
    static let numberOfImagesReturnedPerPage = 10
    
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
                return Endpoints.base + Endpoints.api_key + "&lat=\(lat)&lon=\(lon)" + Endpoints.numberPerPage + Endpoints.format
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
    
    class func downloadPictures(farmId: Int,serverId: String,id: String,secret: String, completion: @escaping (Error?,Data?) -> Void) {
        taskForGetRequest(url: Endpoints.fetchImage(farmId, serverId, id, secret).url) { (error, data) in
           if error != nil {
                DispatchQueue.main.async {
                    completion(error,nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(nil,data)
            }
        }
    }
    
    class func getPictureDetails(lat: Double,lon: Double, completion: @escaping (Error?,Data?) -> Void) {
        taskForGetRequest(url: Endpoints.search(lat, lon).url) { (error, data) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(error,nil)
                }
                return
            }
            do {
                let detailsData = try JSONDecoder().decode(PhotoDetails.self, from: data!)
                var images: [Data] = []
                for n in 0..<numberOfImagesReturnedPerPage {
                    downloadPictures(farmId: detailsData.photos.photo[n].farm, serverId: detailsData.photos.photo[n].server, id: detailsData.photos.photo[n].id, secret: detailsData.photos.photo[n].secret) { (error, data) in
                        if error != nil {
                            DispatchQueue.main.async {
                                print("Something went wrong")
                                completion(error,nil)
                            }
                            return
                        }
                        if let data = data {
                            //images.append(data)
                            DispatchQueue.main.async {
                                               completion(nil,data)
                                           }
                        }
                    }
                }
            }catch {
                DispatchQueue.main.async {
                    completion(error,nil)
                }
            }
            
        }
    }
}
