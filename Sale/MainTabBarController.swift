//
//  MainTabBarController.swift
//  Sale
//


import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let splitController = self.viewControllers![1] as! ProductsSplitViewController
        Utilities.splitController = splitController
        Utilities.customizePopoverView(customizedView: splitController.alertView)
   //     splitController.alertView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        splitController.alertView.alpha = 0.0
    }

}
