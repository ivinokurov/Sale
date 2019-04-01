//
//  LogoutButton.swift
//  Sale
//


import UIKit

class LogoutButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            imageView?.image = isHighlighted ? UIImage(named: "LogoutFilled") : UIImage(named: "Logout")
        }
    }
}
