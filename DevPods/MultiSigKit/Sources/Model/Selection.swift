//
//  Selection.swift
//  MultiSigKit
//
//  Created by KittenYang on 10/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import CoreData

@objc(Selection)
public class Selection: NSManagedObject {

}

public extension Selection {

	@nonobjc class func fetchRequest() -> NSFetchRequest<Selection> {
		return NSFetchRequest<Selection>(entityName: "Selection")
	}

	@NSManaged var family: Family?

}

extension Selection : Identifiable {

}


