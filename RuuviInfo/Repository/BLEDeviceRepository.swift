//
//  BLEDeviceRepository.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 01/06/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEDeviceRepositoryProtocol {
    
    init(deviceAdvertisementReceived: @escaping (RuuviTag) -> ())
    
    func startScanningForDevices()
    func stopScanningForDevices()
    
    func connectToDevice(UUID: String)
    func disconnectDevice(UUID: String)
    
}

class BLEDeviceRepository: NSObject, BLEDeviceRepositoryProtocol {
    
    let dataKey = "kCBAdvDataManufacturerData"
    
    let deviceAdvertisementReceived: (RuuviTag) -> ()
    let centralManager: CBCentralManager!
    
    required init(deviceAdvertisementReceived: @escaping (RuuviTag) -> ()) {
        self.deviceAdvertisementReceived = deviceAdvertisementReceived
        
        let opts = [CBCentralManagerOptionShowPowerAlertKey: true]
        centralManager = CBCentralManager(delegate: nil, queue: DispatchQueue.main, options: opts)
        
        super.init()
        
        centralManager.delegate = self
    }
    
    func startScanningForDevices() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanningForDevices() {
        
    }
    
    func connectToDevice(UUID: String) {
        
    }
    
    func disconnectDevice(UUID: String) {
        
    }
}

extension BLEDeviceRepository: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            debugPrint("Powered on")
        case .poweredOff:
            debugPrint("Powered off")
        default:
            debugPrint("Oh never mind", central.state)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        debugPrint(peripheral.name)
        debugPrint("Manufacturer", advertisementData[dataKey])
    }
}
