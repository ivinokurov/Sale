//
//  PersonSalesDBRules.swift
//  Sale
//


import UIKit
import CoreData

class PersonSalesDBRules: NSObject {
    
    class func getSelectedSessionPersonAllSales(personName name: String, personRole role: Int16) -> [NSManagedObject]? {
        let viewContext = CommonDBRules.getManagedView()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SessionPersons")
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND role == %d", argumentArray: [name, role])
        
        do {
            let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
            if fetchResult.count > 0 {
                if SessionDBRules.selectedSession == nil {
                    return nil
                } else {
                    let person = fetchResult.first
                    if person?.mutableSetValue(forKey: "sales").allObjects.count == 0 {
                        return nil
                    }
               //     let allPersonSales = person!.mutableSetValue(forKey: "sales").allObjects.filter({ (($0 as! NSManagedObject).value(forKeyPath: "date") as! Date) >= SessionDBRules.selectedSession!.value(forKeyPath: "openDate") as! Date && (($0 as! NSManagedObject).value(forKeyPath: "date") as! Date ) <= SessionDBRules.selectedSession!.value(forKeyPath: "closeDate") as! Date})
                    
                    var allPersonSales = person!.mutableSetValue(forKey: "sales").allObjects
                    allPersonSales = allPersonSales.filter({sale in
                        let date = (sale as! NSManagedObject).value(forKeyPath: "date") as? Date
                        if date == nil {
                            return false
                        }
                        
                        let sessionOpenDate = SessionDBRules.selectedSession!.value(forKeyPath: "openDate") as? Date
                        if sessionOpenDate == nil {
                            return false
                        }
                        
                        let sessionCloseDate = SessionDBRules.selectedSession!.value(forKeyPath: "closeDate") as? Date
                        if sessionCloseDate == nil {
                            return false
                        }
                        
                        if date! >= sessionOpenDate! && date! <= sessionCloseDate! {
                            return true
                        } else {
                            return false
                        }
                    })
                    
                    if allPersonSales.count == 0 {
                        return nil
                    }
                    
                    return allPersonSales.sorted(by: {(($0 as! NSManagedObject).value(forKeyPath: "date") as! Date) < (($1 as! NSManagedObject).value(forKeyPath: "date") as! Date)}) as? [NSManagedObject]
                }
            }
        } catch let error as NSError {
            NSLog("Ошибка извлечения продаж сотрудника: " + error.localizedDescription)
        }
        return nil
    }
    
    class func deleteSessionPersonSales(personName name: String, personRole role: Int16) {
        let viewContext = CommonDBRules.getManagedView()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SessionPersons")
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND role == %d", argumentArray: [name, role])
        
        do {
            let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
            if fetchResult.count > 0 {
                let person = fetchResult.first
                
                if SessionDBRules.selectedSession == nil {
                    return
                } else {
                    let allPersonSales = person!.mutableSetValue(forKey: "sales").allObjects.filter({ (($0 as! NSManagedObject).value(forKeyPath: "date") as! Date) >= SessionDBRules.selectedSession!.value(forKeyPath: "openDate") as! Date && (($0 as! NSManagedObject).value(forKeyPath: "date") as! Date ) <= SessionDBRules.selectedSession!.value(forKeyPath: "closeDate") as! Date})

                
                    for sale in allPersonSales {
                        viewContext!.delete(sale as! NSManagedObject)
                        try viewContext!.save()
                    }
                    
                    person!.setValue(nil, forKey: "sales")
                    try viewContext!.save()
                }
            }
        } catch let error as NSError {
            NSLog("Ошибка удаления продаж сотрудника: " + error.localizedDescription)
        }
    }
    
    class func isProductPresentsInSales(personName name: String, personRole role: Int16, productBarcode code: String) -> Bool {
        let viewContext = CommonDBRules.getManagedView()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SessionPersons")
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND role == %d", argumentArray: [name, role])
        
