//
//  SettingsTableViewController.swift
//  Sale
//

class BtDevicesDataSource: UITableView, UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate  {
    var centralManager: CBCentralManager?
    var peripherals: [CBPeripheral] = []
    var selectedPeripheral: CBPeripheral? = nil
    var parent: SettingsTableViewController? = nil
    
    var dismissView: ((UIButton)->())? = nil
    
    func initBtDevicesDataSource(parentController controller: SettingsTableViewController) {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.parent = controller
        
        self.parent?.btDevicesTableView!.dataSource = self
        self.parent?.btDevicesTableView!.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn) {
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name != nil {
            if !(self.peripherals.map({item in
                item.name}).contains(peripheral.name)) {
                self.peripherals.append(peripheral)
                self.parent?.btDevicesTableView!.reloadData()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "btDeviceCellId")! as UITableViewCell
        
        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        cell.detailTextLabel?.text = peripheral.identifier.description
        cell.tintColor = Utilities.accentColor
        Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
        
        if let peripheral = self.selectedPeripheral {
            if cell.textLabel?.text == peripheral.name {
                cell.accessoryType = .checkmark
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        cell?.tintColor = Utilities.accentColor
        
        self.selectedPeripheral = self.peripherals[indexPath.row]
        self.parent?.tableView?.cellForRow(at: IndexPath(row: 0, section: 2))?.textLabel!.text = "Выбрать устройство из списка [" + (self.selectedPeripheral?.name)! + "]"
        
        self.parent?.tableView.reloadData()
        Utilities.dismissView(viewToDismiss: (self.parent?.btDevicesView)!)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
}


import UIKit
import CoreBluetooth

class SettingsTableViewController: UITableViewController, UITextFieldDelegate, StreamDelegate {
    
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
    
    @IBOutlet var btDevicesView: UIView!
    @IBOutlet weak var btDevicesTableView: UITableView!
    @IBOutlet weak var dismissBtDevicesButton: UIButton!
        
    @IBOutlet var hostNameView: UIView!
    @IBOutlet weak var dismissHostNameButton: UIButton!
    @IBOutlet weak var hostNameTextEdit: UITextField!
    @IBOutlet weak var hostNameUnderView: UIView!
    @IBOutlet weak var hostNameOKButton: UIButton!
    
    var textUnderlineDecorationDic: Dictionary<UITextField, UIView>!
    
    var btDevices: BtDevicesDataSource?
    var parentView: UIView? = nil
    var keyboardHeight: CGFloat = 0.0
    var taxTypeIndex: Int = 0
    
    var hostName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parentView = Utilities.mainController!.view
        Utilities.customizePopoverView(customizedView: self.colorsView)
        Utilities.customizePopoverView(customizedView: self.orgInfoView)
        Utilities.customizePopoverView(customizedView: self.btDevicesView)
        Utilities.customizePopoverView(customizedView: self.hostNameView)
        
        self.itnTextField.delegate = self
        self.kppTextField.delegate = self
        
        for button in self.accentColorButtons {
            Utilities.makeButtonRounded(button: button)
            button.backgroundColor = Utilities.colors[accentColorButtons.firstIndex(of: button)!]
            button.layer.borderColor = button.backgroundColor?.cgColor
            button.tintColor = .white
        }
        
        let colorIndex = SettingsDBRules.getAccentColorIndex()!
        self.accentColorButtons[Int(colorIndex)].setImage(Images.check, for: .normal)
        
        Utilities.createDismissButton(button: self.dismissColorsViewButton)
        Utilities.createDismissButton(button: self.dismissOrgInfoButton)
        Utilities.createDismissButton(button: self.dismissBtDevicesButton)
        Utilities.createDismissButton(button: self.dismissHostNameButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil
        )
        
        self.textUnderlineDecorationDic = [self.orgNameTextField : self.orgNameUnderView, self.pointNameTextField : self.pointNameUnderView, self.pointAddressTextField : self.pointAddressUnderView, self.itnTextField : self.itnUnderView, self.kppTextField : self.kppUnderView, self.hostNameTextEdit : self.hostNameUnderView]
        
        self.btDevices = BtDevicesDataSource()
        self.btDevices?.initBtDevicesDataSource(parentController: self)
        
        self.btDevicesTableView.tableFooterView = UIView()
        
        self.hostName = SettingsDBRules.getTCPDeviceName()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.hostName != nil && !(self.hostName?.isEmpty)! {
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 3))?.textLabel!.text = "Ввести сетевое имя или IP-адрес устройства [" + self.hostName! + "]"
        }
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
        
        Utilities.setAccentColorForSomeViews(viewsToSetAccentColor: [self.orgNameTextField, self.pointNameTextField, self.pointAddressTextField, self.itnTextField, self.kppTextField, self.saveOrgInfoButton, self.cancelOrgInfoButton, self.hostNameTextEdit, self.hostNameOKButton])
        Utilities.setBkgColorForSomeViews(viewsToSetAccentColor: [self.orgNameUnderView, self.pointNameUnderView, self.pointAddressUnderView, self.itnUnderView, self.kppUnderView, self.hostNameUnderView])
        
        self.showSelectedAccentColor()
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
    
    func changeAccentColorForHostNameView() {
        Utilities.setAccentColorForSomeViews(viewsToSetAccentColor: [self.hostNameTextEdit, self.hostNameOKButton])
        Utilities.setBkgColorForSomeViews(viewsToSetAccentColor: [self.hostNameUnderView])
    }
    
    @IBAction func setTaxType(_ sender: UIButton) {
        for taxTypeButton in self.taxTypeButtons {
            taxTypeButton.setImage(nil, for: .normal)
        }
        
        sender.setImage(Images.check, for: .normal)
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
            self.removeOrgInfoView()
        }
    }
    
    func removeOrgInfoView() {
        Utilities.removeOverlayView()
        
        self.tableView.reloadData()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.orgInfoView.alpha = 0.0
        }), completion: { (completed: Bool) in
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
        self.removeOrgInfoView()
    }
    
