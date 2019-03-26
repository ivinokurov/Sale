//
//  PurchaseDBRules.swift
//  Sale
//


import UIKit
import CoreData

class PurchaseDBRules: Any {
    
    class func addNewProductInPurchase(productName name: String, productBarcode code: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let newProductInPurchase = NSEntityDescription.insertNewObject(forEntityName: "Purchase", into: viewContext!)
            newProductInPurchase.setValue(name, forKey: "name")
            newProductInPurchase.setValue(code, forKey: "code")
            newProductInPurchase.setValue(1.0, forKey: "count")
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления товара в покупку: " + error.localizedDescription)
            }
        }
    }
    
    class func isTheSameProductPresentsInPurchase(productBarcode barcode: String) -> Bool {
        if let allProductsInPurchase = self.getAllProductsInPurchase() {
            if allProductsInPurchase.count != 0 {
                if allProductsInPurchase.filter ({ $0.value(forKeyPath: "code") as! String == barcode }).count > 0 {
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
                return allProductsInPurchase?.sorted(by: {($0.value(forKeyPath: "name") as! String) < ($1.value(forKeyPath: "name") as! String)})
            } catch let error as NSError {
                NSLog("Ошибка извлечения списка товаров покупки: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func deleteProductInPurchaseByBarcode(productBarcode code: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Purchase")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [code])
            do {
                let productsToDelete = try viewContext!.fetch(fetchRequest) as? [NSManagedObject]
                if productsToDelete != nil {
                    viewContext!.delete((productsToDelete?.first)!)
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка удаления товара из покупки: " + error.localizedDescription)
            }
        }
    }
    
    class func deleteAllProductsInPurchase() {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Purchase")
            do {
                let allProductsInPurchase = try viewContext!.fetch(fetchRequest) as? [NSManagedObject]
                if allProductsInPurchase != nil {
                    for product in allProductsInPurchase! {
                        viewContext!.delete(product)
                    }
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка удаления товаров из покупки: " + error.localizedDescription)
            }
        }
    }
    
    class func updatePurchasedProductsCount() {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Purchase")
            do {
                let allProductsInPurchase = try viewContext!.fetch(fetchRequest) as? [NSManagedObject]
                if allProductsInPurchase != nil {
                    for product in allProductsInPurchase! {
                        if let productBarcode = product.value(forKey: "code") as? String {
                            let productNewCount = ProductsDBRules.getProductsCountByBarcode(productBarcode: productBarcode)! - (product.value(forKey: "count") as? Float)!
                            ProductsDBRules.changeProductCount(productBarcode: productBarcode, productCount: productNewCount)
                        }
                    }
                }
            } catch let error as NSError {
                NSLog("Ошибка обновления количества товаров после покупки: " + error.localizedDescription)
            }
        }
    }
    
    class func addProductInPurchase(productBarcode code: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Purchase")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [code])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let product = fetchResult.first
                    let productCount = product!.value(forKey: "count") as? Float
                    product!.setValue(productCount! + 1, forKey: "count")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения количества товара в покупке: " + error.localizedDescription)
            }
        }
    }
    
    class func getProductIndexByBarcode(productBarcode code: String) -> Int? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Purchase")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [code])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return self.getAllProductsInPurchase()?.firstIndex(of: fetchResult.first!)
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения количества товара в покупке: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func getProductsCountInPurchase(productBarcode code: String) -> Float? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Purchase")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [code])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return fetchResult.first!.value(forKey: "count") as? Float
                }
            } catch let error as NSError {
                NSLog("Ошибка получения количества товара в покупке: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func isProductCanBeAddedToPurchase(controller: UIViewController, productBarcode code: String) -> Bool {
        if ProductsDBRules.getProductsCountByBarcode(productBarcode: code)! - (self.getProductsCountInPurchase(productBarcode: code) ?? 0 ) > 0 {
            return true
        } else {
            Utilities.showErrorAlertView(alertTitle: "ПОКУПКА", alertMessage: "Этот товар уже отсутствует!")
            return false
        }
    }
    
    class func getPurchaseTotalPrice() -> Float {
        var purchasePrice: Float = 0.0
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Purchase")
            do {
                let allProductsInPurchase = try viewContext!.fetch(fetchRequest) as? [NSManagedObject]
                if allProductsInPurchase != nil {
                    for product in allProductsInPurchase! {
                        purchasePrice = purchasePrice + (self.getProductsCountInPurchase(productBarcode: (product.value(forKey: "code") as? String)!) ?? 0) * (ProductsDBRules.getProductPriceByBarcode(productBarcode: (product.value(forKey: "code") as? String)!) ?? 0)
                    }
                }
            } catch let error as NSError {
                NSLog("Ошибка удаления товаров из покупки: " + error.localizedDescription)
            }
        }
        return purchasePrice
    }

}
