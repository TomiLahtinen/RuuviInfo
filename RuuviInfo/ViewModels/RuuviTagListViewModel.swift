//
//  File.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 31/05/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation

protocol RuuviTagListViewModelProtocol {
    init(didUpdateTags: @escaping ([RuuviTag]) -> (),
         didUpdateTag: @escaping (RuuviTag) -> ())
    
    func startScanningTags()
    func stopScanningTags()
    
}


class RuuviTagListViewModel: RuuviTagListViewModelProtocol {
    
    let didUpdateTags: ([RuuviTag]) -> ()
    let didUpdateTag: (RuuviTag) -> ()
    
    fileprivate lazy var repository: BLEDeviceRepository = {
        return BLEDeviceRepository(deviceAdvertisementReceived: { tag in
            debugPrint("Tag at model", tag)
        })
    }()
    
    required init(didUpdateTags: @escaping ([RuuviTag]) -> (),
                  didUpdateTag: @escaping (RuuviTag) -> ()) {
        
        self.didUpdateTags = didUpdateTags
        self.didUpdateTag = didUpdateTag
    }
    
    func startScanningTags() {
        // TODO
    }
    
    func stopScanningTags() {
        // TODO
    }
    
    
}
