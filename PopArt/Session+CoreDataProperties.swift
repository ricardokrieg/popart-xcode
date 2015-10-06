//
//  Session+CoreDataProperties.swift
//  PopsArt
//
//  Created by Ricardo Franco on 05/10/15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Session {

    @NSManaged var session: String?
    @NSManaged var email: String?
    @NSManaged var name: String?
    @NSManaged var image: String?

}
