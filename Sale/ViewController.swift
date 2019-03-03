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
        
        Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "Другие закладки приложения", alertMessage: "В демо версии не реализовано", alertButtonHandler: nil)
    }
}

