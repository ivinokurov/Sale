//
//  PaymentCommand.swift
//  Sale
//


import UIKit

class PaymentCommand {
    var abstarctCommand = FPAbstractCommand()
    
    init(paidMode mode: String, paidAmount amount: String) {
        
        self.abstarctCommand.error = false
        
        self.abstarctCommand.commandCode = 0x35
        self.abstarctCommand.commandParams.removeAll()
        self.abstarctCommand.commandParams.append(mode)
        self.abstarctCommand.commandParams.append(amount)
    }
    
    func writeCommand() {
        let name = SettingsDBRules.getTCPDeviceName()
        let port = 3999
        
        self.abstarctCommand.writeCommand(hostName: name!, hostPort: port)
    }
}
