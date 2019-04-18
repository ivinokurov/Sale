//
//  DatecsFiscalPrinterCommand.swift
//  Sale
//


import UIKit

class FPAbstractCommand: UIViewController, StreamDelegate {
    
    var commandCode: UInt32 = 0
    var SEQ: UInt8 = 0x20
    let PREAMBLE: UInt8 = 0x01
    let POSTAMBLE: UInt8 = 0x05
    let STATUSSEP: UInt8 = 0x04
    let TERMINATOR: UInt8 = 0x03
    let SEPARATOR: String = "\t"
    var commandParams = Array<String?>()
   
    var inputStream: InputStream? = nil
    var outputStream: OutputStream? = nil
    
    var error: Bool = false
    
    func buildCommand() -> [UInt8] {
        let parametersLen = self.getParametersLenInBytes()
        var buf = [UInt8].init(repeating: 0, count: parametersLen + 16)
        var offset = 0
        
        buf[offset] = self.PREAMBLE
    
        offset += 1
        let len = self.toKKTByteSequence(value: UInt32(9 + parametersLen + 1 + 0x20))
        for i in offset..<5 {
            buf[i] = len[i - offset]
        }
        
        offset += 4
        buf[offset] = self.getSequence()
        
        offset += 1
        let code = self.toKKTByteSequence(value: self.commandCode)
        for i in offset..<10 {
            buf[i] = code[i - offset]
        }

        offset += 4
        let parameters = self.getCP866Bytes(utf8Bytes: self.getParametersUtf8String())
        for i in offset..<offset + parametersLen {
            let index = parameters.index(parameters.startIndex, offsetBy: i)
            let bytes: [UInt8] = [UInt8](parameters)
            
            buf[i] = bytes[index - offset]
        }
        
        offset += parametersLen
        buf[offset] = self.POSTAMBLE

        offset += 1
        let checksum = self.calcChecksum(data: buf)
        for i in offset..<offset + 4 {
            buf[i] = checksum[i - offset]
        }
        
        offset += 4
        buf[offset] = self.TERMINATOR
        return buf
    }
    
    func getParametersUtf8String() -> [UInt8] {
        var ret: String = ""
        for parameter in self.commandParams {
            if parameter != nil {
                ret += parameter!
            }
            ret += SEPARATOR
        }
        if ret.count == 0 {
            ret += SEPARATOR
        }
        return ret.utf8.filter({ $0 == $0 })
    }
    
    func getCP866Bytes(utf8Bytes: [UInt8]) -> [UInt8] {
        var ret = [UInt8]()
        
        var index = 0

        for _ in 0..<utf8Bytes.count {
            if index >= utf8Bytes.count {
                break
            }
            if utf8Bytes[index] < 208 {
                ret.append(utf8Bytes[index])
                index += 1
                continue
            } else {
                if utf8Bytes[index] == 208 {
                    ret.append(utf8Bytes[index + 1] - 16)
                }
                if utf8Bytes[index] == 209 {
                    ret.append(utf8Bytes[index + 1] + 96)
                }
                index += 2
            }
        }
        return ret
    }
    
    func toKKTByteSequence(value: UInt32) -> [UInt8] {
        var ret = [UInt8].init(repeating: 0x30, count: 4)
        
        ret[0] += UInt8((value & 0x0f000) >> 12)
        ret[1] += UInt8((value & 0x00f00) >> 8)
        ret[2] += UInt8((value & 0x000f0) >> 4)
        ret[3] += UInt8(value & 0x0000f)
        
        return ret
    }
    
    func calcChecksum(data: [UInt8]) -> [UInt8]{
        var checksum: UInt32 = 0
        
        for i in 1..<data.count - 4 {
            checksum += UInt32(data[i])
        }
        
        return toKKTByteSequence(value: checksum)
    }
    
    func getSequence() -> UInt8 {
        if SEQ >= 0 && SEQ < 0x20 {
            SEQ = 0x20
        } else {
            SEQ += 1
        }
        return SEQ
    }
    
    func getParametersLenInBytes() -> Int {
        var len = 0
        
        for parameter in self.commandParams {
            if parameter != nil {
                len += parameter!.count + 1
            } else {
                len += 1
            }
        }
        return len
    }
    
    func getOutputStream (hostName name: String, hostPort port: Int) {
        Stream.getStreamsToHost(withName: name, port: port, inputStream: &self.inputStream, outputStream: &self.outputStream)
        if self.outputStream != nil {
            self.outputStream?.schedule(in: .main, forMode: .default)
            self.outputStream?.delegate = self
            self.outputStream!.open()
        }
    }
    
    func writeCommand(hostName name: String, hostPort port: Int) {
        self.getOutputStream(hostName: name, hostPort: port)
        self.writeToStream(data: Data(bytes: self.buildCommand()), outStream: self.outputStream!)
        if self.outputStream != nil {
            self.outputStream!.close()
        }
    }
    
    func writeToStream(data: Data, outStream: OutputStream) {
        let _ = data.withUnsafeBytes { (unsafePointer: UnsafePointer<UInt8>) in
            _ = outStream.write(unsafePointer, maxLength: data.count)
        }
    }
    
    func stream(_ aStream: Stream, handle c: Stream.Event) {
        switch c {
        case Stream.Event.errorOccurred:
            self.error = true
            Utilities.showErrorAlertView(alertTitle: "ПЕЧАТЬ", alertMessage: "Ошибка печати чека!")
        default:
            break
        }
    }

}
