//
//  DataController.swift
//  VirtualTourist
//
//  Created by Osifeso Adeyemi on 16/08/2020.
//  Copyright © 2020 Osifeso Adeyemi. All rights reserved.
//
import Foundation
import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completeion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores(completionHandler: {storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completeion?()
        })
    }
    
    func autoSaveData(interval: TimeInterval = 30){
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveData(interval: interval)
        }
    }
}
