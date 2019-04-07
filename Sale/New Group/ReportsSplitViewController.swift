//
//  ReportsSplitViewController.swift
//  Sale
//


import UIKit

class ReportsSplitViewController: UISplitViewController {
    
    var selectedReportPersonName: String? = nil
    var selectedReportPersonRole: Int16? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
    }

}
