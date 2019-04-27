//
//  ReportPersonsTableViewController.swift
//  Sale
//


import UIKit
import CoreData

class ReportPersonsTableViewController: UITableViewController {
    
    @IBOutlet var sessionsView: UIView!
    @IBOutlet weak var dismissSessionsButton: UIButton!
    @IBOutlet weak var deleteAllSessionsButton: UIButton!
    @IBOutlet weak var sessionsTableView: UITableView!
        
    var parentView: UIView? = nil
    var currentPersonItn: String? = nil
    var selectedIndexPath: IndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parentView = Utilities.mainController!.view
    
        self.currentPersonItn = PersonalDBRules.getPersonItnByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)
        
        self.sessionsTableView.dataSource = self
        self.sessionsTableView.delegate = self
        
        self.sessionsTableView.tableFooterView = UIView()
        self.sessionsTableView.layer.cornerRadius = 8
        
        self.tableView.tableFooterView = UIView()
        self.tableView.isEditing = false
        
        self.addSessionBarItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Utilities.customizePopoverView(customizedView: self.sessionsView)
        Utilities.createDismissButton(button: self.dismissSessionsButton)
        
        self.deleteAllSessionsButton.tintColor = UIColor.red // Utilities.accentColor
        self.navigationItem.rightBarButtonItem?.tintColor = Utilities.accentColor
        self.tableView.reloadData()
    }
    
    func showSessionsView() {
        self.sessionsView.center = Utilities.getParentViewCenterPoint(parentView: self.parentView)
        self.sessionsView.alpha = 0.0
        
        self.sessionsView.autoresizingMask =  [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.sessionsView.alpha = CGFloat(Utilities.popoverViewAlpha)
        }), completion: { (completed: Bool) in
        })
        
        if self.selectedIndexPath == nil && (SessionDBRules.getAllSessions()?.count ?? 0) > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            self.sessionsTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.sessionsTableView.delegate?.tableView!(self.sessionsTableView, didSelectRowAt: indexPath)
        }
        
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.sessionsView)
        
        Utilities.makeViewFlexibleAppearance(view: self.sessionsView)
        self.dismissSessionsButton.tintColor = Utilities.accentColor
    }
    
    func addSessionBarItem() {
        let rightItemBarButton = UIBarButtonItem(image: Images.team, style: .done, target: self, action: #selector(self.showSessionList))
        self.navigationItem.rightBarButtonItem = rightItemBarButton
    }
    
    @objc func showSessionList() {
        self.showSessionsView()
        
        self.sessionsTableView.reloadData()
    }
    
    @IBAction func dismissSessionsView(_ sender: UIButton) {
        Utilities.decorateDismissButtonTap(buttonToDecorate: sender, viewToDismiss: self.sessionsView)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView != self.sessionsTableView {
            return (SessionDBRules.selectedSession?.mutableSetValue(forKey: "persons"))?.count ?? 0
        } else {
            let sessionsCount = SessionDBRules.getAllSessions()?.count ?? 0
            if SessionDBRules.isCurrentSessionOpened() ?? false {
                if sessionsCount > 0 {
                    return sessionsCount - 1
                } else {
                    return 0
                }
            } else {
                return sessionsCount
            }
        }
    }
    
    func updateSalesTable() {
        let navController = Utilities.reportsSplitController!.viewControllers[1] as! UINavigationController
        let salesController = navController.topViewController as! ReportSalesViewController
        salesController.showWaitView()
        salesController.personSalesTableView.reloadData()
        salesController.dismissWaitView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView != self.sessionsTableView {
            let person = SessionDBRules.selectedSession?.mutableSetValue(forKey: "persons").allObjects.sorted(by: {person1, person2 in
                guard let person1Name = (person1 as! NSManagedObject).value(forKeyPath: "name") as? String else { return false }
                guard let person2Name = (person2 as! NSManagedObject).value(forKeyPath: "name") as? String else { return false }
                if person1Name < person2Name {
                        return true
                    } else {
                        return false
                    }
                })[indexPath.row] as! NSManagedObject
            
            Utilities.reportsSplitController!.reportsSelectedPersonName = person.value(forKeyPath: "name") as? String
            Utilities.reportsSplitController!.reportsSelectedPersonRole = person.value(forKeyPath: "role") as? Int16
            
            self.updateSalesTable()
        } else {
            SessionDBRules.selectedSession = SessionDBRules.getAllSessions()![indexPath.row]
            
            self.sessionsTableView.cellForRow(at: indexPath)?.tintColor = Utilities.accentColor
            
            if self.selectedIndexPath == nil {
                self.selectedIndexPath = indexPath
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView == self.sessionsTableView ? true : false
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == self.sessionsTableView {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            
            let deleteAction = UIContextualAction(style: .normal, title:  "Удалить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
                let deleteSession: (() -> ()) = {
                    let session = SessionDBRules.getAllSessions()?[indexPath.row]
                    SessionDBRules.deleteSession(sessionToDelete: session!)
                        
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                    tableView.endUpdates()
                        
                    SessionDBRules.selectedSession = session
                    self.tableView.reloadData()
                    self.updateSalesTable()
                }
                    
            DeleteAlertView().showDeleteAlertView(parentView: self.parentView!, messageToShow: "Удалить эту смену?", deleteHandler: deleteSession)

            success(true)
            })
            deleteAction.backgroundColor = Utilities.deleteActionBackgroundColor
                
            return UISwipeActionsConfiguration(actions: [deleteAction])
            } else {
            return UISwipeActionsConfiguration(actions: [])
            }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if tableView != self.sessionsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reportsRersonsCellId", for: indexPath)
                
                let allPersons = SessionDBRules.selectedSession?.mutableSetValue(forKey: "persons").allObjects.sorted(by: { (($0 as! NSManagedObject).value(forKeyPath: "name") as! String) < (($1 as! NSManagedObject).value(forKeyPath: "name") as! String)})
                
                let cellPerson = allPersons![indexPath.row] as! NSManagedObject
                
                let cellPersonName = cellPerson.value(forKeyPath: "name") as? String
                let cellPersonRole = cellPerson.value(forKeyPath: "role") as! Int16
                
                cell.textLabel?.text = cellPersonName
                cell.detailTextLabel?.text = Utilities.roleNames[Int(cellPersonRole)]!
                if Int(cellPersonRole) == Utilities.personRole.admin.rawValue {
                    cell.detailTextLabel?.textColor = Utilities.accentColor
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
                cell.accessoryView?.addSubview(UILabel())
                
                Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
                
                let firstPerson = allPersons![0] as! NSManagedObject
                let firstPersonName = firstPerson.value(forKeyPath: "name") as? String
                let firstPersonRole = firstPerson.value(forKeyPath: "role") as! Int16
                tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
                
                Utilities.reportsSplitController!.reportsSelectedPersonName = firstPersonName
                Utilities.reportsSplitController!.reportsSelectedPersonRole = firstPersonRole
                
                self.updateSalesTable()

            return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCellId", for: indexPath)

                let session = SessionDBRules.getAllSessions()![indexPath.row]
                let openDate = session.value(forKeyPath: "openDate") as? Date
                let closeDate = session.value(forKeyPath: "closeDate") as? Date
                                
                cell.textLabel?.text = "СМЕНА"
                cell.detailTextLabel?.text = "Начало: " + Utilities.getDateStr(dateToString: openDate!)! + ". Завершение: " + (closeDate == nil ? "..." : Utilities.getDateStr(dateToString: closeDate!)! + ".")
                cell.imageView?.tintColor = Utilities.accentColor
                
                if let session = SessionDBRules.selectedSession {
                    if session.value(forKeyPath: "openDate") as? Date == openDate && session.value(forKeyPath: "closeDate") as? Date == closeDate {
                        cell.tintColor = Utilities.accentColor
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    }
                }
                
                Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
                
                return cell
        }
    }
    
    @IBAction func deleteAllSessions(_ sender: UIButton) {
        let deleteAllSessions: (() -> ()) = {
            guard let sessions = SessionDBRules.getAllSessions() else { return }
            sessions.forEach({ session in
                SessionDBRules.deleteSession(sessionToDelete: session)
            })
            
            self.sessionsTableView.reloadData()
            
            self.tableView.reloadData()
            self.updateSalesTable()
        }
        if SessionDBRules.getAllSessions()?.count ?? 0 > 0 {
            DeleteAlertView().showDeleteAlertView(parentView: self.parentView!, messageToShow: "Удалить все смены?", deleteHandler: deleteAllSessions)
        }
    }

}
