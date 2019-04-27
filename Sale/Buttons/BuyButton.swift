//
//  BuyButton.swift
//  Sale
//


import UIKit

class BuyButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            imageView?.image = isHighlighted ? UIImage(named: "BuyFilled") : UIImage(named: "Buy")
        }
    }
}
