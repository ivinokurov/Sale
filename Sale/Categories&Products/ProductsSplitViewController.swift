//
//  ProductsSplitViewController.swift
//  Sale
//


import UIKit

class ProductsSplitViewController: UISplitViewController {
    
    @IBOutlet var alertView: UIView!
    @IBOutlet weak var alertImageView: UIImageView!
    @IBOutlet weak var alertTextLabel: UILabel!
    @IBOutlet weak var dismissAlertButton: UIButton!
    
    var isAlertViewPresented: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isAlertViewPresented {
            self.alertView.isHidden = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.isAlertViewPresented {
            self.alertView.isHidden = true
        }
    }
        
    func initAndShowAlertView(imageName: String, text: String) {
        DispatchQueue.main.async {
            self.alertImageView.image = UIImage(named: imageName)
            self.alertTextLabel.text = text
        }
        
        self.showAlertView()
    }
    
    func showAlertView() {
        self.isAlertViewPresented = true
        
        DispatchQueue.main.async {
            Utilities.addAlertOverlayView()
        
        self.alertView.center = Utilities.mainController!.view.center
        Utilities.mainController!.view.addSubview(self.alertView)
        self.isAlertViewPresented = true
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.alertView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
        
        self.dismissAlertButton.tintColor = Utilities.accentColor
    //    Utilities.makeViewFlexibleAppearance(view: self.alertView)
        }
    }
    
     @IBAction func dismissAlertView(_ sender: Any) {
        Utilities.decorateButtonTap(buttonToDecorate: self.dismissAlertButton)
        Utilities.removeAlertOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.alertView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isAlertViewPresented = false
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size , with: coordinator)

        if self.isAlertViewPresented {
            self.alertView.removeFromSuperview()
            
            coordinator.animate(alongsideTransition: { _ in
                self.alertView.center = self.parent!.view.center
                Utilities.addAlertOverlayView()
                Utilities.mainController!.view.addSubview(self.alertView)
            })
        }

    }
    
}

