//
//  Products.swift
//  Sale
//


import UIKit

class Utilities: Any {
    
    enum measures: Int {
        case items = 1, kilos = 2, liters = 3
    }
    
    static var splitController: ProductsSplitViewController? = nil
    
    static let deleteActionBackgroundColor = UIColor.red.withAlphaComponent(0.6)
    static let editActionBackgroundColor = UIColor.green.withAlphaComponent(0.6)
    static let animationDuration = 0.4
    static let alpha = 0.94
    static let overlayView: UIView = UIView()
    static let alertOverlayView: UIView = UIView()
    static let barButtonItemColor: UIColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static let barCodeButtonColor = UIColor.blue
    static let buyProductButtonColor = UIColor(red: 0/255, green: 143/255, blue: 0/255, alpha: 1.0)
    static let buyProductsButtonColor = UIColor(red: 0/255, green: 84/255, blue: 147/255, alpha: 1.0)
    static let deleteProductsButtonColor = UIColor.red
    static let accentColor: UIColor = .red
    
    class func addOverlayView() {
        self.overlayView.frame = CGRect(x: 0, y: 0, width: 5000, height: 5000) // my little joke :)
        self.overlayView.isOpaque = false
        self.overlayView.alpha = 0.4
        self.overlayView.backgroundColor = UIColor.darkGray
        self.splitController!.parent!.view.addSubview(self.overlayView)
    }
    
    class func addAlertOverlayView() {
        self.alertOverlayView.frame = CGRect(x: 0, y: 0, width: 5000, height: 5000) // my little joke :)
        self.alertOverlayView.isOpaque = false
        self.alertOverlayView.alpha = 0.4
        self.alertOverlayView.backgroundColor = UIColor.darkGray
        self.splitController!.parent!.view.addSubview(self.alertOverlayView)
    }
    
    class func removeOverlayView() {
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.overlayView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.overlayView.removeFromSuperview()
        })
    }
    
    class func removeAlertOverlayView() {
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.alertOverlayView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.alertOverlayView.removeFromSuperview()
        })
    }
    
    class func showOkAlertView(alertTitle title: String, alertMessage message: String) {
        (self.splitController as! ProductsSplitViewController).initAndShowAlertView(imageName: "Ok", text: message)
    }

    class func showErrorAlertView(alertTitle title: String, alertMessage message: String) {
        (self.splitController as! ProductsSplitViewController).initAndShowAlertView(imageName: "Error", text: message)
    }
    
    class func showTwoButtonsAlert(controllerInPresented controller: UIViewController, alertTitle title: String, alertMessage message: String, okButtonHandler okHandler: ((UIAlertAction) -> Void)?, cancelButtonHandler cancelHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: okHandler))
        alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.destructive, handler: cancelHandler))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func decorateButton(buttonToDecorate button: UIButton) {
        button.layer.borderWidth = 0.4
        button.layer.cornerRadius = 4
        button.layer.borderColor = self.accentColor.withAlphaComponent(0.2).cgColor
    }
    
    class func decorateButtonTap(buttonToDecorate button: UIButton) {
        button.layer.backgroundColor = self.accentColor.withAlphaComponent(0.04).cgColor
        UIView.animate(withDuration:self.animationDuration, animations: ({
            button.layer.backgroundColor = UIColor.white.cgColor
        }), completion: { (completed: Bool) in
            
        })
    }
    
    class func setCellSelectedColor(cellToSetSelectedColor cell: UITableViewCell) {
        let bgkColorView = UIView()
        bgkColorView.backgroundColor = self.accentColor.withAlphaComponent(0.04)
        cell.selectedBackgroundView = bgkColorView
    }
    
    class func setCollectionViewCellSelectedColor(cellToSetSelectedColor cell: UICollectionViewCell) {
        let bgkColorView = UIView()
        bgkColorView.backgroundColor = self.accentColor.withAlphaComponent(0.04)
        cell.selectedBackgroundView = bgkColorView
    }
    
    class func makeLeftViewForTextField(textEdit: UITextField, imageName: String) {
        textEdit.leftViewMode = UITextField.ViewMode.always
        let textFeildImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        textFeildImageView.image = UIImage(named: imageName)
        textFeildImageView.tintColor = .darkGray
        textEdit.leftView = textFeildImageView
    }
    
    class func makeButtonRounded(button: UIView) {
        button.tintColor = self.barButtonItemColor
        button.layer.borderColor = self.barButtonItemColor.cgColor
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.borderWidth = 1.0
    }
    
    class func dismissKeyboard(conroller: UIViewController) {
        UIApplication.shared.sendAction(#selector(conroller.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    class func customizePopoverView(customizedView view: UIView) {
        view.layer.borderColor = Utilities.accentColor.cgColor
        view.layer.borderWidth = 0.4
        view.layer.cornerRadius = 8
    }
    
    class func makeViewFlexibleAppearance(view: UIView) {
        let previousTransform = view.transform
        view.layer.transform = CATransform3DMakeScale(0.99, 0.99, 0.0);
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            view.layer.transform = CATransform3DMakeScale(1.0, 1.0, 0.0);
        }, completion: { (Bool) -> Void in
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                view.layer.transform = CATransform3DMakeScale(0.99, 0.99, 0.0);
            }, completion: { (Bool) -> Void in
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    view.layer.transform = CATransform3DMakeScale(1.0, 1.0, 0.0);
                }, completion: { (Bool) -> Void in
                    view.transform = previousTransform
                })
            })
        })
    }

}
