//
//  CategoriesDBRules.swift
//  Sale
//


import UIKit
import CoreData

class CategoriesDBRules: Any {
    
    class func addNewCategory(categoryName name: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let newCategory = NSEntityDescription.insertNewObject(forEntityName: "Categories", into: viewContext!)
            newCategory.setValue(name, forKey: "name")
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления новой категории товаров: " + error.localizedDescription)
            }
        }
    }
    
    class func getAllCategories() -> [NSManagedObject]? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
            do {
                let allCategories = try viewContext!.fetch(fetchRequest) as? [NSManagedObject]
                return allCategories?.sorted(by: {($0.value(forKeyPath: "name") as! String) < ($1.value(forKeyPath: "name") as! String)})
            } catch let error as NSError {
                NSLog("Ошибка извлечения списка категорий товаров: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func deleteCategory(categoryName name: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
            fetchRequest.predicate = NSPredicate(format: "name == %@", argumentArray: [name])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    viewContext!.delete(fetchResult.first!)
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка удаления категории товаров: " + error.localizedDescription)
            }
        }
    }
    
    class func changeCategory(originCategoryName originName: String, newCategoryName newName: String) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
            fetchRequest.predicate = NSPredicate(format: "name == %@", argumentArray: [originName])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let category = fetchResult.first
                    category!.setValue(newName, forKey: "name")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения категории товаров: " + error.localizedDescription)
            }
        }
    }
    
    class func isTheSameCategoryPresents(categoryName name: String) -> Bool {
        if let allCategories = self.getAllCategories() {
            if allCategories.count != 0 {
                if allCategories.filter ({ $0.value(forKeyPath: "name") as! String == name }).count > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    class func getCategiryByName(categoryName name: String) -> NSManagedObject? {
        if let allCategories = self.getAllCategories() {
            if allCategories.count != 0 {
                return allCategories.filter ({ $0.value(forKeyPath: "name") as! String == name }).first
            }
        }
        return nil
    }
    
    class func getCategoryIndexByName(categoryName name: String) -> Int? {
        return self.getAllCategories()?.firstIndex(of: self.getCategiryByName(categoryName: name)!)
    }

}
