//
//  Products.swift
//  Sale
//


import UIKit

class Utilities: Any {

    static let productImages = ["RedApples", "GreenApples", "Cherry", "Strawberry"]    
    static let productNames = ["Красные яблоки. Словакия", "Зеленые яблоки. Венгрия", "Вишня. Испания", "Клубника. Франция"]
    static let productPrices = [65.50, 75.5, 350.00, 520.70]
    static let barcodes = ["8580123456789", "5990123456789", "8400123456789", "3000123456789"]
    
    static var productsCount = ["Красные яблоки. Словакия": 0,
                                "Зеленые яблоки. Венгрия": 0,
                                "Вишня. Испания": 0,
                                "Клубника. Франция": 0]
    
    static let productCount = productImages.count
    
    class func showOneButtonAlert(controllerInPresented controller: UIViewController, alertTitle title: String, alertMessage message: String, alertButtonHandler handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler))
        controller.present(alert, animated: true, completion: nil)
    }
}
