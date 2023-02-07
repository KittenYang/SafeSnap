//
//  CoreDataProtocol.swift
//  family-dao
//
//  Created by KittenYang on 10/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import CoreData

protocol CoreDataProtocol {
	var persistentContainer: NSPersistentContainer { get }
	func saveContext()
	func rollback()
}

extension CoreDataProtocol {
	var viewContext: NSManagedObjectContext { persistentContainer.viewContext }
}
