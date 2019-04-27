//
//  OrgInfoDBRules.swift
//  Sale
//


import UIKit
import CoreData

class OrgInfoDBRules: Any {
    
    class func addNewOrgInfo(organizationName orgName: String, pointName pntName: String, pointAddress pntAddress: String, organizationItn orgItn: String, organizationKpp orgKpp: String, organizationTaxType orgTaxType: Int16) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let newOrgInfo = NSEntityDescription.insertNewObject(forEntityName: "OrgInfo", into: viewContext!)
            newOrgInfo.setValue(orgName, forKey: "orgName")
            newOrgInfo.setValue(pntName, forKey: "pointName")
            newOrgInfo.setValue(pntAddress, forKey: "pointAddress")
            newOrgInfo.setValue(orgItn, forKey: "itn")
            newOrgInfo.setValue(orgKpp, forKey: "kpp")
            newOrgInfo.setValue(orgTaxType, forKey: "taxType")
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления данных об организации: " + error.localizedDescription)
            }
        }
    }
    
    class func changeOrgInfo(organizationName newOrgName: String, pointName newPntName: String, pointAddress newPntAddress: String, organizationItn newOrgItn: String, organizationKpp newOrgKpp: String, organizationTaxType newOrgTaxType: Int16) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrgInfo")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let orgInfo = fetchResult.first
                    orgInfo!.setValue(newOrgName, forKey: "orgName")
                    orgInfo!.setValue(newPntName, forKey: "pointName")
                    orgInfo!.setValue(newPntAddress, forKey: "pointAddress")
                    orgInfo!.setValue(newOrgItn, forKey: "itn")
                    orgInfo!.setValue(newOrgKpp, forKey: "kpp")
                    orgInfo!.setValue(newOrgTaxType, forKey: "taxType")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения данных об организации: " + error.localizedDescription)
            }
        }
    }
    
    class func getOrgInfo() -> NSManagedObject? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrgInfo")
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return fetchResult.first!
                }
            } catch let error as NSError {
                NSLog("Ошибка извлечения данных об организации: " + error.localizedDescription)
            }
        }
        return nil
    }

}
