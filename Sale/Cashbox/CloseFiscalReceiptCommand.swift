//
//  CloseFiscalReceiptCommand.swift
//  Sale
//


import UIKit

class CloseFiscalReceiptCommand: NSObject {
    var abstarctCommand = FPAbstractCommand()
    
    override init() {
        
        self.abstarctCommand.error = false
        
        self.abstarctCommand.commandCode = 0x38

    }
    
    func writeCommand() {
        let name = SettingsDBRules.getTCPDeviceName()
        let port = 3999
        
        self.abstarctCommand.writeCommand(hostName: name!, hostPort: port)
    }
}
