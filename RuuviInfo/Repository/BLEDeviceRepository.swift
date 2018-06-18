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
import RuuviTag_iOS

protocol BLEDeviceRepositoryProtocol {
    
    init(deviceAdvertisementReceived: @escaping (RuuviTag) -> ())
    
    func startScanningForDevices()
    func stopScanningForDevices()
    
    func connectToDevice(UUID: String)
    func disconnectDevice(UUID: String)
    
}

class BLEDeviceRepository: NSObject, BLEDeviceRepositoryProtocol {
    
    let dataKey = "kCBAdvDataManufacturerData"
    let centralManagerQueue = DispatchQueue(label: "CB Central manager dispatch queue")
    let deviceAdvertisementReceived: (RuuviTag) -> ()
    var ruuviTags: RTRuuviTagsProtocol?
    
    required init(deviceAdvertisementReceived: @escaping (RuuviTag) -> ()) {
        self.deviceAdvertisementReceived = deviceAdvertisementReceived
        super.init()
        ruuviTags = RTRuuviTags.listen() { tagInfo in
            let managedContext = PersistenceContainer.shared.persistentContainer.viewContext
            let tag = self.fetchTagOrCreate(with: tagInfo, in: managedContext)
            self.createObservation(from: tagInfo, for: tag, in: managedContext)
            do {
                try managedContext.save()
                deviceAdvertisementReceived(tag)
                NotificationCenter.default.post(name: Notification.Name.ruuviData, object: nil)
            } catch let error as NSError {
                print("Could not save tag \(error), \(error.userInfo)")
            }
        }
        
    }
    
    func startScanningForDevices() {}
    func stopScanningForDevices() {}
    
    func connectToDevice(UUID: String) {}
    func disconnectDevice(UUID: String) {}
    
    func fetchTagOrCreate(with data: RTTagInfo, in context: NSManagedObjectContext) -> RuuviTag {
        let tagsFetch = NSFetchRequest<RuuviTag>(entityName: "RuuviTag")
        tagsFetch.predicate = NSPredicate(format: "%K == %@", "uuid", data.uuid as CVarArg)
        do {
            let fetchedTags = try context.fetch(tagsFetch) as [RuuviTag]
            guard let tag = fetchedTags.first else {
                let tag = NSEntityDescription.insertNewObject(forEntityName: "RuuviTag", into: context) as! RuuviTag
                tag.uuid = data.uuid
                tag.name = data.name ?? "Unknown"
                tag.customName = ""
                return tag
            }
            return tag
        }
        catch {
            fatalError("Failed to fetch tags \(error)")
        }
    }
    
    func createObservation(from data: RTTagInfo, for tag: RuuviTag, in context: NSManagedObjectContext) {
        let value = NSEntityDescription.insertNewObject(forEntityName: "SensorValues", into: context) as! SensorValues
        inject(rtSensorValues: data.sensorValues, to: value)
        value.timestamp = Date()
        if tag.sensorValues?.count == 0 {
            tag.sensorValues = NSSet(object: value)
        }
        else {
            tag.sensorValues = tag.sensorValues?.adding(value) as? NSSet
        }
        
    }
    
    func inject(rtSensorValues: RTSensorValues, to values: SensorValues) {
        values.temperature = rtSensorValues.temperature
        values.humidity = rtSensorValues.humidity
        values.pressure = rtSensorValues.pressure
        values.accelerationX = Int16(rtSensorValues.accelerationX)
        values.accelerationY = Int16(rtSensorValues.accelerationY)
        values.accelerationZ = Int16(rtSensorValues.accelerationZ)
        values.voltage = Int16(rtSensorValues.voltage)
    }
}
