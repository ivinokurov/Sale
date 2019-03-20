//
//  Products.swift
//  Sale
//


import UIKit

class Utilities: Any {

    static let productImages = ["RedApples", "GreenApples", "Cherry", "Strawberry", "Tangerine", "Cake", "Coca-Cola"]
    static let productNames = ["КРАСНЫЕ ЯБЛОКИ. Словакия", "ЗЕЛЁНЫЕ ЯБЛОКИ. Венгрия", "ВИШНЯ. Испания", "КЛУБНИКА. Франция", "МАНДАРИНЫ. Марокко", "ТОРТ. Россия", "COCA-COLA. Россия"]
    static let productPrices = [65.50, 75.5, 350.00, 520.70, 70.0, 250.0, 75.0]
    static let barcodes = ["9788420532318", "5012345678900", "5901234123457", "4606453849072", "4623720660024", "6009800461091", "9780000000002"]
    
    static let catigories = ["Фрукты", "Кондитерские изделия", "Напитки"]
    
    static var productsCount = ["КРАСНЫЕ ЯБЛОКИ. Словакия": 0,
                                "ЗЕЛЁНЫЕ ЯБЛОКИ. Венгрия": 0,
                                "ВИШНЯ. Испания": 0,
                                "КЛУБНИКА. Франция": 0,
                                "МАНДАРИНЫ. Марокко": 0,
                                "ТОРТ. Россия": 0,
                                "COCA-COLA. Россия": 0]
    
    enum measures: Int {
        case items = 1, kilos = 2, liters = 3
    }
    
    static let productCount = productImages.count
    static var splitController: UISplitViewController? = nil
    
    static let deleteActionBackgroundColor = UIColor.red.withAlphaComponent(0.4)
    static let editActionBackgroundColor = UIColor.green.withAlphaComponent(0.4)
    static let animationDuration = 0.2
    static let alpha = 0.94
    static let overlayView: UIView = UIView()
    static let accentColor: UIColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    
    class func addOverlayView() {
        self.overlayView.frame = CGRect(x: 0, y: 0, width: 5000, height: 5000)
        self.overlayView.isOpaque = false
        self.overlayView.alpha = 0.2
        self.overlayView.backgroundColor = UIColor.lightGray
        self.splitController!.view.addSubview(self.overlayView)
    }
    
    class func removeOverlayView() {
        self.overlayView.removeFromSuperview()
    }
    
    class func showOneButtonAlert(controllerInPresented controller: UIViewController, alertTitle title: String, alertMessage message: String, alertButtonHandler handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler))
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
        button.layer.cornerRadius = 4
        button.layer.borderColor = self.accentColor.withAlphaComponent(0.4).cgColor
    }
    
    class func decorateButtonTap(buttonToDecorate button: UIButton) {
        button.layer.backgroundColor = self.accentColor.withAlphaComponent(0.2).cgColor
        UIView.animate(withDuration: 0.4, animations: ({
            button.layer.backgroundColor = UIColor.white.cgColor
        }), completion: { (completed: Bool) in
            
        })
    }
    
    class func setCellSelectedColor(cellToSetSelectedColor cell: UITableViewCell) {
        let bgkColorView = UIView()
        bgkColorView.backgroundColor = self.accentColor.withAlphaComponent(0.1)
        cell.selectedBackgroundView = bgkColorView
    }
    
    class func setCollectionViewCellSelectedColor(cellToSetSelectedColor cell: UICollectionViewCell) {
        let bgkColorView = UIView()
        bgkColorView.backgroundColor = self.accentColor.withAlphaComponent(0.1)
        cell.selectedBackgroundView = bgkColorView
    }
    
    class func makeLeftViewForTextField(textEdit: UITextField, imageName: String) {
        textEdit.leftViewMode = UITextField.ViewMode.always
        let textFeildImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        textFeildImageView.image = UIImage(named: imageName)
        textEdit.leftView = textFeildImageView
    }
    
    class func makeButtonRounded(button: UIView) {
        button.tintColor = self.accentColor
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.borderColor = self.accentColor.cgColor
        button.layer.borderWidth = 1.0
    }
    
    class func dismissKeyboard(conroller: UIViewController) {
        UIApplication.shared.sendAction(#selector(conroller.resignFirstResponder), to: nil, from: nil, for: nil)
    }

}
