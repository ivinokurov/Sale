//
//  ProductsSplitViewController.swift
//  Sale
//


import UIKit

class ProductsSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.splitController = self
        self.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
    }
}

