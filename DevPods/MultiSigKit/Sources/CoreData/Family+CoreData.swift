//
//  Family+CoreData.swift
//  family-dao
//
//  Created by KittenYang on 10/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import CoreData


public extension Family {

//	var isSelected: Bool { selection != nil }

	var hasAddress: Bool { address.isEmpty == false }

//	var isReadOnly: Bool {
//		guard let owners = ownersInfo else { return false }
//		if let keys = try? KeyInfo.keys(addresses: owners.map(\.address)), !keys.isEmpty {
//			return false
//		} else {
//			return true
//		}
//	}
	
	var toViewModel: FamilyViewModel? {
		.init(managedObject: self)
	}

	static var count: Int {
		let context = CoreDataStack.shared.viewContext
		return (try? context.count(for: Family.fetchRequest().all())) ?? 0
	}


	static var all: [Family] {
		let context = CoreDataStack.shared.viewContext
		return (try? context.fetch(Family.fetchRequest().all())) ?? []
	}

	@MainActor
	static func by(address: String, chainId: String) async -> Family? {
		dispatchPrecondition(condition: .onQueue(.main))
		let context = CoreDataStack.shared.viewContext
		let fr = Family.fetchRequest().by(address: address, chainId: chainId)
		return try? context.fetch(fr).first
	}

//	static func updateCachedNames() {
//		guard let safes = try? Family.getAll() else { return }
//
//		cachedNames = safes.reduce(into: [String: String]()) { names, safe in
//			let chainId = safe.chain != nil ? safe.chain!.id! : "1"
//			let key = "\(safe.displayAddress):\(chainId)"
//			names[key] = safe.name!
//		}
//	}

//	static func cachedName(by address: AddressString, chainId: String) -> String? {
//		let key = "\(address.description):\(chainId)"
//		return cachedNames[key]
//	}
//
//	static func cachedName(by address: String, chainId: String) -> String? {
//		let key = "\(address):\(chainId)"
//		return cachedNames[key]
//	}

	override func awakeFromInsert() {
		super.awakeFromInsert()
		additionDate = Date()
	}

	@MainActor func select() async {
		let selection = await Selection.current()
		selection.family = self
		CoreDataStack.shared.saveContext()
		NotificationCenter.default.post(name: .selectedSafeChanged, object: nil)
	}

	static func getSelected() throws -> Family? {
		do {
			let context = CoreDataStack.shared.viewContext
			let fr = Family.fetchRequest().selected()
			let safe = try context.fetch(fr).first
			return safe
		} catch {
			throw GSError.DatabaseError(reason: error.localizedDescription)
		}
	}

	static func getAll() throws -> [Family] {
		do {
			let context = CoreDataStack.shared.viewContext
			let fr = Family.fetchRequest().all()
			let safes = try context.fetch(fr)
			return safes
		} catch {
			throw GSError.DatabaseError(reason: error.localizedDescription)
		}
	}

	static func exists(_ address: String, chainId: String) async -> Bool {
		await by(address: address, chainId: chainId) != nil
	}

	@discardableResult
	@MainActor
	static func create(address: String,
					   name: String,
					   chain: Chain.ChainID,
					   owners: [String]? = nil,
					   nonce: Int64? = nil,
					   threshold: Int64? = nil,
					   selected: Bool = true) async -> Family {
		dispatchPrecondition(condition: .onQueue(.main))
		if let old = await Family.by(address: address, chainId: chain.rawValue) {
			await old.select()
			return old
		}
		
		let context = CoreDataStack.shared.viewContext

		let safe = Family(context: context)
		safe.address = address
		safe.name = name
		safe.chainID = chain.rawValue
		safe.owners = owners ?? []
		safe.nonce = nonce ?? 0
		safe.threshold = threshold ?? 0
		if selected {
			/// 新建 family 通过直接 select 就切换当前家庭了
			await safe.select()
		}
		CoreDataStack.shared.saveContext()

		return safe
	}

	@MainActor
	func update(name: String) async {
		dispatchPrecondition(condition: .onQueue(.main))
		
		self.name = name

		CoreDataStack.shared.saveContext()

		NotificationCenter.default.post(name: .selectedSafeUpdated, object: self)
	}
	
