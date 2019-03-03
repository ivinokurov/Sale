//
//  DeleteButton.swift
//  Sale
//


import UIKit

class DeleteButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            imageView?.image = isHighlighted ? UIImage(named: "DeleteFilled") : UIImage(named: "Delete")
        }
    }
}