    @IBAction func dismissBtDevicesView(_ sender: UIButton) {
        Utilities.decorateDismissButtonTap(buttonToDecorate: sender, viewToDismiss: self.btDevicesView, tableViewToReloadData: self.tableView)
    }
        
    @IBAction func dismissOrgInfoView(_ sender: UIButton) {
        Utilities.decorateDismissButtonTap(buttonToDecorate: sender, viewToDismiss: self.orgInfoView, tableViewToReloadData: self.tableView)
        Utilities.dismissKeyboard(conroller: self)
    }
    
    @IBAction func dismissColorsView(_ sender: UIButton) {
        Utilities.decorateDismissButtonTap(buttonToDecorate: sender, viewToDismiss: self.colorsView, tableViewToReloadData: self.tableView)
        Utilities.dismissKeyboard(conroller: self)
    }
    
    @IBAction func dismissHostNameView(_ sender: UIButton) {
        Utilities.decorateDismissButtonTap(buttonToDecorate: sender, viewToDismiss: self.hostNameView, tableViewToReloadData: self.tableView)
        Utilities.dismissKeyboard(conroller: self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) != nil {
            
            if indexPath.row == 0 && indexPath.section == 0 {
                self.showOrgInfoView()
                return
            }
            
            if indexPath.row == 0 && indexPath.section == 1 {
                self.showAccentColorsView()
                return
            }
            
            if indexPath.row == 0 && indexPath.section == 2 {
                self.showBtDevicesView()
                return
            }
            
            if indexPath.row == 0 && indexPath.section == 3 {
                self.showHostNameView()
                return
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            self.setHostNameViewFrame()
            self.setOrgInfoViewFrame()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let _: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = 0
            self.setHostNameViewFrame()
            self.setOrgInfoViewFrame()
        }
    }
    
    func setOrgInfoViewFrame() {
        self.orgInfoView.center.x = (self.parentView?.center.x)!
        let productViewY = (UIScreen.main.bounds.height - self.keyboardHeight - self.orgInfoView.frame.height) / 2
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        
        self.orgInfoView.frame.origin.y =  productViewY < statusBarHeight ? statusBarHeight : productViewY
    }
    
    func setHostNameViewFrame() {
        self.hostNameView.center.x = self.view.center.x
        self.hostNameView.frame.origin.y = (UIScreen.main.bounds.height -  self.keyboardHeight - self.hostNameView.frame.height) / 2
    }
    
    func showHostNameView() {
        self.hostNameView.alpha = 0.0
        
        self.hostNameView.autoresizingMask =  [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.hostNameView.alpha = CGFloat(Utilities.alpha)
        }), completion: { (completed: Bool) in
        })
        
