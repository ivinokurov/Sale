//
//  SessionDBRules.swift
//  Sale
//


import UIKit
import CoreData

class SessionDBRules: NSObject {
    
    class func addNewSessionState(sessionState state: Bool) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let sessionState = NSEntityDescription.insertNewObject(forEntityName: "Sessions", into: viewContext!)
            sessionState.setValue(state, forKey: "isOpened")
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления состояния сессии: " + error.localizedDescription)
            }
        }
    }
    
    class func getSessionState() -> Bool? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let isSessionOpened = fetchResult.first
                    return isSessionOpened?.value(forKey: "isOpened") as? Bool
                }
            } catch let error as NSError {
                NSLog("Ошибка извлечения состояния сессии: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func changeSessionState(sessionState state: Bool) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let sessionState = fetchResult.first
                    sessionState!.setValue(state, forKey: "isOpened")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения состояния сессии: " + error.localizedDescription)
            }
        }
    }
    
}
