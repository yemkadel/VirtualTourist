//
//  PhotoDetails.swift
//  VirtualTourist
//
//  Created by Osifeso Adeyemi on 23/08/2020.
//  Copyright © 2020 Osifeso Adeyemi. All rights reserved.
//

import Foundation

struct PhotoDetails: Codable {
    let stat: String
    let photos: PhotoDetailsResponse
    
    enum CodingKeys: String,CodingKey {
        case stat
        case photos
    }
}

struct PhotoDetailsResponse: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    let photo: [Foto]
    
    enum CodingKeys: String,CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}

struct Foto: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    enum CodingKeys: String,CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
}


