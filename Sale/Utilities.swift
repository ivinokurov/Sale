//
//  Products.swift
//  Sale
//


import UIKit

class Utilities: Any {

    static let productImages = ["RedApples", "GreenApples", "Cherry", "Strawberry", "Tangerine", "Cake", "Coca-Cola"]
    static let productNames = ["Красные яблоки. Словакия", "Зеленые яблоки. Венгрия", "Вишня. Испания", "Клубника. Франция", "Мандарины. Марокко", "Торт. Россия", "Coca-Cola. Россия"]
    static let productPrices = [65.50, 75.5, 350.00, 520.70, 70.0, 250.0, 75.0]
    static let barcodes = ["9788420532318", "5012345678900", "5901234123457", "4606453849072", "4623720660024", "6009800461091", "9780000000002"]
    
    static let catigories = ["Фрукты", "Кондитерские изделия", "Напитки"]
    
    static var productsCount = ["Красные яблоки. Словакия": 0,
                                "Зеленые яблоки. Венгрия": 0,
                                "Вишня. Испания": 0,
                                "Клубника. Франция": 0,
                                "Мандарины. Марокко": 0,
                                "Торт. Россия": 0,
                                "Coca-Cola. Россия": 0]
    
    static let productCount = productImages.count
    
    class func showOneButtonAlert(controllerInPresented controller: UIViewController, alertTitle title: String, alertMessage message: String, alertButtonHandler handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler))
        controller.present(alert, animated: true, completion: nil)
    }
}
