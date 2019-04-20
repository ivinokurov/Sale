//
//  MainTabBarController.swift
//  Sale
//


import UIKit
import ExternalAccessory

class MainTabBarController: UITabBarController, EAAccessoryDelegate, DTDeviceDelegate  {
    
//    let btDevices = BluetoothDevicesInterconnection()
    var btSession: EASession? = nil
    var btAccessory: EAAccessory? = nil
    var accessories: [EAAccessory]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        Utilities.mainController = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let cashboxController = storyboard.instantiateViewController(withIdentifier: "cashboxControllerId") as! CashboxNavigationController
        let productsSplitController = storyboard.instantiateViewController(withIdentifier: "splitControllerId") as! ProductsSplitViewController
        let personalController = storyboard.instantiateViewController(withIdentifier: "personalControllerId") as! PersonalNavigationController
        let reportsSplitontroller = storyboard.instantiateViewController(withIdentifier: "reportsControllerId") as! ReportsSplitViewController
        let settingsController = storyboard.instantiateViewController(withIdentifier: "settingsControllerId") as! SettingsNavigationController
        Utilities.settingsNavController = settingsController
        
        switch self.getCurrentPersonRole() {
            case Utilities.personRole.admin.rawValue:
            do {
                self.viewControllers = [cashboxController, productsSplitController, personalController, reportsSplitontroller, settingsController]
            }
        case Utilities.personRole.merchandiser.rawValue:
            do {
                self.viewControllers = [cashboxController, productsSplitController, personalController]
            }
        case Utilities.personRole.cashier.rawValue:
            do {
                self.viewControllers = [cashboxController, personalController]
            }
        default: self.viewControllers = nil
        }
        
        Utilities.productsSplitController = productsSplitController
        Utilities.reportsSplitController = reportsSplitontroller
        
        Utilities.customizePopoverView(customizedView: productsSplitController.alertView)

    //    self.btDevices.findBluetoothDevices()

        productsSplitController.alertView.alpha = 0.0
    }
    
    func accessoryDidDisconnect(_ accessory: EAAccessory) {
        Utilities.showSimpleAlert(controllerToShowFor: self, messageToShow: accessory.name)
    }
    
    @objc func accessoryConnected(_ notification: NSNotification) {
        Utilities.showSimpleAlert(controllerToShowFor: self, messageToShow: notification.description)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBar.tintColor = Utilities.accentColor
    }
    
    func getCurrentPersonRole () -> Int {
        let personRole = PersonalDBRules.getPersonRoleByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)!
        
        return Int(personRole)
    }

}
