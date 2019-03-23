//
//  ProductsTableViewCell.swift
//  Sale
//


import UIKit
import CoreData

class ProductsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var barcodeImageView: UIImageView!
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
        
        self.barcodeImageView.tintColor = .lightGray
        self.contentView.layer.cornerRadius = 4
        
        var products: [NSObject]?
        
        if isFiltered {
            products = ProductsDBRules.filteredProducts
        } else {
            let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: categoryName)
            products = ProductsDBRules.getAllProductsForCategory(productCategory: selectedCategory!)
        }
        
        let price: Float = ((products![indexPath.row] as NSObject).value(forKeyPath: "price") as? Float)!
        let count: Float = ((products![indexPath.row] as NSObject).value(forKeyPath: "count") as? Float)!
        let measure: Int = Int(((products![indexPath.row] as NSObject).value(forKeyPath: "measure") as? Int16)!)
        
        let productDesc = products![indexPath.row].value(forKeyPath: "desc") as? String
        
        self.productNameLabel.text = products![indexPath.row].value(forKeyPath: "name") as? String
        self.productDescLabel.text = productDesc == "" ? "Без описания" : productDesc
        self.productPriceLabel.text = price.description + " руб."
        self.productCountLabel.text = count.description + ProductsDBRules.getProductMeasure(product: products![indexPath.row] as! NSManagedObject )
        self.productBarcodeLabel.text = products![indexPath.row].value(forKeyPath: "code") as? String
    }

}
