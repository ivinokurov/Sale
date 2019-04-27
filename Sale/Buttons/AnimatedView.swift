//
//  AnimatedView.swift
//  Sale
//


import UIKit

class AnimatedView: UIView {
    
    func pulseView(delay: TimeInterval) {
        
        self.backgroundColor = Utilities.accentColor
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: delay,  options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.curveEaseInOut.rawValue | UIView.AnimationOptions.repeat.rawValue | UIView.AnimationOptions.autoreverse.rawValue), animations: {
                self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { (finished) in
                UIView.animate(withDuration: 0.5, delay: delay,  options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.curveEaseInOut.rawValue | UIView.AnimationOptions.repeat.rawValue | UIView.AnimationOptions.autoreverse.rawValue), animations: {
                    self.transform = CGAffineTransform.identity
                })
            }
        }
    }
 
}
