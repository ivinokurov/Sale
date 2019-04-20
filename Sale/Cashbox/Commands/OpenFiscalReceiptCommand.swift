//
//  OpenFiscalReceiptCommand.swift
//  Sale
//


import UIKit

class OpenFiscalReceiptCommand: NSObject {
    var abstarctCommand = FPAbstractCommand()
    
    init(operatorNumber opCode: String, operatorPassword opPwd: String, pointOfSaleNumber tillNmb: String, operationType type: String, buyerInfo buer: String? = nil) {
        
        self.abstarctCommand.error = false
        
        self.abstarctCommand.commandCode = 0x30        
        self.abstarctCommand.commandParams.removeAll()
        self.abstarctCommand.commandParams.append(opCode)
        self.abstarctCommand.commandParams.append(opPwd)
        self.abstarctCommand.commandParams.append(tillNmb)
        self.abstarctCommand.commandParams.append(type)
        self.abstarctCommand.commandParams.append(buer)
    }
    
    func writeCommand() {
        self.abstarctCommand.writeCommand()
    }
}
