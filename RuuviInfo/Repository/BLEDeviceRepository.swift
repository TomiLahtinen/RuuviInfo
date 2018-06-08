//
//  BLEDeviceRepository.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 01/06/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit
import CoreData

protocol BLEDeviceRepositoryProtocol {
    
    init(deviceAdvertisementReceived: @escaping (RuuviTag) -> ())
    
    func startScanningForDevices()
    func stopScanningForDevices()
    
    func connectToDevice(UUID: String)
    func disconnectDevice(UUID: String)
    
}

class BLEDeviceRepository: NSObject, BLEDeviceRepositoryProtocol {
    
    fileprivate lazy var appDelegate: AppDelegate = {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("No AppDelegate available???")
        }
        return delegate
    }()
    
    let dataKey = "kCBAdvDataManufacturerData"
    let centralManagerQueue = DispatchQueue(label: "CB Central manager dispatch queue")
    let deviceAdvertisementReceived: (RuuviTag) -> ()
    let centralManager: CBCentralManager!
    
    required init(deviceAdvertisementReceived: @escaping (RuuviTag) -> ()) {
        self.deviceAdvertisementReceived = deviceAdvertisementReceived
        
        let opts = [CBCentralManagerScanOptionSolicitedServiceUUIDsKey: true,
                    CBCentralManagerOptionShowPowerAlertKey: true,
                    CBCentralManagerScanOptionAllowDuplicatesKey: true]
        centralManager = CBCentralManager(delegate: nil, queue: centralManagerQueue, options: opts)
        super.init()
        centralManager.delegate = self
    }
    
    func startScanningForDevices() {}
    func stopScanningForDevices() {}
    
    func connectToDevice(UUID: String) {}
    func disconnectDevice(UUID: String) {}
    
    func fetchTagOrCreate(for peripheral: CBPeripheral, with data: DataFormat3, in context: NSManagedObjectContext) -> RuuviTag {
        let tagsFetch = NSFetchRequest<RuuviTag>(entityName: "RuuviTag")
        tagsFetch.predicate = NSPredicate(format: "%K == %@", "uuid", peripheral.identifier as CVarArg)
        do {
            let fetchedTags = try context.fetch(tagsFetch) as [RuuviTag]
            guard let tag = fetchedTags.first else {
                let tag = NSEntityDescription.insertNewObject(forEntityName: "RuuviTag", into: context) as! RuuviTag
                tag.uuid = peripheral.identifier
                tag.name = peripheral.name ?? "Unknown"
                tag.customName = ""
                return tag
            }
            return tag
        }
        catch {
            fatalError("Failed to fetch tags \(error)")
        }
    }
    
    func createObservation(from data: DataFormat3, for tag: RuuviTag, in context: NSManagedObjectContext) {
        let value = NSEntityDescription.insertNewObject(forEntityName: "SensorValues", into: context) as! SensorValues
        value.insert(data: data)
        value.timestamp = Date()
        if tag.sensorValues?.count == 0 {
            tag.sensorValues = NSSet(object: value)
        }
        else {
            tag.sensorValues = tag.sensorValues?.adding(value) as! NSSet
        }
        
    }
}

extension BLEDeviceRepository: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            debugPrint("Powered off")
        default:
            debugPrint("Oh never mind", central.state.rawValue)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey],
           let rawData = DataFormat3.decode(data: manufacturerData as? Data){
            debugPrint("RuuviTag data received")
          
            let managedContext = appDelegate.persistentContainer.viewContext
            // Has we tag in almighty CoreData
            let tag = fetchTagOrCreate(for: peripheral, with: rawData, in: managedContext)
            createObservation(from: rawData, for: tag, in: managedContext)
            do {
                try managedContext.save()
                deviceAdvertisementReceived(tag)
                NotificationCenter.default.post(name: Notification.Name.ruuviData, object: nil)
            } catch let error as NSError {
                print("Could not save tag \(error), \(error.userInfo)")
            }
        }
    }
}

extension BLEDeviceRepository: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach { service in
            debugPrint("Service", service)
        }
    }
}
