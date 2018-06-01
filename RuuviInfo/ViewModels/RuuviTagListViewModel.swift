//
//  File.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 31/05/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation

protocol RuuviTagListViewModelProtocol {
    init(didUpdateTags: @escaping ([RuuviTag]) -> ())
    func startScanningTags()
    func stopScanningTags()
    
}


class RuuviTagListViewModel: RuuviTagListViewModelProtocol {
    
    let didUpdateTags: ([RuuviTag]) -> ()
    
    required init(didUpdateTags: @escaping ([RuuviTag]) -> ()) {
        self.didUpdateTags = didUpdateTags
    }
    
    func startScanningTags() {
        <#code#>
    }
    
    func stopScanningTags() {
        <#code#>
    }
    
    
}
