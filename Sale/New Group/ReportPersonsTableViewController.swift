//
//  ReportPersonsTableViewController.swift
//  Sale
//


import UIKit

class ReportPersonsTableViewController: UITableViewController {
    
    var currentPersonItn: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentPersonItn = PersonalDBRules.getPersonItnByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PersonalDBRules.getAllPersons()?.count ?? 0
    }
    
    func updateSalesTable() {
        let navController = Utilities.reportsSplitController!.viewControllers[1] as! UINavigationController
        let salesController = navController.topViewController as! ReportSalesViewController
        if salesController.personSalesTableView != nil {
            salesController.personSalesTableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = PersonalDBRules.getAllPersons()![indexPath.row]
        self.currentPersonItn = person.value(forKeyPath: "itn") as? String

        Utilities.reportsSplitController!.selectedReportPersonName = person.value(forKeyPath: "name") as? String
        Utilities.reportsSplitController!.selectedReportPersonRole = person.value(forKeyPath: "role") as? Int16
        
        self.updateSalesTable()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportsRersonsCellId", for: indexPath)
        
        let person = PersonalDBRules.getAllPersons()![indexPath.row]
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
        
        Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
        
        if self.currentPersonItn != nil && self.currentPersonItn == itn {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
            Utilities.reportsSplitController!.selectedReportPersonName = name
            Utilities.reportsSplitController!.selectedReportPersonRole = role            
            self.updateSalesTable()
        }

        return cell
    }

}
