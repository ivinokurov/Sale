//
//  PrintTextCommand.swift
//  Sale
//


import UIKit

class PrintTextCommand: NSObject {
    var abstarctCommand = FPAbstractCommand()
    
    init(textToPrint text: String, textBold bold: String? = nil, textItalic italic: String? = nil, textDoubleHeight doubleH: String? = nil, textUnderline underline: String? = nil, textAlignment alignment: String? = nil, textCondensed condensed: String? = nil) {
        
        self.abstarctCommand.error = false
        
        self.abstarctCommand.commandCode = 0x2A
        self.abstarctCommand.commandParams.removeAll()
        self.abstarctCommand.commandParams.append(text)
        self.abstarctCommand.commandParams.append(bold)
        self.abstarctCommand.commandParams.append(italic)
        self.abstarctCommand.commandParams.append(doubleH)
        self.abstarctCommand.commandParams.append(underline)
        self.abstarctCommand.commandParams.append(alignment)
        self.abstarctCommand.commandParams.append(condensed)
    }
    
    func writeCommand() {
        self.abstarctCommand.writeCommand()
    }
}
