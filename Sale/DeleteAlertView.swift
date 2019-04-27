//
//  DeleteAlertView.swift
//  Sale
//


import UIKit

class DeleteAlertView: UIView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var delete: (() -> ())? = nil
    var cancel: (() -> ())? = nil
        
    @IBAction func deleteAction(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        _ = self.delete!()
        self.removeDeleteAlertView()
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        _ = self.cancel ?? nil
        self.removeDeleteAlertView()
    }
    
    @objc func showDeleteAlertView(parentView view: UIView, messageToShow message: String, deleteHandler delete: (() -> ())?, deleteButtonText text: String? = "УДАЛИТЬ") {
        if let deleteView = Bundle.main.loadNibNamed("DeleteAlertView", owner: self, options: nil)?.first as? DeleteAlertView {
            
            Utilities.customizePopoverView(customizedView: deleteView)
            
            deleteView.autoresizingMask =  [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]

            deleteView.cancelButton.tintColor = Utilities.accentColor
            deleteView.messageLabel.text = message
            deleteView.deleteButton.setTitle(text, for: .normal)
            deleteView.delete = delete
            deleteView.alpha = 0.0
            
            UIView.animate(withDuration: Utilities.animationDuration, animations: ({
                deleteView.alpha = CGFloat(Utilities.alpha)
            }), completion: { (completed: Bool) in
            })
            
            Utilities.addOverlayView()
            view.addSubview(deleteView)
            
            deleteView.center = Utilities.getParentViewCenterPoint(parentView: view)
        }
    }
    
    func removeDeleteAlertView() {
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.alpha = 0.0
        }), completion: { (completed: Bool) in
        })
    }
    
}
