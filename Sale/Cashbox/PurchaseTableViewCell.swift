//
//  PurchaseTableViewCell.swift
//  Sale
//


import UIKit

class PurchaseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var purchaseNameLabel: UILabel!
    @IBOutlet weak var purchaseDescLabel: UILabel!
    @IBOutlet weak var purchasePriceLabel: UILabel!
    @IBOutlet weak var purchaseCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initCell(productBarcode: String) {
        if let product = ProductsDBRules.getProductByBarcode(code: productBarcode) {
            self.purchaseNameLabel.text = product.value(forKey: "name") as? String
            
            let productDesc = product.value(forKeyPath: "desc") as? String
            self.purchaseDescLabel.text = productDesc == "" ? "Без описания" : productDesc
            
            self.purchasePriceLabel.text = (product.value(forKeyPath: "price") as? Float)?.description
            
            self.purchaseCountLabel.text = (PurchaseDBRules.getProductsCountInPurchase(productBarcode: productBarcode)?.description)! + ProductsDBRules.getProductMeasure(product: product)
        }
    }
}
