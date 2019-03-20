//
//  CommonDBRules.swift
//  Sale
//


import UIKit
import CoreData

class CommonDBRules: Any {
    
    class func getManagedView() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }

}
