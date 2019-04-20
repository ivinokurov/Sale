//
//  BluetoothDevicesInterconnection.swift
//  Sale
//


import UIKit

class BluetoothDevicesInterconnection: DTDeviceDelegate {
    
    let lib = DTDevices.sharedDevice() as! DTDevices
    var btDevices = [String]()
    
    init() {
        lib.addDelegate(self)
        lib.connect()
    }
    
    func bluetoothDeviceDiscovered(_ address: String!, name: String!) {
        self.btDevices.append(name)
        self.btDevices.append(address)
    }
    
    func bluetoothDiscoverComplete(_ success: Bool) {
        if success {
        }
    }
    
    func findBluetoothDevices() {
        DispatchQueue.global().async {
            do {
                try self.lib.btDiscoverSupportedDevices(inBackground: 8, maxTime: 10.0, filter: BLUETOOTH_FILTER.ALL)
            } catch let error as NSError {
     //           Utilities.showSimpleAlert(controllerToShowFor: Utilities.mainController!, messageToShow: error.localizedDescription)
            }
        }
    }
    
    func isConnected(address: String) -> Bool {
        for device in lib.btConnectedDevices {
            if device == address {
                return true
            }
        }
        return false
    }
    
    func connectToDevice(deviceAddress address: String) {
        DispatchQueue.global().async {
            if self.isConnected(address: address) {
                do {
                    try self.lib.btDisconnect(address)
                } catch _ {
                }
            } else {
                do {
                    try self.lib.btConnectSupportedDevice(address, pin: "0000")
                } catch let error as NSError {
     //               Utilities.showSimpleAlert(controllerToShowFor: Utilities.mainController!, messageToShow: error.localizedDescription)
                }
            }
        }
    }

}
