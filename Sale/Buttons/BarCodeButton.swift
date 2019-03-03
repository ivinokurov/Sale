//
//  BarCodeButton.swift
//  Sale
//


import UIKit

class BarCodeButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            imageView?.image = isHighlighted ? UIImage(named: "BarcodeFilled") : UIImage(named: "Barcode")
        }
    }
}
