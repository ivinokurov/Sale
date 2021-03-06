//
//  SessionDBRules.swift
//  Sale
//


import UIKit
import CoreData


class SessionDBRules: NSObject {
    
    static var currentSession: NSManagedObject? = nil
    static var selectedSession: NSManagedObject? = nil
    
    class func getAllSessions() -> [NSManagedObject]? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
            do {
                let allSessions = try viewContext!.fetch(fetchRequest) as? [NSManagedObject]
                return allSessions?.sorted(by: {($0.value(forKeyPath: "openDate") as! Date) < ($1.value(forKeyPath: "openDate") as! Date)})
            } catch let error as NSError {
                NSLog("Ошибка извлечения списка смен: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func openNewSession() {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            let session = NSEntityDescription.insertNewObject(forEntityName: "Sessions", into: viewContext!)
            session.setValue(true, forKey: "isOpened")
            session.setValue(Date(), forKey: "openDate")
            session.setValue(nil, forKey: "closeDate")
            
            self.currentSession = session
            
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления состояния сессии: " + error.localizedDescription)
            }
        }
    }
    
    class func isCurrentSessionOpened() -> Bool? {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            if self.currentSession == nil {
                return false
            } else {
                return self.currentSession!.value(forKey: "isOpened") as? Bool
            }
        }
        return nil
    }
    
    class func closeCurrentSession() {
        let viewContext = CommonDBRules.getManagedView()
        if viewContext != nil {
            for session in self.getAllSessions()! {
                if session === self.currentSession {
                    session.setValue(false, forKey: "isOpened")
                    session.setValue(Date(), forKey: "closeDate")
                }
                do {
                    try viewContext!.save()
                } catch let error as NSError {
                    NSLog("Ошибка звкрытия смены: " + error.localizedDescription)
                }
            }
            if self.currentSession != nil {
                self.currentSession!.setValue(false, forKey: "isOpened")
                self.currentSession!.setValue(Date(), forKey: "closeDate")
                self.currentSession = nil
            }
        }
    }
    
    class func addPersonInCurrentSession(personName name: String, personRole role: Int16, personItn itn: String) {
        let viewContext = CommonDBRules.getManagedView()
        
        do {
            if let session = self.currentSession {
                let sessionPerson = NSEntityDescription.insertNewObject(forEntityName: "SessionPersons", into: viewContext!)
                sessionPerson.setValue(name, forKey: "name")
                sessionPerson.setValue(role, forKey: "role")
                sessionPerson.setValue(itn, forKey: "itn")
                
                session.mutableSetValue(forKey: "persons").add(sessionPerson)
                try viewContext!.save()
            }
        } catch let error as NSError {
            NSLog("Ошибка добавления сотрудника в смену: " + error.localizedDescription)
        }
    }
    
    class func isPersonPresentsInCurrentSession(personName name: String, personRole role: Int16) -> Bool {
        if let session = self.currentSession {
            let allSessionPersons = session.mutableSetValue(forKey: "persons")
            if allSessionPersons.allObjects.filter({ (($0 as! NSManagedObject).value(forKeyPath: "name") as! String) == name && (($0 as! NSManagedObject).value(forKeyPath: "role") as! Int16 == role) }).count > 0 {
                return true
            }
        }
        return false
    }
    
    class func deleteSession(sessionToDelete session: NSManagedObject) {
        let viewContext = CommonDBRules.getManagedView()
        
        do {
            let allSessionPersons = session.mutableSetValue(forKey: "persons").allObjects as? [NSManagedObject]

            for person in allSessionPersons! {
                let allPersonSales = person.mutableSetValue(forKey: "sales").allObjects.filter({ (($0 as! NSManagedObject).value(forKeyPath: "date") as! Date) >= session.value(forKeyPath: "openDate") as! Date && (($0 as! NSManagedObject).value(forKeyPath: "date") as! Date ) <= session.value(forKeyPath: "closeDate") as! Date})
                
                for sale in allPersonSales {
                    viewContext!.delete(sale as! NSManagedObject)
                    try viewContext!.save()
                }
                
                let name = person.value(forKey: "name") as! String
                let role = person.value(forKey: "role") as! Int16
                
                PersonSalesDBRules.deleteSessionPersonSales(personName: name, personRole: role)
                person.setValue(nil, forKey: "sales")
            }
            viewContext!.delete(session)
            try viewContext!.save()
        } catch let error as NSError {
            NSLog("Ошибка удаления смены: " + error.localizedDescription)
        }
    }
    
}
