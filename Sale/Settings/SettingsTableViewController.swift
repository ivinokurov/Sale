//
//  SettingsTableViewController.swift
//  Sale
//


import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var colorsView: UIView!
    @IBOutlet var accentColorButtons: [UIButton]!
    @IBOutlet weak var dismissColorsViewButton: UIButton!
    @IBOutlet weak var dismissOrgInfoButton: UIButton!
    @IBOutlet var orgInfoView: UIView!
    @IBOutlet weak var orgNameTextField: UITextField!
    @IBOutlet weak var orgNameUnderView: UIView!
    @IBOutlet weak var pointNameTextField: UITextField!
    @IBOutlet weak var pointNameUnderView: UIView!
    @IBOutlet weak var pointAddressTextField: UITextField!
    @IBOutlet weak var pointAddressUnderView: UIView!
    @IBOutlet weak var itnTextField: UITextField!
    @IBOutlet weak var itnUnderView: UIView!
    @IBOutlet weak var kppTextField: UITextField!
    @IBOutlet weak var kppUnderView: UIView!
    @IBOutlet var taxTypeButtons: [UIButton]!
    @IBOutlet weak var saveOrgInfoButton: UIButton!
    @IBOutlet weak var cancelOrgInfoButton: UIButton!
    
    var textUnderlineDecorationDic: Dictionary<UITextField, UIView>!
    
    var isColorsViewPresented: Bool = false
    var isOrgInfoViewPresented: Bool = false
    var parentView: UIView? = nil
    var keyboardHeight: CGFloat = 0.0
    var taxTypeIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parentView = Utilities.mainController!.view
        Utilities.customizePopoverView(customizedView: self.colorsView)
        Utilities.customizePopoverView(customizedView: self.orgInfoView)
        
        self.itnTextField.delegate = self
        self.kppTextField.delegate = self
        
        for button in self.accentColorButtons {
            Utilities.makeButtonRounded(button: button)
            button.backgroundColor = Utilities.colors[accentColorButtons.firstIndex(of: button)!]
            button.layer.borderColor = button.backgroundColor?.cgColor
            button.tintColor = .white
        }
        
        let colorIndex = SettingsDBRules.getAccentColorIndex()!
        self.accentColorButtons[Int(colorIndex)].setImage(UIImage(named: "Check"), for: .normal)
        
        Utilities.createDismissButton(button: self.dismissColorsViewButton)
        self.dismissColorsViewButton.tintColor = Utilities.accentColor
        Utilities.createDismissButton(button: self.dismissOrgInfoButton)
        self.dismissOrgInfoButton.tintColor = Utilities.accentColor
        
        self.textUnderlineDecorationDic = [self.orgNameTextField : self.orgNameUnderView, self.pointNameTextField : self.pointNameUnderView, self.pointAddressTextField : self.pointAddressUnderView, self.itnTextField : self.itnUnderView, self.kppTextField : self.kppUnderView]
    }
    
    @IBAction func checkITNStringLength(_ sender: UITextField) {
        if (self.itnTextField.text!.count > 12) {
            self.itnTextField.deleteBackward()
        }
    }
    
    @IBAction func checkKPPStringLength(_ sender: UITextField) {
        if (self.kppTextField.text!.count > 9) {
            self.kppTextField.deleteBackward()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.itnTextField || textField == self.kppTextField {
            let allowedCharacters = CharacterSet(charactersIn: Utilities.digitsOny)
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .left
    }
    
    func changeAccentColorForOrgInfoView() {
        Utilities.setAccentColorForSomeViews(viewsToSetAccentColor: [self.orgNameTextField, self.pointNameTextField, self.pointAddressTextField, self.itnTextField, self.kppTextField, self.saveOrgInfoButton, self.cancelOrgInfoButton])
        Utilities.setBkgColorForSomeViews(viewsToSetAccentColor: [self.orgNameUnderView, self.pointNameUnderView, self.pointAddressUnderView, self.itnUnderView, self.kppUnderView])
        
        for taxTypeButton in self.taxTypeButtons {
            Utilities.makeButtonRounded(button: taxTypeButton)
        }
    }
    
    @IBAction func setTaxType(_ sender: UIButton) {
        for taxTypeButton in self.taxTypeButtons {
            taxTypeButton.setImage(nil, for: .normal)
        }
        
        sender.setImage(UIImage(named: "Check"), for: .normal)
        self.taxTypeIndex = sender.tag
    }
    
    @IBAction func saveOrgInfo(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        
        if self.checkOrgInfo() {
            let orgName = self.orgNameTextField.text!
            let pntName = self.pointNameTextField.text!
            let pntAddress = self.pointAddressTextField.text!
            let orgItn = self.itnTextField.text!
            let orgKpp = self.kppTextField.text
            
            if OrgInfoDBRules.getOrgInfo() != nil {
                OrgInfoDBRules.changeOrgInfo(organizationName: orgName, pointName: pntName, pointAddress: pntAddress, organizationItn: orgItn, organizationKpp: orgKpp ?? "", organizationTaxType: Int16(self.taxTypeIndex))
            } else {
                OrgInfoDBRules.addNewOrgInfo(organizationName: orgName, pointName: pntName, pointAddress: pntAddress, organizationItn: orgItn, organizationKpp: orgKpp ?? "", organizationTaxType: Int16(self.taxTypeIndex))
            }
        }
        self.removeOrgInfoView()
    }
    
    func removeOrgInfoView() {
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.orgInfoView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isOrgInfoViewPresented = false
        })
    }
    
    func getOrgInfo() {
        if let orgInfo = OrgInfoDBRules.getOrgInfo() {
            self.orgNameTextField.text = orgInfo.value(forKey: "orgName") as? String
            self.pointNameTextField.text = orgInfo.value(forKey: "pointName") as? String
            self.pointAddressTextField.text = orgInfo.value(forKey: "pointAddress") as? String
            self.itnTextField.text = orgInfo.value(forKey: "itn") as? String
            self.kppTextField.text = orgInfo.value(forKey: "kpp") as? String
            
            let taxTypeIndex = Int(orgInfo.value(forKey: "taxType") as! Int16)
            if let button = self.taxTypeButtons.first(where: { $0.tag == taxTypeIndex })  {
                self.setTaxType(button)
            }
        }
    }
        
    @IBAction func cancelSaveOrgInfo(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.orgInfoView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isOrgInfoViewPresented = false
        })
    }
        
    @IBAction func dismissOrgInfoView(_ sender: UIButton) {
        Utilities.dismissView(viewToDismiss: self.orgInfoView)
        self.isOrgInfoViewPresented = false
    }
    
    @IBAction func dismissColorsView(_ sender: UIButton) {
        Utilities.dismissView(viewToDismiss: self.colorsView)
        self.isColorsViewPresented = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) != nil {
            
            if indexPath.row == 0 && indexPath.section == 0 {
                self.showOrgInfoView()
                tableView.reloadData()
                return
            }
            
            if indexPath.row == 0 && indexPath.section == 1 {
                self.showAccentColorsView()
                tableView.reloadData()
                return
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            self.setOrgInfoViewFrame()
        }
    }
    
    func setOrgInfoViewFrame() {
        self.orgInfoView.center.x = (self.parentView?.center.x)!
        self.orgInfoView.frame.origin.y = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    func getColorsViewCenterPoint() -> CGPoint {
        
        let centerX = (self.parentView?.center.x)!
        let centerY = (self.parentView?.center.y)!
        
        return CGPoint(x: centerX, y: centerY)
    }
    
    func showAccentColorsView() {
        self.colorsView.center = self.getColorsViewCenterPoint()
        self.colorsView.alpha = 0.0
        self.colorsView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.colorsView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
        
        self.isColorsViewPresented = true
        self.colorsView.alpha = 0.94
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.colorsView)
        
        Utilities.makeViewFlexibleAppearance(view: self.colorsView)
    }
    
    func showOrgInfoView() {
        self.orgInfoView.alpha = 0.0
        self.orgInfoView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.orgInfoView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
        
        self.changeAccentColorForOrgInfoView()
        
        self.isOrgInfoViewPresented = true
        self.orgInfoView.alpha = 0.94
    //    self.orgNameTextField.becomeFirstResponder()
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.orgInfoView)
        self.setOrgInfoViewFrame()
        self.getOrgInfo()
        
        Utilities.makeViewFlexibleAppearance(view: self.orgInfoView)
    }
    
    func checkOrgInfo() -> Bool {
        if self.orgNameTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ОРГАНИЗАЦИЯ", alertMessage: "Отсутствует название организации!")
            return false
        }
        if self.pointNameTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ОРГАНИЗАЦИЯ", alertMessage: "Отсутствует наименование торгового объекта!")
            return false
        }
        if self.pointAddressTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ОРГАНИЗАЦИЯ", alertMessage: "Отсутствует адрес торгового объекта!")
            return false
        }
        if self.itnTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ОРГАНИЗАЦИЯ", alertMessage: "Отсутствует ИНН организации!")
            return false
        }
        
        return true
    }
    
    @IBAction func setAccentColor(_ sender: UIButton) {
        for button in self.accentColorButtons {
            button.setImage(nil, for: .normal)
        }
        
        sender.setImage(UIImage(named: "Check"), for: .normal)
        
        let colorIndex = Int16(self.accentColorButtons.firstIndex(of: sender)!)
        
        SettingsDBRules.changeAccentColorIndex(colorIndex: colorIndex)
        Utilities.accentColor = Utilities.colors[Int(colorIndex)]!
        
        self.dismissColorsViewButton.tintColor = Utilities.accentColor
        self.tableView.reloadData()
        Utilities.mainController!.tabBar.tintColor = Utilities.accentColor
        self.dismissColorsView(sender)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size , with: coordinator)
        
        self.colorsView.removeFromSuperview()
        self.orgInfoView.removeFromSuperview()
        
        coordinator.animate(alongsideTransition: { _ in
            if self.isColorsViewPresented {
                self.parentView?.addSubview(self.colorsView)
                self.colorsView.center = self.getColorsViewCenterPoint()
            }
            if self.isOrgInfoViewPresented {
                self.parentView?.addSubview(self.orgInfoView)
                self.setOrgInfoViewFrame()
                
                if (Utilities.splitController?.isAlertViewPresented)! {
                    _ = self.checkOrgInfo()
                }
            }
        })
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

}