	/*
	 @NSManaged public var additionDate: Date?
	 @NSManaged public var name: String?
	 @NSManaged public var token: FamilyToken?
	 @NSManaged public var chainID: String?
	 @NSManaged public var address: String?
	 @NSManaged public var owners: [String]?
 //	@NSManaged public var nonce: Int?
 //	@NSManaged public var threshold: Int?
	 @NSManaged public var ownerTokenBalance: OwnersTokenBalance?
	 */
//	func update(name: String?, owners: [String]?, nonce: Int64?, threshold: Int64?, ownerTokenBalance: OwnersTokenBalance? = nil) {
//		dispatchPrecondition(condition: .onQueue(.main))
//
//		self.name = name ?? ""
//		self.owners = owners ?? []
//		self.nonce = nonce ?? 0
//		self.threshold = threshold ?? 0
//		if let ownerTokenBalance {
//			self.ownerTokenBalance = ownerTokenBalance
//		}
//
//		CoreDataStack.shared.saveContext()
//
//		NotificationCenter.default.post(name: .selectedSafeUpdated, object: self)
//	}
//	
//	func update(ownerTokenBalance: OwnersTokenBalance?) {
//		dispatchPrecondition(condition: .onQueue(.main))
//		if let ownerTokenBalance {
//			self.ownerTokenBalance = ownerTokenBalance
//			CoreDataStack.shared.saveContext()
//			NotificationCenter.default.post(name: .selectedSafeUpdated, object: self)
//		}
//	}
	
	@MainActor
	func update(token: FamilyToken?) async {
		dispatchPrecondition(condition: .onQueue(.main))
		if let token {
			self.token = token
			CoreDataStack.shared.saveContext()
			NotificationCenter.default.post(name: .selectedSafeUpdated, object: self)
		}
	}
	
	/// familydao-0x786252.... (没有 .eth 后缀)
	@MainActor
	func update(spaceDomain: String?) async {
		dispatchPrecondition(condition: .onQueue(.main))
		self.spaceDomain = spaceDomain
		CoreDataStack.shared.saveContext()
		NotificationCenter.default.post(name: .selectedSafeUpdated, object: self)
	}

	@MainActor
	static func select(address: String, chainId: String) async {
		dispatchPrecondition(condition: .onQueue(.main))
		let context = CoreDataStack.shared.viewContext
		let fr = Family.fetchRequest().by(address: address, chainId: chainId)
		guard let safe = try? context.fetch(fr).first else { return }
		await safe.select()
	}
	
	static func remove(safe: Family) async {
		let deletedSafeAddress = safe.address
		let context = CoreDataStack.shared.viewContext

		let chainId = safe.chainID


//		if let deletedSafeAddress = deletedSafeAddress {
//			// delete related EthTransaction's
//			let txs = CDEthTransaction.by(safeAddresses: [deletedSafeAddress], chainId: chainId)
//			for tx in txs {
//				context.delete(tx)
//			}
//
//			// delete stored SafeCreationCall's
//			let calls = SafeCreationCall.by(safe: safe)
//			for call in calls {
//				context.delete(call)
//			}
//		}

		context.delete(safe)

		if let safe = try? Family.getAll().first {
			await safe.select()
		}

		CoreDataStack.shared.saveContext()

		NotificationCenter.default.post(name: .selectedSafeChanged, object: nil)

		// TODO: 移除 push 通知
//		if let addressString = deletedSafeAddress, let address = Address(addressString) {
//			App.shared.notificationHandler.safeRemoved(address: address, chainId: chainId)
//		}

	}

	static func removeAll() async {
		for safe in all {
			await remove(safe: safe)
		}
		
		NotificationCenter.default.post(name: .selectedSafeChanged, object: nil)
	}
}


public extension Family {
	//TODO: core data viewModel 中间层
//	func update(from info: SafeInfoRequest.ResponseType) {
//		threshold = info.threshold.value
//		ownersInfo = info.owners.map { $0.addressInfo }
//		implementationInfo = info.implementation.addressInfo
//		implementationVersionState = ImplementationVersionState(info.implementationVersionState)
//		nonce = info.nonce.value
//		modulesInfo = info.modules?.map { $0.addressInfo }
//		fallbackHandlerInfo = info.fallbackHandler?.addressInfo
//		guardInfo = info.guard?.addressInfo
//		version = info.version
//		DispatchQueue.main.async {
//			self.contractVersion = info.version
//			App.shared.coreDataStack.saveContext()
//			NotificationCenter.default.post(name: .selectedSafeUpdated, object: self)
//		}
//	}
}

public extension NSFetchRequest where ResultType == Family {
	// 查询当前所有 family
	func all() -> Self {
		sortDescriptors = [NSSortDescriptor(keyPath: \Family.additionDate, ascending: true)]
		return self
	}

	// 查询当前选中的 family
	func selected() -> Self {
		sortDescriptors = []
		predicate = NSPredicate(format: "selection != nil")
		fetchLimit = 1
		return self
	}
	
	// 查询指定地址的 family
	func by(address: String, chainId: String) -> Self {
		sortDescriptors = []
		predicate = NSPredicate(format: "address == %@ AND chainID == %@", address, chainId)
		fetchLimit = 1
		return self
	}
}


