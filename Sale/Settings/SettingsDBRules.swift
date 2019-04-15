//
//  SettingsDBRules.swift
//  Sale
//


import UIKit
import CoreData

class SettingsDBRules: Any {
    
    class func addNewAccentColorIndex(colorIndex index: Int16) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let newColorIndex = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: viewContext!)
            newColorIndex.setValue(index, forKey: "colorIndex")
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления индекса акцентного цвета: " + error.localizedDescription)
            }
        }
    }
    
    class func changeAccentColorIndex(colorIndex index: Int16) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let colorIndex = fetchResult.first
                    colorIndex!.setValue(index, forKey: "colorIndex")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения индекса акцентного цвета: " + error.localizedDescription)
            }
        }
    }
    
    class func getAccentColorIndex() -> Int16? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let colorIndex = fetchResult.first
                    return colorIndex?.value(forKey: "colorIndex") as? Int16
                }
            } catch let error as NSError {
                NSLog("Ошибка извлечения индекса акцентного цвета: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func isColorIndexPresents() -> Bool {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return true
                }
            } catch let error as NSError {
                NSLog("Ошибка определения наличия индекса акцентного цвета: " + error.localizedDescription)
            }
        }
        return false
    }
    
    class func addNewBtDeviceName(btDeviceName name: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let newBtDeviceName = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: viewContext!)
            newBtDeviceName.setValue(name, forKey: "btDevice")
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления имени bluetooth устройства: " + error.localizedDescription)
            }
        }
    }
    
    class func changeBtDeviceName(btDeviceName name: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let btDeviceName = fetchResult.first
                    btDeviceName!.setValue(name, forKey: "btDevice")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения имени bluetooth устройства: " + error.localizedDescription)
            }
        }
    }
    
    class func getBtDeviceName() -> String? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let btDeviceName = fetchResult.first
                    return btDeviceName?.value(forKey: "btDevice") as? String
                }
            } catch let error as NSError {
                NSLog("Ошибка извлечения имени bluetooth устройства: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func isBtDeviceNamePresents() -> Bool {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return true
                }
            } catch let error as NSError {
                NSLog("Ошибка определения имени bluetooth устройства: " + error.localizedDescription)
            }
        }
        return false
    }
    
    class func addNewTCPDeviceName(tcpDeviceName name: String?) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let newTCPDeviceName = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: viewContext!)
            newTCPDeviceName.setValue(name, forKey: "tcpDevice")
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления имени TCP устройства: " + error.localizedDescription)
            }
        }
    }
    
    class func changeTCPDeviceName(tcpDeviceName name: String?) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let tcpDeviceName = fetchResult.first
                    tcpDeviceName!.setValue(name, forKey: "tcpDevice")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения имени TCP устройства: " + error.localizedDescription)
            }
        }
    }
    
    class func getTCPDeviceName() -> String? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let tcpDeviceName = fetchResult.first
                    return tcpDeviceName?.value(forKey: "tcpDevice") as? String
                }
            } catch let error as NSError {
                NSLog("Ошибка извлечения имени TCP устройства: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func isTCPDeviceNamePresents() -> Bool {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return true
                }
            } catch let error as NSError {
                NSLog("Ошибка определения имени TCP устройства: " + error.localizedDescription)
            }
        }
        return false
    }

}
