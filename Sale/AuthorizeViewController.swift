//
//  AuthorizeViewController.swift
//  Sale
//


import UIKit

class AuthorizeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var adminView: UIView!
    
    @IBOutlet weak var adminNameTextField: UITextField!
    @IBOutlet weak var adminNameUnderView: UIView!
    @IBOutlet weak var adminItnTextField: UITextField!
    @IBOutlet weak var adminItnUnderView: UIView!
    @IBOutlet weak var adminLoginTextField: UITextField!
    @IBOutlet weak var adminLoginUnderView: UIView!
    @IBOutlet weak var adminPwdTextField: UITextField!
    @IBOutlet weak var adminPwdUnderView: UIView!
    @IBOutlet weak var addAdminButton: UIButton!
    @IBOutlet weak var cancelAdminButton: UIButton!
    @IBOutlet weak var dismissAdminViewButton: UIButton!
    @IBOutlet weak var adminPwdVisibilityButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var authorizeView: UIView!
    @IBOutlet weak var loginTextField: UITextField!    
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var passwordVisibilityButton: UIButton!
    @IBOutlet weak var loginUnderView: UIView!    
    @IBOutlet weak var passwordUnderView: UIView!
    
    @IBOutlet var alertView: UIView!
    @IBOutlet weak var alertImageView: UIImageView!
    @IBOutlet weak var alertTextLabel: UILabel!
    @IBOutlet weak var dismissAlertButton: UIButton!
    
    var textUnderlineDecorationDic: Dictionary<UITextField, UIView>!
    var parentView: UIView? = nil
    var keyboardHeight: CGFloat = 0.0
    var isAdminViewPresented: Bool = false
    var isAlertViewPresented: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pwdTextField.isSecureTextEntry = true
        self.passwordVisibilityButton.setImage(Images.hidePwd, for: .normal)
        self.adminPwdVisibilityButton.setImage(Images.hidePwd, for: .normal)
        
        Utilities.customizePopoverView(customizedView: self.adminView)
        Utilities.createDismissButton(button: self.dismissAdminViewButton)
        
        Utilities.customizePopoverView(customizedView: self.alertView)
        
        Utilities.setAccentColorForSomeViews(viewsToSetAccentColor: [self.adminNameTextField, self.adminItnTextField, self.adminLoginTextField, self.adminPwdTextField, self.enterButton, self.addAdminButton, self.cancelAdminButton])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil
        )
        
        if SettingsDBRules.isColorIndexPresents() {
            if let colorIndex = SettingsDBRules.getAccentColorIndex() {
                Utilities.accentColor = Utilities.colors[Int(colorIndex)]!
            }
        } else {
            SettingsDBRules.addNewAccentColorIndex(colorIndex: 0)
            Utilities.accentColor = Utilities.colors[0]!
        }
        
        self.adminItnTextField.delegate = self
        
        if PersonalDBRules.getAllPersons()?.count == 0 {
            self.textUnderlineDecorationDic = [self.adminNameTextField : self.adminNameUnderView, self.adminItnTextField : self.adminItnUnderView, self.adminLoginTextField : self.adminLoginUnderView, self.adminPwdTextField : self.adminPwdUnderView]
            self.authorizeView.isHidden = true
            self.showAdminView()
        } else {
            self.textUnderlineDecorationDic = [self.loginTextField : self.loginUnderView, self.pwdTextField : self.passwordUnderView]
        }
    }
    
    func initAndShowAlertView(imageName: String, text: String) {
        self.alertImageView.image = UIImage(named: imageName)
        self.alertTextLabel.text = text

        self.showAlertView()
    }
    
    func showAlertView() {
        self.isAlertViewPresented = true
        
        Utilities.addOverlayViewToParent(parent: self.view)
            
        self.alertView.center = self.view.center
        self.view.addSubview(self.alertView)
        self.isAlertViewPresented = true
            
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.alertView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
            
        self.dismissAlertButton.tintColor = Utilities.accentColor
    }
    
    @IBAction func dismissAlertView(_ sender: Any) {
        Utilities.decorateButtonTap(buttonToDecorate: self.dismissAlertButton)
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.alertView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isAlertViewPresented = false
        })
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            self.setAuthorizeViewFrame()
            self.setAdminViewFrame()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = 0
            self.setAuthorizeViewFrame()
            self.setAdminViewFrame()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Utilities.customizePopoverView(customizedView: self.authorizeView)
        
        Utilities.setAccentColorForSomeViews(viewsToSetAccentColor: [self.loginTextField, self.loginUnderView, self.pwdTextField, self.passwordUnderView, self.enterButton, self.passwordVisibilityButton, self.adminPwdVisibilityButton])
        Utilities.setBkgColorForSomeViews(viewsToSetAccentColor: [self.loginUnderView, self.passwordUnderView, self.adminNameUnderView, self.adminItnUnderView, self.adminLoginUnderView, self.adminPwdUnderView])
        
        self.setAuthorizeViewFrame()
        
        self.showPersonView()
        Utilities.makeViewFlexibleAppearance(view: self.authorizeView)
    }
    
    @objc func showPersonView() {
        self.authorizeView.alpha = 0.0
    //    self.loginTextField.becomeFirstResponder()
        self.setAuthorizeViewFrame()
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.authorizeView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
    }
    
    func setAuthorizeViewFrame() {
        self.authorizeView.center.x = self.view.center.x
        self.authorizeView.frame.origin.y = (UIScreen.main.bounds.height -  self.keyboardHeight - self.authorizeView.frame.height) / 2
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size , with: coordinator)
        
        self.authorizeView.removeFromSuperview()
        self.adminView.removeFromSuperview()
        self.alertView.removeFromSuperview()

        coordinator.animate(alongsideTransition: { _ in
        //    self.loginTextField.becomeFirstResponder()
            self.setAuthorizeViewFrame()
            self.view.addSubview(self.authorizeView)
            
            if self.isAdminViewPresented {
                self.setAdminViewFrame()
                self.view.addSubview(self.adminView)
            }
            
            if self.isAlertViewPresented {
                self.alertView.center = self.view.center
                self.view.addSubview(self.alertView)
                self.isAlertViewPresented = true
            }
        })
    }
    
    @IBAction func showOrHidePassword(_ sender: UIButton) {
        if PersonalDBRules.currentLogin == nil || PersonalDBRules.currentPassword == nil {
            if self.adminPwdTextField.isSecureTextEntry {
                self.adminPwdTextField.isSecureTextEntry = false
                self.passwordVisibilityButton.setImage(Images.openPwd, for: .normal)
            } else {
                self.adminPwdTextField.isSecureTextEntry = true
                self.passwordVisibilityButton.setImage(Images.hidePwd, for: .normal)
            }
        } else {
            if self.pwdTextField.isSecureTextEntry {
                self.pwdTextField.isSecureTextEntry = false
                self.adminPwdVisibilityButton.setImage(Images.openPwd, for: .normal)
            } else {
                self.pwdTextField.isSecureTextEntry = true
                self.adminPwdVisibilityButton.setImage(Images.hidePwd, for: .normal)
            }
        }
    }
        
    @IBAction func enterAppForSomePerson(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        
        let login = self.loginTextField.text!
        let password = self.pwdTextField.text!
        
        if PersonalDBRules.getAllPersons()?.count == 0 {
            self.authorizeView.isHidden = true
            self.showAdminView()
            self.initAndShowAlertView(imageName: "Error", text: "Необходимо зарегистрировать как минимум одного сотруднка!")
        }
        
        if login == "" {
            self.initAndShowAlertView(imageName: "Error", text: "Отсутствует логин!")
        }
        if password == "" {
            self.initAndShowAlertView(imageName: "Error", text: "Отсутствует пароль!")
        }

        if PersonalDBRules.isPersonPresents(personLogin: login, personPassword: password) {
            PersonalDBRules.currentLogin = login
            PersonalDBRules.currentPassword = password
            Utilities.dismissView(viewToDismiss: self.authorizeView)
            self.performSegue(withIdentifier: "enterForSomePerson", sender: self)
        } else {
            self.loginTextField.text = ""
        //    self.loginTextField.becomeFirstResponder()
            self.pwdTextField.text = ""
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
    
    func checkAdminInfo() -> Bool {
        if self.adminNameTextField.text == "" {
            self.initAndShowAlertView(imageName: "Error", text: "Отсутствует имя администратора!")
            return false
        }
        if self.adminItnTextField.text == "" {
            self.initAndShowAlertView(imageName: "Error", text: "Отсутствует ИНН администратора!")
            return false
        }
        if self.adminLoginTextField.text == "" {
            self.initAndShowAlertView(imageName: "Error", text: "Отсутствует логин администратора!")
            return false
        }
        if self.adminPwdTextField.text == "" {
            self.initAndShowAlertView(imageName: "Error", text: "Отсутствует пароль администратора!")
            return false
        }
        
        return true
    }
    
    func setAdminViewFrame() {
        let y = (UIScreen.main.bounds.height - self.keyboardHeight - self.adminView.frame.height) / 2
        
        self.adminView.center.x = self.view.center.x
        self.adminView.frame.origin.y = y >  UIApplication.shared.statusBarFrame.size.height ? y : UIApplication.shared.statusBarFrame.size.height
    }
    
    @objc func showAdminView() {
        self.adminView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        self.setAdminViewFrame()
        self.adminView.alpha = 0.0
        // self.fullPersonNameTextField.becomeFirstResponder()
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.adminView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
        
        self.isAdminViewPresented = true
        self.adminView.alpha = CGFloat(Utilities.alpha)
        
    //    Utilities.addOverlayViewToParent(parent: self.view)
        self.view.addSubview(self.adminView)
        
        Utilities.makeViewFlexibleAppearance(view: self.adminView)
        self.dismissAdminViewButton.tintColor = Utilities.accentColor
        
        self.adminPwdTextField.isSecureTextEntry = true
        self.passwordVisibilityButton.setImage(Images.hidePwd, for: .normal)
    }
    
    @IBAction func cancelAdminView(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.adminView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isAdminViewPresented = false
            self.authorizeView.isHidden = false
        })
    }
    
    @IBAction func dismissAdminView(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissView(viewToDismiss: self.adminView)
        Utilities.dismissKeyboard(conroller: self)
        self.isAdminViewPresented = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.adminItnTextField {
            let allowedCharacters = CharacterSet(charactersIn: Utilities.digitsOny)
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    @IBAction func checkITNStringLength(_ sender: UITextField) {
        if (self.adminItnTextField.text!.count > 12) {
            self.adminItnTextField.deleteBackward()
        }
    }
    
    @IBAction func addNewAdmin(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        
        let adminName = self.adminNameTextField.text!
        let itn = self.adminItnTextField.text!
        let login = self.adminLoginTextField.text!
        let password = self.adminPwdTextField.text!
        let role = Int16(Utilities.personRole.admin.rawValue)
        
        if self.checkAdminInfo() {
            PersonalDBRules.currentLogin = login
            PersonalDBRules.currentPassword = password
            
            PersonalDBRules.addNewPerson(personName: adminName, personItn: itn, personLogin: login, personPassword: password, personRole: role)
            
            self.performSegue(withIdentifier: "enterForSomePerson", sender: self)
        }
    }
    
}
