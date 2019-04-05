//
//  MainTabBarController.swift
//  Sale
//


import UIKit

class MainTabBarController: UITabBarController, DTDeviceDelegate  {
    
    let btDevices = BluetoothDevicesInterconnection()

    override func viewDidLoad() {
        super.viewDidLoad()

        Utilities.mainController = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let cashboxController = storyboard.instantiateViewController(withIdentifier: "cashboxControllerId") as! CashboxNavigationController
        let splitController = storyboard.instantiateViewController(withIdentifier: "splitControllerId") as! ProductsSplitViewController
        let personalController = storyboard.instantiateViewController(withIdentifier: "personalControllerId") as! PersonalNavigationController
        let reportsController = storyboard.instantiateViewController(withIdentifier: "reportsControllerId") as! ReportsNavigationController
        let settingsController = storyboard.instantiateViewController(withIdentifier: "settingsControllerId") as! SettingsNavigationController
        
        switch self.getCurrentPersonRole() {
            case Utilities.personRole.admin.rawValue:
            do {
                self.viewControllers = [cashboxController, splitController, personalController, reportsController, settingsController]
            }
        case Utilities.personRole.merchandiser.rawValue:
            do {
                self.viewControllers = [cashboxController, splitController, personalController]
            }
        case Utilities.personRole.cashier.rawValue:
            do {
                self.viewControllers = [cashboxController, personalController]
            }
        default: self.viewControllers = nil
        }
        
        Utilities.splitController = splitController
        Utilities.customizePopoverView(customizedView: splitController.alertView)
        
        self.btDevices.findBluetoothDevices()

        splitController.alertView.alpha = 0.0
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
