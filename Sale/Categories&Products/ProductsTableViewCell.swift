//
//  ProductsTableViewCell.swift
//  Sale
//


import UIKit

class ProductsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!    
    @IBOutlet weak var productBarcodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initCell(categoryName: String, indexPath: IndexPath, isFiltered: Bool) {
        
        var products: [NSObject]?
        
        if isFiltered {
            products = ProductsDBRules.filteredProducts
        } else {
            let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: categoryName)
            products = ProductsDBRules.getCategoryProducts(productCategory: selectedCategory!)
        }
        
        let price: Float = ((products![indexPath.row] as NSObject).value(forKeyPath: "price") as? Float)!
        let count: Float = ((products![indexPath.row] as NSObject).value(forKeyPath: "count") as? Float)!
        let measure: Int = Int(((products![indexPath.row] as NSObject).value(forKeyPath: "measure") as? Int16)!)
        
        var measureTail: String!
        switch measure {
        case Utilities.measures.items.rawValue:
            do {
                measureTail = " шт."
            }
        case Utilities.measures.kilos.rawValue:
            do {
                measureTail = " кг."
            }
        case Utilities.measures.liters.rawValue:
            do {
                measureTail = " л."
            }
        default: break
        }
        
        self.productNameLabel.text = products![indexPath.row].value(forKeyPath: "name") as? String
        self.productDescLabel.text = products![indexPath.row].value(forKeyPath: "desc") as? String
        self.productPriceLabel.text = price.description + " руб."
        self.productCountLabel.text = count.description + measureTail
        self.productBarcodeLabel.text = products![indexPath.row].value(forKeyPath: "code") as? String
    }

}
