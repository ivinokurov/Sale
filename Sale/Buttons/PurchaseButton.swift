//
//  PurchaseButton.swift
//  Sale
//


import UIKit

class PurchaseButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            imageView?.image = isHighlighted ? UIImage(named: "PurchaseFilled") : UIImage(named: "Purchase")
        }
    }
}
