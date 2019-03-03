//
//  PurchaseTableViewCell.swift
//  Sale
//


import UIKit

class PurchaseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var purchaseImageView: UIImageView!
    @IBOutlet weak var purchaseNameLabel: UILabel!
    @IBOutlet weak var purchasePriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
