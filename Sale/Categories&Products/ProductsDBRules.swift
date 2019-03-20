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
    
    class func getCategoryProducts(productCategory category: NSManagedObject) -> [NSManagedObject]? {
        let categoryProducts = category.mutableSetValue(forKey: "products").allObjects as? [NSManagedObject]
        return (categoryProducts?.sorted(by: {($0.value(forKeyPath: "name") as! String) < ($1.value(forKeyPath: "name") as! String)}) ?? nil)
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
                NSLog("Ошибка удаления продукта: " + error.localizedDescription)
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
                NSLog("Ошибка извлечения продукта: " + error.localizedDescription)
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
    
    class func isTheSameBarcodePresents(productBarcode code: String) -> Bool {
        if let allProducts = self.getAllProducts() {
            if allProducts.count != 0 {
                if allProducts.filter ({ $0.value(forKeyPath: "code") as! String == code }).count > 0 {
                    return true
                }
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
        if let allProducts = self.getCategoryProducts(productCategory: category) {
            return allProducts.filter({(product: NSManagedObject) -> Bool in
                (product.value(forKeyPath: "name") as? String)!.lowercased().range(of: name.lowercased()) != nil
            })
        }
        return nil
    }
}


