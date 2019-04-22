//
//  ReportPersonsTableViewController.swift
//  Sale
//


import UIKit
import CoreData

class ReportPersonsTableViewController: UITableViewController {
    
    @IBOutlet var sessionsView: UIView!
    @IBOutlet weak var dismissSessionsButton: UIButton!
    @IBOutlet weak var sessionsTableView: UITableView!
        
    var parentView: UIView? = nil
    var currentPersonItn: String? = nil
    var isSessionsViewPresented: Bool = false

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
        
        self.navigationItem.rightBarButtonItem?.tintColor = Utilities.accentColor
        self.tableView.reloadData()
    }
    
    func showSessionsView() {
        self.sessionsView.center = Utilities.getParentViewCenterPoint(parentView: self.parentView)
        self.sessionsView.alpha = 0.0
        self.sessionsView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.sessionsView.alpha = CGFloat(Utilities.alpha)
        }), completion: { (completed: Bool) in
        })
        
        self.isSessionsViewPresented = true
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
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissView(viewToDismiss: self.sessionsView)
        self.isSessionsViewPresented = false
    //    self.tableView.reloadData()
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
        if salesController.personSalesTableView != nil {
            salesController.personSalesTableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView != self.sessionsTableView {
            let person = SessionDBRules.selectedSession?.mutableSetValue(forKey: "persons").allObjects.sorted(by: {person1, person2 in
                    let person1Name = (person1 as! NSManagedObject).value(forKeyPath: "name") as? String
                    if person1Name == nil { return false }
                
                    let person2Name = (person2 as! NSManagedObject).value(forKeyPath: "name") as? String
                    if person2Name == nil { return false }
                
                    if person1Name! < person2Name! {
                        return true
                    } else {
                        return false
                    }
                })[indexPath.row] as! NSManagedObject
            
            Utilities.reportsSplitController!.selectedReportPersonName = person.value(forKeyPath: "name") as? String
            Utilities.reportsSplitController!.selectedReportPersonRole = person.value(forKeyPath: "role") as? Int16
            
            self.updateSalesTable()
        } else {
            SessionDBRules.selectedSession = SessionDBRules.getAllSessions()![indexPath.row]
            
            let cell = self.sessionsTableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            cell?.tintColor = Utilities.accentColor
            
            self.tableView.reloadData()
            
            self.dismissSessionsView(UIButton())
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView == self.sessionsTableView {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView == self.sessionsTableView ? true : false
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == self.sessionsTableView /*&& indexPath == tableView.indexPathForSelectedRow*/ {
                let deleteAction = UIContextualAction(style: .normal, title:  "Удалить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
                    
                    let deleteHandler: ((UIAlertAction) -> Void)? = { _ in
                        
                        let session = SessionDBRules.getAllSessions()?[indexPath.row]
                        SessionDBRules.deleteSession(sessionToDelete: session!)
                        
                        self.sessionsTableView.beginUpdates()
                        self.sessionsTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                        self.sessionsTableView.endUpdates()
                        
                        if SessionDBRules.getAllSessions()?.count == 0 || indexPath == tableView.indexPathForSelectedRow {
                            SessionDBRules.selectedSession = session
                            self.tableView.reloadData()
                            self.updateSalesTable()
                        }
                    }
                    
                    Utilities.showTwoButtonsAlert(controllerInPresented: self, alertTitle: "УДАЛЕНИЕ СМЕНЫ", alertMessage: "Удалить эту смену?", okButtonHandler: deleteHandler,  cancelButtonHandler: nil)
                    
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
                
            let person = SessionDBRules.selectedSession?.mutableSetValue(forKey: "persons").allObjects.sorted(by: { (($0 as! NSManagedObject).value(forKeyPath: "name") as! String) < (($1 as! NSManagedObject).value(forKeyPath: "name") as! String)})[indexPath.row] as! NSManagedObject
            
            let name = person.value(forKeyPath: "name") as? String
            let role = person.value(forKeyPath: "role") as! Int16
            let itn = person.value(forKeyPath: "itn") as? String
            
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = Utilities.roleNames[Int(role)]!
            if Int(role) == Utilities.personRole.admin.rawValue {
                cell.detailTextLabel?.textColor = Utilities.accentColor
            } else {
                cell.detailTextLabel?.textColor = UIColor.black
            }
            cell.accessoryView?.addSubview(UILabel())
            
            Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
            
            if self.currentPersonItn != nil && self.currentPersonItn == itn {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                
                Utilities.reportsSplitController!.selectedReportPersonName = name
                Utilities.reportsSplitController!.selectedReportPersonRole = role
                
                self.updateSalesTable()
            }

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
                        cell.accessoryType = .checkmark
                        cell.tintColor = Utilities.accentColor
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    } else {
                        cell.accessoryType = .none
                    }
                } else {
                    cell.accessoryType = .none
                }
                
                Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
                
                return cell
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size , with: coordinator)
        
        if self.isSessionsViewPresented {
            self.sessionsView.removeFromSuperview()
        
            coordinator.animate(alongsideTransition: { _ in
                self.parentView?.addSubview(self.sessionsView)
                self.sessionsView.center = Utilities.getParentViewCenterPoint(parentView: self.parentView)
            })
        }
    }

}