        do {
            let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
            if fetchResult.count > 0 {
                let person = fetchResult.first
                var found: Bool = false
                
                if SessionDBRules.selectedSession == nil {
                    return found
                } else {
                    let allPersonSales = person!.mutableSetValue(forKey: "sales").allObjects.filter({ (($0 as! NSManagedObject).value(forKeyPath: "date") as! Date) >= SessionDBRules.selectedSession!.value(forKeyPath: "openDate") as! Date && (($0 as! NSManagedObject).value(forKeyPath: "date") as! Date ) <= SessionDBRules.selectedSession!.value(forKeyPath: "closeDate") as! Date})
                    if allPersonSales.count == 0 {
                        return found
                    }
                    
                    allPersonSales.forEach({
                        if ($0 as! NSManagedObject).value(forKey: "code") as! String == code {
                            found = true
                        }
                    })
                    return found
                }
            }
        } catch let error as NSError {
            NSLog("Ошибка определения наличия продукта в продажах сотрудника: " + error.localizedDescription)
        }
        return false
    }
    
    class func addProductInPersonSale(personName: String, personRole role: Int16, productName name: String, productCount count: Float, productBarcode code: String) {
        let viewContext = CommonDBRules.getManagedView()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SessionPersons")
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND role == %d", argumentArray: [personName, role])
        
        do {
            let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
            if fetchResult.count > 0 {
                
                let newSale = NSEntityDescription.insertNewObject(forEntityName: "Sales", into: viewContext!)
                newSale.setValue(name, forKey: "name")
                newSale.setValue(count, forKey: "count")
                newSale.setValue(code, forKey: "code")
                newSale.setValue(Date(), forKey: "date")
                
                let person = fetchResult.first
                person!.mutableSetValue(forKey: "sales").add(newSale)
                try viewContext!.save()
            }
        } catch let error as NSError {
            NSLog("Ошибка добавления продукта в продажи сотрудника: " + error.localizedDescription)
        }
    }
    
    class func getPerosonSalesTotalSum(personName name: String, personRole role: Int16) -> Float {
        let viewContext = CommonDBRules.getManagedView()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SessionPersons")
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND role == %d", argumentArray: [name, role])
        
        var totalSum: Float = 0.0
        
        do {
            let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
            if fetchResult.count > 0 {
                let person = fetchResult.first
                if SessionDBRules.selectedSession == nil {
                    return totalSum
                } else {
               //     let allPersonSales = person!.mutableSetValue(forKey: "sales").allObjects.filter({ (($0 as! NSManagedObject).value(forKeyPath: "date") as! Date) >= SessionDBRules.selectedSession!.value(forKeyPath: "openDate") as! Date && (($0 as! NSManagedObject).value(forKeyPath: "date") as! Date ) <= SessionDBRules.selectedSession!.value(forKeyPath: "closeDate") as! Date})
                    
                    var allPersonSales = person!.mutableSetValue(forKey: "sales").allObjects
                    allPersonSales = allPersonSales.filter({sale in
                        let date = (sale as! NSManagedObject).value(forKeyPath: "date") as? Date
                        if date == nil {
                            return false
                        }
                        
                        let sessionOpenDate = SessionDBRules.selectedSession!.value(forKeyPath: "openDate") as? Date
                        if sessionOpenDate == nil {
                            return false
                        }
                        
                        let sessionCloseDate = SessionDBRules.selectedSession!.value(forKeyPath: "closeDate") as? Date
                        if sessionCloseDate == nil {
                            return false
                        }
                        
                        if date! >= sessionOpenDate! && date! <= sessionCloseDate! {
                            return true
                        } else {
                            return false
                        }
                    })
                    
                    if allPersonSales.count == 0 {
                        return totalSum
                    }
                
                    allPersonSales.forEach({
                        totalSum += (ProductsDBRules.getProductByBarcode(code: ($0 as! NSManagedObject).value(forKey: "code") as! String))!.value(forKey: "price") as! Float * (($0 as! NSManagedObject).value(forKey: "count") as! Float)
                    })
                }
                return totalSum
            }
        } catch let error as NSError {
            NSLog("Ошибка определения суммы продаж сотрудника: " + error.localizedDescription)
        }
        return totalSum
    }

}
