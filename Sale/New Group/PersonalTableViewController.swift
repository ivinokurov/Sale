//
//  PersonalTableViewController.swift
//  Sale
//


import UIKit

class PersonalTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var personView: UIView!
    @IBOutlet weak var fullPersonNameTextField: UITextField!
    @IBOutlet weak var itnPersonTextField: UITextField!
    @IBOutlet weak var loginPersonTextField: UITextField!
    @IBOutlet weak var pwdPersonTextField: UITextField!
    @IBOutlet weak var adminPersonButton: UIButton!
    @IBOutlet weak var merchPersonButton: UIButton!
    @IBOutlet weak var cashPersonButton: UIButton!
    @IBOutlet weak var addOrEditPersonButton: UIButton!
    @IBOutlet weak var cancelPersonButton: UIButton!    
    @IBOutlet weak var personViewTitleLabel: UILabel!
    
    var parentView: UIView? = nil
    var isPersonEditing: Bool = false
    var isPersonViewPresented: Bool = false
    var swipedRowIndex: Int? = nil
    var selectedPersonRole: Int = Utilities.personRole.admin.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parentView = Utilities.splitController!.parent!.view
        
        Utilities.makeButtonRounded(button: self.adminPersonButton)
        Utilities.makeButtonRounded(button: self.merchPersonButton)
        Utilities.makeButtonRounded(button: self.cashPersonButton)
        
        self.itnPersonTextField.delegate = self
        
        self.addNewPersonaBarItem()
    }
    
    func addNewPersonaBarItem() {
        let rightItemBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showPersonView))
        rightItemBarButton.tintColor = Utilities.barButtonItemColor
        self.navigationItem.rightBarButtonItem = rightItemBarButton
        
        Utilities.customizePopoverView(customizedView: self.personView)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.itnPersonTextField {
            let allowedCharacters = CharacterSet(charactersIn: Utilities.digitsOny)
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    @IBAction func setPersonRole(_ sender: UIButton) {
        self.adminPersonButton.setImage(nil, for: .normal)
        self.merchPersonButton.setImage(nil, for: .normal)
        self.cashPersonButton.setImage(nil, for: .normal)
        switch sender.tag {
        case Utilities.personRole.admin.rawValue:
            do {
                self.adminPersonButton.setImage(UIImage(named: "Check"), for: .normal)
                self.selectedPersonRole = Utilities.personRole.admin.rawValue
            }
        case Utilities.personRole.merchandiser.rawValue:
            do {
                self.merchPersonButton.setImage(UIImage(named: "Check"), for: .normal)
                self.selectedPersonRole = Utilities.personRole.merchandiser.rawValue
            }
        case Utilities.personRole.cashier.rawValue:
            do {
                self.cashPersonButton.setImage(UIImage(named: "Check"), for: .normal)
                self.selectedPersonRole = Utilities.personRole.cashier.rawValue
            }
        default: break
        }
    }
    
    @objc func showPersonView() {
        
        self.setPersonViewActionTitles()
        
        if !self.isPersonEditing {
            self.fullPersonNameTextField.text = ""
            self.itnPersonTextField.text = ""
            self.loginPersonTextField.text = ""
            self.pwdPersonTextField.text = ""
            self.setPersonRole(self.adminPersonButton)
        }
        
        self.personView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        self.setPersonViewFrame()
        self.personView.alpha = 0.0
        self.fullPersonNameTextField.becomeFirstResponder()
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.personView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
        
        self.setPersonaViewActionTitles()
        self.isPersonViewPresented = true
        self.personView.alpha = CGFloat(Utilities.alpha)
        
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.personView)
        
        Utilities.makeViewFlexibleAppearance(view: self.personView)
    }
    
    func setPersonaViewActionTitles() {
    }
    
    func setPersonViewFrame() {
        self.personView.center.x = (self.parentView?.center.x)!
        self.personView.frame.origin.y = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PersonalDBRules.getAllPersons()?.count ?? 0
    }
    
    func isLoginMuchTheSame(personLogin login: String, personNewLogin newLogin: String) -> Bool {
        if login == newLogin {
            return true
        }
        return false
    }
    
    @IBAction func addNewPerson(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        
        let person = PersonalDBRules.getAllPersons()![self.swipedRowIndex!]
        
        let newName = self.fullPersonNameTextField.text!
        let itn = self.itnPersonTextField.text!
        let newLogin = self.loginPersonTextField.text!
        let newPassword = self.pwdPersonTextField.text!
        let newRole = Int16(self.selectedPersonRole)
        
        if self.checkPersonInfo() {
            if !self.isPersonEditing {
                if !PersonalDBRules.isTheSamePersonPresents(personLogin: newLogin) {
                    PersonalDBRules.addNewPerson(personName: newName, personItn: itn, personLogin: newLogin, personPassword: newPassword, personRole: newRole)
                    
                    self.removePersonView()
                    self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                } else {
                    Utilities.showErrorAlertView(alertTitle: "ПЕРСОНАЛ", alertMessage: "Такой логин уже присутствует!")
                }
            } else {
                if !self.isLoginMuchTheSame(personLogin: person.value(forKeyPath: "login") as! String, personNewLogin: newLogin)
                {
                    if !PersonalDBRules.isTheSamePersonPresents(personLogin: newLogin) {
                        PersonalDBRules.changePerson(originItn: itn, personNewName: newName, personNewLogin: newLogin, personNewPassword: newPassword, personNewRole: newRole)
                        
                        self.removePersonView()
                        self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                    } else {
                        Utilities.showErrorAlertView(alertTitle: "ПЕРСОНАЛ", alertMessage: "Такой логин уже присутствует!")
                    }
                } else {
                    PersonalDBRules.changePerson(originItn: itn, personNewName: newName, personNewLogin: newLogin, personNewPassword: newPassword, personNewRole: newRole)
                    
                    self.removePersonView()
                    self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                }
            }
        }
    }
    
    func setPersonViewActionTitles() {
        if !self.isPersonEditing {
            self.personViewTitleLabel.text = "НОВЫЙ СОТРУДНИК"
            self.itnPersonTextField.isUserInteractionEnabled = true
            self.addOrEditPersonButton.setTitle("ДОБАВИТЬ", for: .normal)
        } else {
            self.personViewTitleLabel.text = "ИЗМЕНЕНИЕ СОТРУДНИКА"
            self.itnPersonTextField.isUserInteractionEnabled = false
            self.addOrEditPersonButton.setTitle("ИЗМЕНИТЬ", for: .normal)
        }
    }
    
    func removePersonView() {
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.personView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isPersonViewPresented = false
        })
    }
    
    @IBAction func cancelAddOrEditPerson(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.personView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isPersonViewPresented = false
            self.isPersonEditing = false
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size , with: coordinator)
        
        self.personView.removeFromSuperview()
        self.tableView.reloadData()
        
        coordinator.animate(alongsideTransition: { _ in
            if self.isPersonViewPresented {
                self.personView.alpha = CGFloat(Utilities.alpha)
                self.parentView?.addSubview(self.personView)
                self.setPersonViewFrame()
            }
        })
    }
    
    func checkPersonInfo() -> Bool {
        
        if self.fullPersonNameTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ПЕРСОНАЛ", alertMessage: "Отсутствует имя сотрудника!")
            return false
        }
        if self.itnPersonTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ПЕРСОНАЛ", alertMessage: "Отсутствует ИНН сотрудника!")
            return false
        }
        if self.loginPersonTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ПЕРСОНАЛ", alertMessage: "Отсутствует логин сотрудника!")
            return false
        }
        if self.pwdPersonTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ПЕРСОНАЛ", alertMessage: "Отсутствует пароль сотрудника!")
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCellId", for: indexPath)

        let person = PersonalDBRules.getAllPersons()![indexPath.row]
        
        cell.textLabel!.text = person.value(forKeyPath: "name") as? String
        cell.detailTextLabel?.text = self.getPersonRoleByCode(personRole: Int(person.value(forKeyPath: "role") as! Int16))
        if (Int)(person.value(forKeyPath: "role") as! Int16) == Utilities.personRole.admin.rawValue {
            cell.detailTextLabel?.textColor = Utilities.accentColor
        } else {
            cell.detailTextLabel?.textColor = UIColor.black
        }
        
        Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let person = PersonalDBRules.getAllPersons()?[indexPath.row]
        let name = person!.value(forKeyPath: "name") as? String
        let role = person!.value(forKeyPath: "role") as? Int16
        
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let deleteHandler: ((UIAlertAction) -> Void)? = { _ in
                PersonalDBRules.deletePerson(personName: name!, personRole: role!)
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                self.tableView.endUpdates()
            }
            
            Utilities.showTwoButtonsAlert(controllerInPresented: self, alertTitle: "УДАЛЕНИЕ СОТРУДНИКА", alertMessage: "Удалить этого сотрудника?", okButtonHandler: deleteHandler,  cancelButtonHandler: nil)
            
            success(true)
        })
        deleteAction.backgroundColor = Utilities.deleteActionBackgroundColor
        
        let editAction = UIContextualAction(style: .normal, title:  "Изменить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.isPersonEditing = true
            self.swipedRowIndex = indexPath.row
            self.showPersonView()
            
            self.fullPersonNameTextField.text = name
            self.itnPersonTextField.text = person!.value(forKeyPath: "itn") as? String
            self.loginPersonTextField.text = person!.value(forKeyPath: "login") as? String
            self.pwdPersonTextField.text = person!.value(forKeyPath: "password") as? String
            
            let pseudoButton = UIButton()
            pseudoButton.tag = Int(person?.value(forKey: "role") as! Int16)
            self.setPersonRole(pseudoButton)
            
            success(true)
        })
        editAction.backgroundColor = Utilities.editActionBackgroundColor
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
    func getPersonRoleByCode(personRole roleCode: Int) -> String {
        return Utilities.roleNames[roleCode]!
    }

}
