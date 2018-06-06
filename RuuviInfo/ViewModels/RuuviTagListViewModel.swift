//
//  File.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 31/05/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation
import UIKit

protocol RuuviTagListViewModelProtocol {
    init(didUpdateTags: @escaping ([RuuviTag]) -> (),
         didUpdateTag: @escaping (RuuviTag) -> ())
    
    func save(tag uuid: UUID, name: String)
    
    func startScanningTags()
    func stopScanningTags()
    
}


class RuuviTagListViewModel: RuuviTagListViewModelProtocol {

    let didUpdateTags: ([RuuviTag]) -> ()
    let didUpdateTag: (RuuviTag) -> ()
    
    fileprivate lazy var repository: BLEDeviceRepository = {
        return BLEDeviceRepository(deviceAdvertisementReceived: { tag in
            self.didUpdateTag(tag)
        })
    }()
    
    required init(didUpdateTags: @escaping ([RuuviTag]) -> (),
                  didUpdateTag: @escaping (RuuviTag) -> ()) {
        
        self.didUpdateTags = didUpdateTags
        self.didUpdateTag = didUpdateTag
    }
    
    func save(tag uuid: UUID, name: String) {
        // TODO
    }
    
    func startScanningTags() {
        repository.startScanningForDevices()
    }
    
    func stopScanningTags() {
        // TODO
    }
}
