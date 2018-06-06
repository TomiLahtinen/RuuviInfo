//
//  TagRepository.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 05/06/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol TagRepositoryProtocol {
    func fetchTag(with uuid: UUID) -> RuuviTag?
}

class TagRepository: TagRepositoryProtocol {

    let managedContext: NSManagedObjectContext!
    
    init() {
        managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func fetchTag(with uuid: UUID) -> RuuviTag? {
        do {
            let tagsFetch = NSFetchRequest<RuuviTag>(entityName: "RuuviTag")
            tagsFetch.predicate = NSPredicate(format: "%K == %@", "uuid", uuid as CVarArg)
            let fetchedTags = try managedContext.fetch(tagsFetch) as [RuuviTag]
            return fetchedTags.first
        }
        catch {
            fatalError("Failed to fetch tags \(error)")
        }
    }
    
    func save(tag uuid: UUID, name: String) {
        guard let tag = fetchTag(with: uuid) else {
            fatalError("No such tag \(uuid.uuidString)")
        }
        tag.customName = name
        try? managedContext.save()
    }
}
