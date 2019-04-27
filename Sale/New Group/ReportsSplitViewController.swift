//
//  ReportsSplitViewController.swift
//  Sale
//


import UIKit

class ReportsSplitViewController: UISplitViewController {
    
    var reportsSelectedPersonName: String? = nil
    var reportsSelectedPersonRole: Int16? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
    }

}