        self.changeAccentColorForHostNameView()
        
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.hostNameView)
        
        self.setHostNameViewFrame()
        
        Utilities.makeViewFlexibleAppearance(view: self.hostNameView)
        self.dismissHostNameButton.tintColor = Utilities.accentColor
        self.hostNameTextEdit.text = self.hostName
    }
    
    func showBtDevicesView() {
        self.btDevicesView.center = Utilities.getParentViewCenterPoint(parentView: self.parentView)
        self.btDevicesView.alpha = 0.0
        
        self.btDevicesView.autoresizingMask =  [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.btDevicesView.alpha = CGFloat(Utilities.alpha)
        }), completion: { (completed: Bool) in
        })
        
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.btDevicesView)
        
        Utilities.makeViewFlexibleAppearance(view: self.btDevicesView)
        self.dismissBtDevicesButton.tintColor = Utilities.accentColor
    }
    
    func showAccentColorsView() {
        self.colorsView.center = Utilities.getParentViewCenterPoint(parentView: self.parentView)
        self.colorsView.alpha = 0.0
        
        self.colorsView.autoresizingMask =  [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.colorsView.alpha = CGFloat(Utilities.alpha)
        }), completion: { (completed: Bool) in
        })
        
        Utilities.addOverlayView()
        
        self.parentView?.addSubview(self.colorsView)
        
        Utilities.makeViewFlexibleAppearance(view: self.colorsView)
        self.dismissColorsViewButton.tintColor = Utilities.accentColor
    }
    
    func showSelectedAccentColor() {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
        accessoryView.backgroundColor = Utilities.accentColor
        accessoryView.layer.cornerRadius = accessoryView.frame.width / 2
        self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.accessoryView = accessoryView
    }
    
    func showOrgInfoView() {
        self.orgInfoView.alpha = 0.0
        
        self.orgInfoView.autoresizingMask =  [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.orgInfoView.alpha = CGFloat(Utilities.alpha)
        }), completion: { (completed: Bool) in
        })
        
        self.changeAccentColorForOrgInfoView()
        
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.orgInfoView)
        
        self.setOrgInfoViewFrame()
        self.getOrgInfo()
        
        Utilities.makeViewFlexibleAppearance(view: self.orgInfoView)
        self.dismissOrgInfoButton.tintColor = Utilities.accentColor
    }
    
    func checkOrgInfo() -> Bool {
        let orgInfoDictionary = [self.orgNameTextField: "Отсутствует название организации!",
                                 self.pointNameTextField: "Отсутствует наименование торгового объекта!",
                                 self.pointAddressTextField: "Отсутствует адрес торгового объекта!",
                                 self.itnTextField: "Отсутствует ИНН организации!"]
        
        let emptyItem = orgInfoDictionary.sorted { $0.key!.tag < $1.key!.tag }.first(where: {key, value in
            return key?.text == Utilities.blankString
        })
        if emptyItem != nil {
            InfoAlertView().showInfoAlertView(infoTypeImageName: Utilities.infoViewImageNames.error.rawValue, parentView: self.parentView!, messageToShow: (emptyItem?.value)!)
            return false
        } else {
            return true
        }
    }
    
    @IBAction func setAccentColor(_ sender: UIButton) {
        for button in self.accentColorButtons {
            button.setImage(nil, for: .normal)
        }
        
        sender.setImage(Images.check, for: .normal)
        
        let colorIndex = Int16(self.accentColorButtons.firstIndex(of: sender)!)
        
        SettingsDBRules.changeAccentColorIndex(colorIndex: colorIndex)
        Utilities.accentColor = Utilities.colors[Int(colorIndex)]!
        
        self.dismissColorsViewButton.tintColor = Utilities.accentColor
        self.tableView.reloadData()
        self.btDevicesTableView.reloadData()
        
        Utilities.mainController!.tabBar.tintColor = Utilities.accentColor
        Utilities.dismissView(viewToDismiss: self.colorsView)
        
        self.colorsView.layer.borderColor = Utilities.accentColor.cgColor
        self.orgInfoView.layer.borderColor = Utilities.accentColor.cgColor
        self.btDevicesView.layer.borderColor = Utilities.accentColor.cgColor
        self.hostNameView.layer.borderColor = Utilities.accentColor.cgColor
        
        self.showSelectedAccentColor()
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
    
    @IBAction func getHostName(_ sender: UIButton) {
        if (self.hostNameTextEdit.text?.isEmpty)! {
            self.hostName = nil
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 3))?.textLabel!.text = "Ввести сетевое имя или IP-адрес устройства"
        } else {
            self.hostName = self.hostNameTextEdit.text
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 3))?.textLabel!.text = "Ввести сетевое имя или IP-адрес устройства [" + self.hostName! + "]"
        }
        
        if !SettingsDBRules.isTCPDeviceNamePresents() {
            SettingsDBRules.addNewTCPDeviceName(tcpDeviceName: self.hostName ?? nil)
        } else {
            SettingsDBRules.changeTCPDeviceName(tcpDeviceName: self.hostName ?? nil)
        }

        self.dismissHostNameView(sender)
    }
    
}
