//
//  FamilyToken.swift
//  MultiSigKit
//
//  Created by KittenYang on 10/4/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import CoreData
import web3swift

extension FamilyToken {
	public var tokenAddress: EthereumAddress? {
		get {
			if let address {
				return EthereumAddress(address)
			}
			return nil
		}
		set {
			self.address = newValue?.address
		}
	}
}

//public class FamilyToken: NSManagedObject, Identifiable {
//	@NSManaged public var address: String?
//	@NSManaged public var name: String?
//	@NSManaged public var symbol: String?
//	public var decimals: Int?
//}

extension FamilyToken {
//	@nonobjc public class func fetchRequest() -> NSFetchRequest<FamilyToken> {
//		return NSFetchRequest<FamilyToken>(entityName: "FamilyToken")
//	}
	
//	@discardableResult
	@MainActor
	static func create(address: String, name: String, symbol: String, decimals: Int64, totalSupply: String?) async -> FamilyToken {
		dispatchPrecondition(condition: .onQueue(.main))
		let context = CoreDataStack.shared.viewContext

		let safe = FamilyToken(context: context)
		safe.address = address
		safe.name = name
		safe.symbol = symbol
		safe.decimals = decimals
		if let totalSupply {
			safe.totalSupply = totalSupply			
		}

		CoreDataStack.shared.saveContext()

		return safe
	}
	
	static func getSelected() throws -> FamilyToken? {
		do {
			let context = CoreDataStack.shared.viewContext
			let fr = FamilyToken.fetchRequest().selected()
			let safe = try context.fetch(fr).first
			return safe
		} catch {
			throw GSError.DatabaseError(reason: error.localizedDescription)
		}
	}
	
	/*
	 @NSManaged public var name: String?
	 @NSManaged public var symbol: String?
	 public var decimals: Int32?
	 @NSManaged public var address: String?
	 */
	@MainActor
	func update(name: String? = nil, symbol: String? = nil, decimals: Int64? = nil, totalSupply: String? = nil, address: String? = nil) async {
		dispatchPrecondition(condition: .onQueue(.main))

		if let name {
			self.name = name
		}
		if let symbol {
			self.symbol = symbol
		}
		if let decimals {
			self.decimals = decimals
		}
		if let address {
			self.address = address			
		}
		if let totalSupply {
			self.totalSupply = totalSupply
		}

		CoreDataStack.shared.saveContext()

		NotificationCenter.default.post(name: .selectedSafeTokenUpdated, object: self)
	}
	
	func select() {
		let family = try? Family.getSelected()
		family?.token = self
		CoreDataStack.shared.saveContext()
		NotificationCenter.default.post(name: .selectedSafeChanged, object: nil)
	}
	
}

extension NSFetchRequest where ResultType == FamilyToken {
	// 查询当前所有货币
	func all() -> Self {
		sortDescriptors = []
		return self
	}

	// 查询当前选中的 Token
	func selected() -> Self {
		sortDescriptors = []
		if let selectedFamilyAddress = try? Family.getSelected()?.address {
			predicate = NSPredicate(format: "family.address == %@", selectedFamilyAddress)
		}
		fetchLimit = 1
		return self
	}
	
	// 查询指定地址的 Token
	func by(address: String) -> Self {
		sortDescriptors = []
		predicate = NSPredicate(format: "address == %@", address)
		fetchLimit = 1
		return self
	}
}
