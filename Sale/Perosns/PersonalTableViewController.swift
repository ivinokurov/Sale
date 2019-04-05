//
//  PersonalTableViewController.swift
//  Sale
//


import UIKit
import CoreData

class PersonalTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var personView: UIView!
    @IBOutlet weak var fullPersonNameTextField: UITextField!
    @IBOutlet weak var personItnTextField: UITextField!
    @IBOutlet weak var personLoginTextField: UITextField!
    @IBOutlet weak var personPasswordTextField: UITextField!
    @IBOutlet weak var adminPersonButton: UIButton!
    @IBOutlet weak var merchPersonButton: UIButton!
    @IBOutlet weak var cashPersonButton: UIButton!
    @IBOutlet weak var addOrEditPersonButton: UIButton!
    @IBOutlet weak var cancelPersonButton: UIButton!    
    @IBOutlet weak var personViewTitleLabel: UILabel!
    @IBOutlet weak var passwordVisibilityButton: UIButton!
    @IBOutlet weak var personNameUnderView: UIView!
    @IBOutlet weak var personItnUnderView: UIView!
    @IBOutlet weak var personLoginUnderView: UIView!
    @IBOutlet weak var personPwdUnderView: UIView!
    @IBOutlet weak var dismissPersonButton: UIButton!
    
    var textUnderlineDecorationDic: Dictionary<UITextField, UIView>!
    
    var parentView: UIView? = nil
    var isPersonEditing: Bool = false
    var isPersonViewPresented: Bool = false
    var swipedRowIndex: Int? = nil
    var selectedPersonRole: Int = Utilities.personRole.admin.rawValue
    var currentPersonItn: String? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parentView = Utilities.mainController!.view
        
        self.personItnTextField.delegate = self
        
        let personRole = PersonalDBRules.getPersonRoleByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)!
        
        if personRole == Utilities.personRole.admin.rawValue {
            self.addNewPersonaBarItem()
        }
        
        self.currentPersonItn = PersonalDBRules.getPersonItnByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)
        
        Utilities.createDismissButton(button: self.dismissPersonButton)
        self.dismissPersonButton.tintColor = Utilities.accentColor
        
        self.textUnderlineDecorationDic = [self.fullPersonNameTextField : self.personNameUnderView, self.personItnTextField : self.personItnUnderView, self.personLoginTextField : self.personLoginUnderView, self.personPasswordTextField : self.personPwdUnderView]
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Utilities.setAccentColorForSomeViews(viewsToSetAccentColor: [self.fullPersonNameTextField, self.personItnTextField, self.personLoginTextField, self.personPasswordTextField, self.addOrEditPersonButton, self.cancelPersonButton, self.passwordVisibilityButton])
        Utilities.setBkgColorForSomeViews(viewsToSetAccentColor: [self.personNameUnderView, self.personItnUnderView, self.personLoginUnderView, self.personPwdUnderView])
        
        Utilities.makeButtonRounded(button: self.adminPersonButton)
        self.adminPersonButton.layer.borderColor = UIColor.red.cgColor
        self.adminPersonButton.tintColor = UIColor.red
        Utilities.makeButtonRounded(button: self.merchPersonButton)
        Utilities.makeButtonRounded(button: self.cashPersonButton)
        
        self.navigationItem.rightBarButtonItem?.tintColor = Utilities.accentColor
        
        self.tableView.reloadData()
    }
    
    func addNewPersonaBarItem() {
        let rightItemBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showPersonView))
        rightItemBarButton.tintColor = Utilities.barButtonItemColor
        self.navigationItem.rightBarButtonItem = rightItemBarButton
        
        Utilities.customizePopoverView(customizedView: self.personView)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.personItnTextField {
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
            self.personItnTextField.text = ""
            self.personLoginTextField.text = ""
            self.personPasswordTextField.text = ""
            self.setPersonRole(self.adminPersonButton)
        }
        
        self.personView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        self.setPersonViewFrame()
        self.personView.alpha = 0.0
        // self.fullPersonNameTextField.becomeFirstResponder()
        
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
        
        self.personPasswordTextField.isSecureTextEntry = true
        self.passwordVisibilityButton.setImage(UIImage(named: "HidePwd"), for: .normal)
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
        
        if let personIndex = self.swipedRowIndex {
            PersonalDBRules.selectedPerson = PersonalDBRules.getAllPersons()?[personIndex]
        } else {
            PersonalDBRules.selectedPerson = nil
        }

        let newName = self.fullPersonNameTextField.text!
        let itn = self.personItnTextField.text!
        let newLogin = self.personLoginTextField.text!
        let newPassword = self.personPasswordTextField.text!
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
                if !self.isLoginMuchTheSame(personLogin: PersonalDBRules.selectedPerson!.value(forKeyPath: "login") as? String ?? "", personNewLogin: newLogin)
                {
                    if !PersonalDBRules.isTheSamePersonPresents(personLogin: newLogin) {
                        PersonalDBRules.changePerson(originItn: itn, personNewName: newName, personNewLogin: newLogin, personNewPassword: newPassword, personNewRole: newRole)
                        
                        self.removePersonView()
                        
                        self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                        self.self.swipedRowIndex = nil
                    } else {
                        Utilities.showErrorAlertView(alertTitle: "ПЕРСОНАЛ", alertMessage: "Такой логин уже присутствует!")
                    }
                } else {
                    PersonalDBRules.changePerson(originItn: itn, personNewName: newName, personNewLogin: newLogin, personNewPassword: newPassword, personNewRole: newRole)
                    
                    self.removePersonView()
                    
                    self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                }
                self.isPersonEditing = false
            }
        }
    }
    
    func setPersonViewActionTitles() {
        if !self.isPersonEditing {
            self.personViewTitleLabel.text = "НОВЫЙ СОТРУДНИК"
            self.personItnTextField.isUserInteractionEnabled = true
            self.addOrEditPersonButton.setTitle("ДОБАВИТЬ", for: .normal)
        } else {
            self.personViewTitleLabel.text = "ИЗМЕНЕНИЕ СОТРУДНИКА"
            self.personItnTextField.isUserInteractionEnabled = false
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
        
        coordinator.animate(alongsideTransition: { _ in
            if self.isPersonViewPresented {
                self.personView.alpha = CGFloat(Utilities.alpha)
                self.parentView?.addSubview(self.personView)
                self.setPersonViewFrame()
                
                if (Utilities.splitController?.isAlertViewPresented)! {
                    _ = self.checkPersonInfo()
                }
            }
        })
    }
    
    func checkPersonInfo() -> Bool {        
        if self.fullPersonNameTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ПЕРСОНАЛ", alertMessage: "Отсутствует имя сотрудника!")
            return false
        }
        if self.personItnTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ПЕРСОНАЛ", alertMessage: "Отсутствует ИНН сотрудника!")
            return false
        }
        if self.personLoginTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ПЕРСОНАЛ", alertMessage: "Отсутствует логин сотрудника!")
            return false
        }
        if self.personPasswordTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ПЕРСОНАЛ", alertMessage: "Отсутствует пароль сотрудника!")
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //    self.currentPersonItn = PersonalDBRules.getAllPersons()![indexPath.row].value(forKeyPath: "itn") as? String
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCellId", for: indexPath)
        
        let person = PersonalDBRules.getAllPersons()![indexPath.row]

        let login = person.value(forKeyPath: "login") as! String
        let password = person.value(forKeyPath: "password") as! String
        let name = person.value(forKeyPath: "name") as! String
        let role = person.value(forKeyPath: "role") as! Int16
        
        cell.textLabel!.text = name
        cell.detailTextLabel?.text = self.getPersonRoleByCode(personRole: Int(person.value(forKeyPath: "role") as! Int16))
        if Int(role) == Utilities.personRole.admin.rawValue {
            cell.detailTextLabel?.textColor = Utilities.accentColor
        } else {
            cell.detailTextLabel?.textColor = UIColor.black
        }
        
        if PersonalDBRules.getPersonItnByLoginAndPassword(personLogin: login, personPassword: password) == self.currentPersonItn {
            
            cell.accessoryView = self.createLougoutButton()
            tableView.cellForRow(at: indexPath)
            cell.selectionStyle = .default
        } else {
            cell.accessoryView = nil
        //    cell.selectionStyle = .none
        }
        
        Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if Int(PersonalDBRules.getPersonRoleByInt(personItn: self.currentPersonItn!)!) == Utilities.personRole.admin.rawValue {
            return true
        } else {
            let person = PersonalDBRules.getAllPersons()![indexPath.row]
            
            let login = person.value(forKeyPath: "login") as! String
            let password = person.value(forKeyPath: "password") as! String
            
            if PersonalDBRules.getPersonItnByLoginAndPassword(personLogin: login, personPassword: password) == self.currentPersonItn {
                return true
            } else {
                return false
            }
        }
    }
    
    func createLougoutButton() -> UIButton {
        let accessoryButton = LogoutButton(type: .custom)
        accessoryButton.setImage(UIImage(named: "Logout"), for: .normal)
        accessoryButton.tintColor = Utilities.accentColor
        accessoryButton.addTarget(self, action: #selector(logoutPerson(sender:)), for: .touchUpInside)
        accessoryButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        accessoryButton.contentMode = .scaleAspectFit
        return accessoryButton
    }
    
    @objc func logoutPerson(sender: AnyObject) {
        let logoutHandler: ((UIAlertAction) -> Void)? = { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let initialController = storyboard.instantiateViewController(withIdentifier: "authorizeControllerId")
            self.present(initialController, animated: true, completion: nil)
            Utilities.isPersonLogout = true
        }
        
        Utilities.showTwoButtonsAlert(controllerInPresented: self, alertTitle: "ВЫХОД", alertMessage: "Выйти из приложения?", okButtonHandler: logoutHandler,  cancelButtonHandler: nil)
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
            self.personItnTextField.text = person!.value(forKeyPath: "itn") as? String
            self.personLoginTextField.text = person!.value(forKeyPath: "login") as? String
            self.personPasswordTextField.text = person!.value(forKeyPath: "password") as? String
            
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
    
    @IBAction func checkITNStringLength(_ sender: UITextField) {
        if (self.personItnTextField.text!.count > 12) {
            self.personItnTextField.deleteBackward()
        }
    }
    
    @IBAction func showOrHidePassword(_ sender: UIButton) {
        if self.personPasswordTextField.isSecureTextEntry {
            self.personPasswordTextField.isSecureTextEntry = false
            self.passwordVisibilityButton.setImage(UIImage(named: "OpenPwd"), for: .normal)
        } else {
            self.personPasswordTextField.isSecureTextEntry = true
            self.passwordVisibilityButton.setImage(UIImage(named: "HidePwd"), for: .normal)
        }
    }
    
    @IBAction func addUnderView(_ sender: UITextField) {
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.textUnderlineDecorationDic.first(where: { $0.key == sender })?.value.backgroundColor = Utilities.accentColor
        }), completion: { (completed: Bool) in
        })
    }
    
    @IBAction func removeUnderView(_ sender: UITextField) {
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.textUnderlineDecorationDic.first(where: { $0.key == sender })?.value.backgroundColor = Utilities.inactiveColor
        }), completion: { (completed: Bool) in
        })
    }
    
    @IBAction func dismissPersonView(_ sender: UIButton) {
        Utilities.dismissView(viewToDismiss: self.personView)
        self.isPersonViewPresented = false
    }
    
}
