//
//  Products.swift
//  Sale
//


import UIKit

class Utilities: NSObject {
    
    enum measures: Int {
        case items = 1, kilos = 2, liters = 3
    }
    enum personRole: Int {
        case admin = 1, merchandiser = 2, cashier = 3
    }
    enum infoViewImageNames: String {
        case success = "Ok", error = "Error"
    }
   
    static let colors = [0: UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0),
                         3: UIColor(red: 0/255, green: 107/255, blue: 109/255, alpha: 1.0),
                         1: UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0),
                         2: UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1.0),
                         4: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)]
    
    static let roleNames = [1: "Администратор", 2: "Товаровед", 3: "Кассир"]
    
    static let adminPrompt = "Вы - администратор. Для вас доступны:\n\n" +
        "1. Кассовые операции.\n" +
        "2. Операции ведения складского учета.\n" +
        "3. Операции с персоналом.\n" +
        "4. Формирование отчетов и настроек приложения."
    static let merchandiserPrompt = "Вы - товаровед. Для вас доступны:\n\n" +
        "1. Кассовые операции.\n" +
        "2. Операции ведения складского учета.\n" +
        "3. Операции с персональной информацией."
    static let cashierPrompt = "Вы - кассир. Для вас доступны:\n\n" +
        "1. Кассовые операции.\n" +
        "2. Операции с персональной информацией."
    
    static let digitsOny = "0123456789"
    static let floatNumbersOnly = "0123456789."
    static let cornerRadius: CGFloat = 12
    static let overlayAlpha: CGFloat = 0.6
    static let animationDuration = 0.4
    static let popoverViewAlpha = 0.94
    static let blankString = "" 
    
    static var mainController: MainTabBarController? = nil    
    static var productsSplitController: ProductsSplitViewController? = nil
    static var reportsSplitController: ReportsSplitViewController? = nil
    static var settingsNavController: SettingsNavigationController? = nil
    static let deleteActionBackgroundColor = UIColor.red.withAlphaComponent(0.6)
    static let editActionBackgroundColor = UIColor.green.withAlphaComponent(0.6)
    static let overlayView: UIView = UIView()
    static let alertOverlayView: UIView = UIView()
    static let lightGrayColor: UIColor = UIColor(red: 235/255, green: 235/255, blue: 241/255, alpha: 1.0)
    static let barCodeButtonColor = UIColor.blue
    static let buyProductButtonColor = UIColor(red: 0/255, green: 143/255, blue: 0/255, alpha: 1.0)
    static let buyProductsButtonColor = UIColor(red: 0/255, green: 84/255, blue: 147/255, alpha: 1.0)
    static let titlesColor = UIColor(red: 7/255, green: 50/255, blue: 89/255, alpha: 1.0)
    static let openSessionColor = UIColor(red: 0/255, green: 143/255, blue: 0/255, alpha: 1.0)
    static let closeSessionColor = UIColor.red
    static let deleteProductsButtonColor = UIColor.red
    static var accentColor: UIColor = colors[0]!
    static let inactiveColor: UIColor = UIColor.lightGray.withAlphaComponent(0.3)
    static var isPersonLogout: Bool = false
    
    class func addOverlayView(parentView view: UIView? = nil) {
        self.overlayView.frame = CGRect(x: 0, y: 0, width: 2 * UIScreen.main.bounds.height, height: 2 * UIScreen.main.bounds.height) 
        self.overlayView.isOpaque = false
        self.overlayView.alpha = self.overlayAlpha
        self.overlayView.backgroundColor = UIColor.darkGray
        if view == nil {
            self.mainController!.view.addSubview(self.overlayView)
        } else {
            view!.addSubview(self.overlayView)
        }
    }
    
    class func addAlertOverlayView(parentView view: UIView? = nil) {
        self.alertOverlayView.frame = CGRect(x: 0, y: 0, width: 2 * UIScreen.main.bounds.height, height: 2 * UIScreen.main.bounds.height)
        self.alertOverlayView.isOpaque = false
        self.alertOverlayView.alpha = self.overlayAlpha
        self.alertOverlayView.backgroundColor = UIColor.darkGray
        if view == nil {
            self.mainController!.view.addSubview(self.overlayView)
        } else {
            view!.addSubview(self.alertOverlayView)
        }
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
    
    /*
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
    */
    
    class func decorateButton(buttonToDecorate button: UIButton) {
        button.layer.borderWidth = 0.4
        button.layer.cornerRadius = self.cornerRadius
        button.backgroundColor = self.accentColor
        button.layer.borderColor = self.accentColor.withAlphaComponent(0.2).cgColor
    }
    
    class func decorateDismissButtonTap(buttonToDecorate button: UIButton, viewToDismiss view: UIView, tableViewToReloadData tableView: UITableView? = nil) {
        button.layer.backgroundColor = UIColor.clear.cgColor
        UIView.animate(withDuration: self.animationDuration / 2, animations: ({
            button.layer.backgroundColor = self.accentColor.withAlphaComponent(0.1).cgColor
        }), completion: { (completed: Bool) in
            if completed {
                button.layer.backgroundColor = UIColor.clear.cgColor
                Utilities.dismissView(viewToDismiss: view)
                tableView?.reloadData()
            }
        })
    }
    
    class func decorateButtonTap(buttonToDecorate button: UIButton) {
        button.layer.backgroundColor = self.accentColor.withAlphaComponent(0.04).cgColor
        UIView.animate(withDuration:self.animationDuration, animations: ({
            button.layer.backgroundColor = UIColor.clear.cgColor
        }), completion: { (completed: Bool) in
        })
    }
    
    class func decorateViewTap(viewToDecorate view: UIView) {
        view.layer.backgroundColor = self.accentColor.withAlphaComponent(0.04).cgColor
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
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
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 0.2
        view.layer.cornerRadius = self.cornerRadius
        view.layer.shadowColor = UIColor.darkGray.cgColor 
        view.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 3
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
        button.setImage(Images.cross, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
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
    
    class func getDateStr(dateToString date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
    class func getParentViewCenterPoint(parentView view: UIView?) -> CGPoint {
        let centerX = (view?.center.x)!
        let centerY = (view?.center.y)!
        
        return CGPoint(x: centerX, y: centerY)
    }

}
