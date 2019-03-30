//
//  ProductsDBRules.swift
//  Sale
//


import UIKit
import CoreData

class ProductsDBRules: Any {
    
    static var filteredProducts: [NSManagedObject]?
    
    class func addNewProduct(productCategory category: NSManagedObject, productName name: String, productDesc desc: String, productCount count: Float, productMeasure measure: Int16, productPrice price: Float, productBarCode code: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let newProduct = NSEntityDescription.insertNewObject(forEntityName: "Products", into: viewContext!)
            newProduct.setValue(name, forKey: "name")
            newProduct.setValue(desc, forKey: "desc")
            newProduct.setValue(count, forKey: "count")
            newProduct.setValue(measure, forKey: "measure")
            newProduct.setValue(price, forKey: "price")
            newProduct.setValue(code, forKey: "code")
            (category.mutableSetValue(forKey: "products")).add(newProduct)
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления нового товара: " + error.localizedDescription)
            }
        }
    }
    
    class func getAllProductsForCategory(productCategory category: NSManagedObject) -> [NSManagedObject]? {
        let categoryProducts = category.mutableSetValue(forKey: "products").allObjects as? [NSManagedObject]
        return (categoryProducts?.sorted(by: {($0.value(forKeyPath: "name") as! String) < ($1.value(forKeyPath: "name") as! String)}) ?? nil)
        }
    
    class func getCategoryProductsTotalPrice(productCategory category: NSManagedObject) -> Float {
        let categoryProducts = category.mutableSetValue(forKey: "products").allObjects as? [NSManagedObject]
        var price: Float = 0.0
        if (categoryProducts?.count)! > 0 {
            for product in categoryProducts! {
                let productCount = product.value(forKey: "count") as! Float
                let productPrice = product.value(forKey: "price") as! Float
                price = price + productCount * productPrice
            }
        }
        return price
    }
    
    class func deleteProductByBarcode(code: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [code])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    viewContext!.delete(fetchResult.first!)
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка удаления товара: " + error.localizedDescription)
            }
        }
    }
    
    class func deleteCategoryProducts(productCategory category: NSManagedObject) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            do {
                if self.getAllProductsForCategory(productCategory: category)?.count == 0 {
                    return
                }
                for product in self.getAllProductsForCategory(productCategory: category)! {
                    viewContext!.delete(product)
                }
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка удаления товара: " + error.localizedDescription)
            }
        }
    }
    
    class func getProductByBarcode(code: String) -> NSManagedObject? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [code])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return fetchResult.first
                } else {
                    return nil
                }
            } catch let error as NSError {
                NSLog("Ошибка извлечения товара: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func getProductNameByBarcode(code: String) -> String?{
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [code])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return fetchResult.first!.value(forKeyPath: "name") as? String
                }
            } catch let error as NSError {
                NSLog("Ошибка извлечения названия товара: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func getAllProducts() -> [NSManagedObject]? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            do {
                let allProducts = try viewContext!.fetch(fetchRequest) as? [NSManagedObject]
                return allProducts?.sorted(by: {($0.value(forKeyPath: "name") as! String) < ($1.value(forKeyPath: "name") as! String)})
            } catch let error as NSError {
                NSLog("Ошибка извлечения списка товаров: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func isTheSameBarcodePresents(productBarcode barcode: String) -> Bool {
        if let allProducts = self.getAllProducts() {
            if allProducts.count != 0 {
                if allProducts.filter ({ $0.value(forKeyPath: "code") as! String == barcode }).count > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    class func changeProductCount(productBarcode barcode: String, productCount newCount: Float) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [barcode])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let product = fetchResult.first
                    product!.setValue(newCount, forKey: "count")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения количества товара: " + error.localizedDescription)
            }
        }
    }
    
    class func isBarcodePresents(productBarcode code: String) -> Bool {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [code])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return true
                }
            } catch let error as NSError {
                NSLog("Ошибка определения товара: " + error.localizedDescription)
            }
        }
        return false
    }
    
    class func changeProduct(originBarcode originCode: String, productNewName newName: String, productNewDesc newDesc: String, productNewCount newCount: Float, productNewMeasure newMeasure: Int16, productNewPrice newPrice: Float, productNewBarcode newCode: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [originCode])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let product = fetchResult.first
                    product!.setValue(newName, forKey: "name")
                    product!.setValue(newDesc, forKey: "desc")
                    product!.setValue(newCount, forKey: "count")
                    product!.setValue(newMeasure, forKey: "measure")
                    product!.setValue(newPrice, forKey: "price")
                    product!.setValue(newCode, forKey: "code")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения категории товаров: " + error.localizedDescription)
            }
        }
    }
    
    class func filterProductsByName(productName name: String, productCategory category: NSManagedObject) -> [NSManagedObject]? {
        if let allProducts = self.getAllProductsForCategory(productCategory: category) {
            return allProducts.filter({(product: NSManagedObject) -> Bool in
                (product.value(forKeyPath: "name") as? String)!.lowercased().range(of: name.lowercased()) != nil
            })
        }
        return nil
    }
    
    class func getProductsCountByBarcode(productBarcode barcode: String) -> Float? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [barcode])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return fetchResult.first!.value(forKeyPath: "count") as? Float
                }
            } catch let error as NSError {
                NSLog("Ошибка извлечения количества товара: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func getProductPriceByBarcode(productBarcode barcode: String) -> Float? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            fetchRequest.predicate = NSPredicate(format: "code == %@", argumentArray: [barcode])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return fetchResult.first!.value(forKeyPath: "price") as? Float
                }
            } catch let error as NSError {
                NSLog("Ошибка извлечения цены товара: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func getCategoryProductIndexByName(productCategory category: NSManagedObject, productBarcode barcode: String) -> Int? {
        return self.getAllProductsForCategory(productCategory: category)?.firstIndex(of: self.getProductByBarcode(code: barcode)!)
    }
    
    class func getProductMeasure(product: NSManagedObject) -> String {
        let measure: Int = Int((product.value(forKeyPath: "measure") as? Int16)!)
    
        var measureTail: String!
        switch measure {
            case Utilities.measures.items.rawValue:
            do {
                measureTail = " шт."
            }
            case Utilities.measures.kilos.rawValue:
            do {
                measureTail = " кг."
            }
            case Utilities.measures.liters.rawValue:
            do {
                measureTail = " л."
            }
            default: break
        }
        return measureTail
    }
}


