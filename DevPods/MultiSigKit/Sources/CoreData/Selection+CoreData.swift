//
//  Selection+CoreData.swift
//  family-dao
//
//  Created by KittenYang on 10/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import CoreData

extension Selection {

	@MainActor
	class func selection() async -> Selection? {
		dispatchPrecondition(condition: .onQueue(.main))
		do {
			let fr = Selection.fetchRequest().all()
			let result = try CoreDataStack.shared.viewContext.fetch(fr)
			return result.first
		} catch {
			fatalError("Error fetching: \(error)")
		}
	}

	@MainActor
	class func current() async -> Selection {
		dispatchPrecondition(condition: .onQueue(.main))
		return await selection() ?? Selection(context: CoreDataStack.shared.viewContext)
	}

}

extension NSFetchRequest where ResultType == Selection {

	func all() -> Self {
		sortDescriptors = []
		return self
	}

}
