//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Osifeso Adeyemi on 16/08/2020.
//  Copyright © 2020 Osifeso Adeyemi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    //creating an instance of the core data stack
    let dataController = DataController(modelName: "VirtualTourist")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        
        
        let navigationController = window?.rootViewController as! UINavigationController
        let viewController = navigationController.topViewController as! TravelLocationsMapView
        viewController.dataController = dataController
        return true
    }

}

