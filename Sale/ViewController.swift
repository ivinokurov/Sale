//
//  ViewController.swift
//  Sale
//


import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Utilities.showErrorAlertView(alertTitle: "Другие закладки приложения", alertMessage: "В демо версии не реализовано")
    }
}

