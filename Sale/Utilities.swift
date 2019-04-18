//
//  Products.swift
//  Sale
//


import UIKit

class Utilities: Any {
    
    enum measures: Int {
        case items = 1, kilos = 2, liters = 3
    }
    
    enum personRole: Int {
        case admin = 1, merchandiser = 2, cashier = 3
    }
    
    static let colors = [0: UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0),
                         3: UIColor(red: 0/255, green: 107/255, blue: 109/255, alpha: 1.0),
                         1: UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0),
                         2: UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1.0),
                         4: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)]
    
    static let roleNames = [1: "Администратор", 2: "Товаровед", 3: "Кассир"]
    
    static let digitsOny = "0123456789"
    static let floatNumbersOnly = "0123456789."
    
    static var mainController: MainTabBarController? = nil    
    static var productsSplitController: ProductsSplitViewController? = nil
    static var reportsSplitController: ReportsSplitViewController? = nil
    static var settingsNavController: SettingsNavigationController? = nil
    static let deleteActionBackgroundColor = UIColor.red.withAlphaComponent(0.6)
    static let editActionBackgroundColor = UIColor.green.withAlphaComponent(0.6)
    static let animationDuration = 0.4
    static let alpha = 0.94
    static let overlayView: UIView = UIView()
    static let alertOverlayView: UIView = UIView()
    static let lightGrayColor: UIColor = UIColor(red: 235/255, green: 235/255, blue: 241/255, alpha: 1.0)
    static let barCodeButtonColor = UIColor.blue
    static let buyProductButtonColor = UIColor(red: 0/255, green: 143/255, blue: 0/255, alpha: 1.0)
    static let buyProductsButtonColor = UIColor(red: 0/255, green: 84/255, blue: 147/255, alpha: 1.0)
    static let titlesColor = UIColor(red: 7/255, green: 50/255, blue: 89/255, alpha: 1.0)
    static let deleteProductsButtonColor = UIColor.red
    static var accentColor: UIColor = colors[0]!
    static let inactiveColor: UIColor = UIColor.lightGray.withAlphaComponent(0.3)
    static var isPersonLogout: Bool = false
    
    class func addOverlayView() {
        self.overlayView.frame = CGRect(x: 0, y: 0, width: 2 * UIScreen.main.bounds.height, height: 2 * UIScreen.main.bounds.height) 
        self.overlayView.isOpaque = false
        self.overlayView.alpha = 0.4
        self.overlayView.backgroundColor = UIColor.darkGray
        self.mainController!.view.addSubview(self.overlayView)
    }
    
    class func addOverlayViewToParent(parent: UIView) {
        self.overlayView.frame = CGRect(x: 0, y: 0, width: 2 * UIScreen.main.bounds.height, height: 2 * UIScreen.main.bounds.height)
        self.overlayView.isOpaque = false
        self.overlayView.alpha = 0.4
        self.overlayView.backgroundColor = UIColor.darkGray
        parent.addSubview(self.overlayView)
    }
    
    class func addAlertOverlayView() {
        self.alertOverlayView.frame = CGRect(x: 0, y: 0, width: 2 * UIScreen.main.bounds.height, height: 2 * UIScreen.main.bounds.height)
        self.alertOverlayView.isOpaque = false
        self.alertOverlayView.alpha = 0.4
        self.alertOverlayView.backgroundColor = UIColor.darkGray
        self.mainController!.view.addSubview(self.alertOverlayView)
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
        self.productsSplitController!.initAndShowAlertView(imageName: "Ok", text: message)
    }

    class func showErrorAlertView(alertTitle title: String, alertMessage message: String) {
        self.productsSplitController!.initAndShowAlertView(imageName: "Error", text: message)
    }
    
    class func showSimpleAlert(controllerToShowFor controller: UIViewController, messageToShow message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.destructive, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func showTwoButtonsAlert(controllerInPresented controller: UIViewController, alertTitle title: String, alertMessage message: String, okButtonHandler okHandler: ((UIAlertAction) -> Void)?, cancelButtonHandler cancelHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: okHandler))
        alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.destructive, handler: cancelHandler))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func decorateButton(buttonToDecorate button: UIButton) {
        button.layer.borderWidth = 0.4
        button.layer.cornerRadius = 8
        button.backgroundColor = self.accentColor
        button.layer.borderColor = self.accentColor.withAlphaComponent(0.2).cgColor
    }
    
    class func decorateButtonTap(buttonToDecorate button: UIButton) {
        button.layer.backgroundColor = self.accentColor.withAlphaComponent(0.04).cgColor
        UIView.animate(withDuration:self.animationDuration, animations: ({
            button.layer.backgroundColor = UIColor.white.cgColor
        }), completion: { (completed: Bool) in
        })
    }
    
    class func decorateViewTap(viewToDecorate view: UIView) {
        view.layer.backgroundColor = self.accentColor.withAlphaComponent(0.04).cgColor
        UIView.animate(withDuration:self.animationDuration, animations: ({
            view.layer.backgroundColor = UIColor.white.cgColor
        }), completion: { (completed: Bool) in
        })
    }
    
    class func setCellSelectedColor(cellToSetSelectedColor cell: UITableViewCell) {
        let bgkColorView = UIView()
        bgkColorView.backgroundColor = self.accentColor.withAlphaComponent(0.08)
        cell.selectedBackgroundView = bgkColorView
    }
    
    class func setCollectionViewCellSelectedColor(cellToSetSelectedColor cell: UICollectionViewCell) {
        let bgkColorView = UIView()
        bgkColorView.backgroundColor = self.accentColor.withAlphaComponent(0.08)
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
        button.tintColor = self.titlesColor // self.accentColor
        button.layer.borderColor = self.titlesColor.cgColor
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.borderWidth = 1.0
    }
    
    class func dismissKeyboard(conroller: UIViewController) {
        UIApplication.shared.sendAction(#selector(conroller.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    class func customizePopoverView(customizedView view: UIView) {
        view.layer.borderColor = Utilities.accentColor.cgColor
        view.layer.borderWidth = 0.4
        view.layer.cornerRadius = 12
    }
    
    class func setAccentColorForSomeViews(viewsToSetAccentColor views: [UIView]) {
        for view in views {
           view.tintColor = Utilities.accentColor
        }
    }
    
    class func setBkgColorForSomeViews(viewsToSetAccentColor views: [UIView]) {
        for view in views {
            view.backgroundColor = self.inactiveColor // Utilities.accentColor
        }
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
    
    class func localizeStorybordView(staticViewTitles dic: Dictionary<UIView, String>) {
        for staticView in dic {
            if staticView.key.isKind(of: UILabel.self) {
                (staticView.key as! UILabel).text = NSLocalizedString(dic[staticView.key]!, comment: "")
            }
            if staticView.key.isKind(of: UIButton.self) {
                (staticView.key as! UIButton).setTitle(NSLocalizedString(dic[staticView.key]!, comment: ""), for: .normal)
            }
        }
    }
    
    class func createDismissButton(button: UIButton) {
        button.tintColor = Utilities.accentColor
        button.setImage(UIImage(named: "Cross"), for: .normal)
        self.makeButtonRounded(button: button)
        button.layer.borderColor = UIColor.clear.cgColor
    }
    
    class func dismissView(viewToDismiss view: UIView) {
        self.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            view.alpha = 0.0
        }), completion: { (completed: Bool) in
        })
    }
    
    class func makeViewsActive(viewsToMakeActive views: [UIView]) {
        views.forEach({ view in
            view.isUserInteractionEnabled = true
            
            if view .isKind(of: UITextField.self) {
                (view as! UITextField).textColor = UIColor.black
            }
        })
    }
    
    class func makeViewsInactive(viewsToMakeInactive views: [UIView]) {
        views.forEach({ view in
            view.isUserInteractionEnabled = false
            
            if view .isKind(of: UITextField.self) {
                (view as! UITextField).textColor = UIColor.lightGray
            }
        })
    }

}
