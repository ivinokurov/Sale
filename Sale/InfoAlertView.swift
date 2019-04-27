//
//  InfoAlertView.swift
//  Sale
//


import UIKit

class InfoAlertView: UIView {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    @IBAction func dismissAction(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        self.removeInfoAlertView()
    }
    
    @objc func showInfoAlertView(infoTypeImageName imageName: String, parentView view: UIView, messageToShow message: String) {
        if let infoView = Bundle.main.loadNibNamed("InfoAlertView", owner: self, options: nil)?.first as? InfoAlertView {
            
            Utilities.customizePopoverView(customizedView: infoView)
            
            infoView.autoresizingMask =  [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            
            infoView.iconImageView.image = UIImage(named: imageName)
            infoView.okButton.tintColor = Utilities.accentColor
            infoView.messageLabel.text = message
            infoView.alpha = 0.0
            
            UIView.animate(withDuration: Utilities.animationDuration, animations: ({
                infoView.alpha = CGFloat(Utilities.alpha)
            }), completion: { (completed: Bool) in
            })
            
            Utilities.addAlertOverlayView(parentView: view)
            view.addSubview(infoView)
            
            infoView.center = Utilities.getParentViewCenterPoint(parentView: view)
        }
    }
    
    func removeInfoAlertView() {
        Utilities.removeAlertOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.alpha = 0.0
        }), completion: { (completed: Bool) in
        })
    }
    
}
