//
//  PersonalDBRules.swift
//  Sale
//


import UIKit
import CoreData

class PersonalDBRules: Any {
    
    class func addNewPerson(personName name: String, personItn itn: String, personLogin login: String, personPassword password: String, personRole role: Int16) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let newPerson = NSEntityDescription.insertNewObject(forEntityName: "Persons", into: viewContext!)
            newPerson.setValue(name, forKey: "name")
            newPerson.setValue(itn, forKey: "itn")
            newPerson.setValue(login, forKey: "login")
            newPerson.setValue(password, forKey: "password")
            newPerson.setValue(role, forKey: "role")
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления нового сотрудника: " + error.localizedDescription)
            }
        }
    }
    
    class func getAllPersons() -> [NSManagedObject]? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Persons")
            do {
                let allPersons = try viewContext!.fetch(fetchRequest) as? [NSManagedObject]
                return allPersons?.sorted(by: {($0.value(forKeyPath: "name") as! String) < ($1.value(forKeyPath: "name") as! String)})
            } catch let error as NSError {
                NSLog("Ошибка извлечения списка сотрудников: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func isTheSamePersonPresents(personLogin login: String) -> Bool {
        if let allPersons = self.getAllPersons() {
            if allPersons.count != 0 {
                if allPersons.filter ({ $0.value(forKeyPath: "login") as! String == login }).count > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    class func deletePerson(personName name: String, personRole role: Int16) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Persons")
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND role == %d", argumentArray: [name, role])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    viewContext!.delete(fetchResult.first!)
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка удаления сотрудника: " + error.localizedDescription)
            }
        }
    }
    
    class func changePerson(originItn itn: String, personNewName newName: String, personNewLogin newLogin: String, personNewPassword newPassword: String, personNewRole newRole: Int16) {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Persons")
            fetchRequest.predicate = NSPredicate(format: "itn == %@", argumentArray: [itn])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let person = fetchResult.first
                    person!.setValue(newName, forKey: "name")
                    person!.setValue(newLogin, forKey: "login")
                    person!.setValue(newPassword, forKey: "password")
                    person!.setValue(newRole, forKey: "role")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения сотрудника: " + error.localizedDescription)
            }
        }
    }

}
