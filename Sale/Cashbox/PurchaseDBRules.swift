//
//  PurchaseDBRules.swift
//  Sale
//


import UIKit
import CoreData

class PurchaseDBRules: Any {
    
    class func addNewProductInPurchase(productBarCode code: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let newProductInPurchase = NSEntityDescription.insertNewObject(forEntityName: "Purchase", into: viewContext!)
            newProductInPurchase.setValue(code, forKey: "code")
            newProductInPurchase.setValue(0.0, forKey: "count")
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления товара в покупку: " + error.localizedDescription)
            }
        }
    }
    
    class func isTheSameProductPresentsInPurchase(productBarcode code: String) -> Bool {
        if let allProductsInPurchase = self.getAllProductsInPurchase() {
            if allProductsInPurchase.count != 0 {
                if allProductsInPurchase.filter ({ $0.value(forKeyPath: "code") as! String == code }).count > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    class func getAllProductsInPurchase() -> [NSManagedObject]? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Purchase")
            do {
                let allProductsInPurchase = try viewContext!.fetch(fetchRequest) as? [NSManagedObject]
                return allProductsInPurchase?.sorted(by: {($0.value(forKeyPath: "code") as! String) < ($1.value(forKeyPath: "code") as! String)})
            } catch let error as NSError {
                NSLog("Ошибка извлечения списка товаров покупки: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func deleteAllProductsInPurchase() -> [NSManagedObject]? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Purchase")
            do {
                let allProductsInPurchase = try viewContext!.fetch(fetchRequest) as? [NSManagedObject]
                if allProductsInPurchase != nil {
                    for product in allProductsInPurchase! {
                        viewContext!.delete(product)
                    }
                }
            } catch let error as NSError {
                NSLog("Ошибка удаления товаров из покупки: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func changeProductInPurchaseCount(productBarcode code: String, productNewCount newCount: Float) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Purchase")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [code])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let product = fetchResult.first
                    product!.setValue(newCount, forKey: "count")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения количества товара в покупке: " + error.localizedDescription)
            }
        }
    }

}
