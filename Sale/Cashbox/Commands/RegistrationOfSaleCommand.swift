//
//  RegistrationOfSaleCommand.swift
//  Sale
//


import UIKit

class RegistrationOfSaleCommand: NSObject {
    var abstarctCommand = FPAbstractCommand()
    
    init(productName pluName: String, taxType taxGr: String, productPrice price: String, productQuantity quantity: String? = nil, discountType dType: String? = nil, discountValue dValue: String? = nil, department dept: String) {
        
        self.abstarctCommand.error = false
        
        self.abstarctCommand.commandCode = 0x31
        self.abstarctCommand.commandParams.removeAll()
        self.abstarctCommand.commandParams.append(pluName)
        self.abstarctCommand.commandParams.append(taxGr)
        self.abstarctCommand.commandParams.append(price)
        self.abstarctCommand.commandParams.append(quantity)
        self.abstarctCommand.commandParams.append(dType)
        self.abstarctCommand.commandParams.append(dValue)
        self.abstarctCommand.commandParams.append(dept)
    }
    
    func writeCommand() {
        self.abstarctCommand.writeCommand()
    }
}
