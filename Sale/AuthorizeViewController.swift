//
//  AuthorizeViewController.swift
//  Sale
//


import UIKit

class AuthorizeViewController: UIViewController {
    
    @IBOutlet weak var authorizeView: UIView!
    @IBOutlet weak var loginTextField: UITextField!    
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var passwordVisibilityButton: UIButton!
    
    var keyboardHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Utilities.customizePopoverView(customizedView: self.authorizeView)
        
        self.pwdTextField.isSecureTextEntry = true
        self.passwordVisibilityButton.setImage(UIImage(named: "HidePwd"), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil
        )
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            self.setAuthorizeViewFrame()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setAuthorizeViewFrame()
        self.showPersonView()
        Utilities.makeViewFlexibleAppearance(view: self.authorizeView)
    }
    
    @objc func showPersonView() {

        self.authorizeView.alpha = 0.0
        self.loginTextField.becomeFirstResponder()
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

        coordinator.animate(alongsideTransition: { _ in
            self.loginTextField.becomeFirstResponder()
            self.setAuthorizeViewFrame()
            self.view.addSubview(self.authorizeView)
        })
    }
    
    @IBAction func showOrHidePassword(_ sender: UIButton) {
        if self.pwdTextField.isSecureTextEntry {
            self.pwdTextField.isSecureTextEntry = false
            self.passwordVisibilityButton.setImage(UIImage(named: "OpenPwd"), for: .normal)
        } else {
            self.pwdTextField.isSecureTextEntry = true
            self.passwordVisibilityButton.setImage(UIImage(named: "HidePwd"), for: .normal)
        }
    }
        
    @IBAction func enterAppForSomePerson(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        let login = self.loginTextField.text!
        let password = self.pwdTextField.text!

        if PersonalDBRules.isPersonPresents(personLogin: login, personPassword: password) {
            
            PersonalDBRules.currentLogin = login
            PersonalDBRules.currentPassword = password
            
            self.performSegue(withIdentifier: "enterForSomePerson", sender: self)
        } else {            
            if PersonalDBRules.getAllPersons()?.count == 0 {
                PersonalDBRules.addNewPerson(personName: "Администратор", personItn: "111111111111", personLogin: login, personPassword: password, personRole: Int16(Utilities.personRole.admin.rawValue))
                
                PersonalDBRules.currentLogin = login
                PersonalDBRules.currentPassword = password
                
                self.performSegue(withIdentifier: "enterForSomePerson", sender: self)
            }
            
            self.loginTextField.text = ""
            self.loginTextField.becomeFirstResponder()
            self.pwdTextField.text = ""
        }
    }
    
}
