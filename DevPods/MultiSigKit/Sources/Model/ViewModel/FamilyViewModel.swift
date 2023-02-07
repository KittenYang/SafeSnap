//
//  FamilyViewModel.swift
//  MultiSigKit
//
//  Created by KittenYang on 10/5/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift

public typealias OwnersTokenBalance = [String:String]

public class FamilyViewModel: Identifiable, Equatable {
	
	public static func == (lhs: FamilyViewModel, rhs: FamilyViewModel) -> Bool {
		return lhs.address == rhs.address
	}
	
	public var id = UUID()
	
	public var additionDate: Date
	// 创建需要
	public var address: String
	public var chainID: String
	public var name: String
	// 更新需要
	public var nonce: Int64
	public var owners: [String]
	public var ownerTokenBalanceData: Data?
	public var threshold: Int64
	
//	public var selection: Selection?
	public var token: FamilyToken?
	
	// Space 空间地址
	public var spaceDomain: String?
		
	public init?(managedObject: Family?) {
		guard let managedObject else {
			return nil
		}
		self.additionDate = managedObject.additionDate
		self.address = managedObject.address
		self.chainID = managedObject.chainID
		self.name = managedObject.name
		
		self.nonce = managedObject.nonce
		self.owners = managedObject.owners
		self.ownerTokenBalanceData = managedObject.ownerTokenBalanceData
		self.threshold = managedObject.threshold
		self.token = managedObject.token
		self.spaceDomain = managedObject.spaceDomain
	}
	
	// ["0x111":"12","0x2222":"34"]
	public var ownerTokenBalance: OwnersTokenBalance? {
		get {
			if let ownerTokenBalanceData {
				return try? JSONSerialization.jsonObject(with: ownerTokenBalanceData, options: .mutableContainers) as? OwnersTokenBalance
			}
			return nil
		}
		set {
			guard let new = newValue, JSONSerialization.isValidJSONObject(new) else {
				self.ownerTokenBalanceData = nil
				return
			}
			if let data = try? JSONSerialization.data(
				withJSONObject: new,
				options: []) {
				self.ownerTokenBalanceData = data
			} else {
				self.ownerTokenBalanceData = nil
			}
		}
	}
	
	public func top5ownerTokenBalanceKeys() -> [String] {
		let result = ownerTokenBalance?.sorted(by: { d1, d2 in
			let i1 = Int(d1.value) ?? 0
			let i2 = Int(d2.value) ?? 0
			return i1 >= i2
		})
		let users = result?.compactMap({ $0.key }).prefix(5) ?? []
		return Array(users)
	}
	
	public var chain: Chain.ChainID {
		get {
			return Chain.ChainID(rawValue: chainID) ?? .ethereumMainnet // 默认主网
		}
		set {
			self.chainID = newValue.rawValue
		}
	}
	
	public var multiSigAddress: EthereumAddress {
		get {
			return EthereumAddress(address) ?? .ethZero
		}
		set {
			self.address = newValue.address
		}
	}
	
	public var ownersAddresses: [EthereumAddress] {
		get {
			return owners.compactMap({ EthereumAddress($0) })
		}
		set {
			self.owners = newValue.compactMap({ $0.address })
		}
	}
	
	@MainActor
	public func update(name: String?, owners: [String]?, nonce: Int64?, threshold: Int64, ownerTokenBalance: OwnersTokenBalance? = nil) async {
		dispatchPrecondition(condition: .onQueue(.main))

		self.name = name ?? ""
		self.owners = owners ?? []
		self.nonce = nonce ?? 0
		self.threshold = threshold
		if let ownerTokenBalance {
			self.ownerTokenBalance = ownerTokenBalance
		}
		
		let current = await Family.by(address: self.address, chainId: self.chainID)
		current?.name = self.name
		current?.owners = self.owners
		current?.threshold = self.threshold
		current?.ownerTokenBalanceData = self.ownerTokenBalanceData
		
		CoreDataStack.shared.saveContext()

		NotificationCenter.default.post(name: .selectedSafeUpdated, object: self)
	}
	
	@MainActor
	public func update(ownerTokenBalance: OwnersTokenBalance?) async {
		dispatchPrecondition(condition: .onQueue(.main))
	
		if let ownerTokenBalance {
			self.ownerTokenBalance = ownerTokenBalance
			
			let current = await Family.by(address: self.address, chainId: self.chainID)
			current?.ownerTokenBalanceData = self.ownerTokenBalanceData
			CoreDataStack.shared.saveContext()
			
			NotificationCenter.default.post(name: .selectedSafeUpdated, object: self)
		}
	}
	
	@MainActor
	public func update(token: FamilyToken?) async {
		dispatchPrecondition(condition: .onQueue(.main))
		if let token {
			self.token = token
			let current = await Family.by(address: self.address, chainId: self.chainID)
			current?.token = self.token
			CoreDataStack.shared.saveContext()
			NotificationCenter.default.post(name: .selectedSafeUpdated, object: self)
		}
	}
	
	public var staticDomain: String {
		return "familydao-\(self.address)"
	}
	
	/// familydao-0x786252.... (没有 .eth 后缀)
	@MainActor
	public func updateSpaceDomain() async {
		dispatchPrecondition(condition: .onQueue(.main))
		self.spaceDomain = self.staticDomain
		let current = await Family.by(address: self.address, chainId: self.chainID)
		current?.spaceDomain = self.spaceDomain
		CoreDataStack.shared.saveContext()
		NotificationCenter.default.post(name: .selectedSafeUpdated, object: self)
	}
	
//	@discardableResult
//	public static func create(address: String,
//							  name: String,
//							  chain: Chain.ChainID = ChainManager.currentChain,
//							  owners: [String]? = nil,
//							  nonce: Int64? = nil,
//							  threshold: Int64? = nil,
//							  selected: Bool = true) -> Family {
//		dispatchPrecondition(condition: .onQueue(.main))
//		let context = CoreDataStack.shared.viewContext
//
//		let safe = Family(context: context)
//		safe.address = address
//		safe.name = name
//		safe.chainID = chain.rawValue
//		safe.owners = owners ?? []
//		safe.nonce = nonce ?? 0
//		safe.threshold = threshold ?? 0
//		if selected {
//			safe.select()
//		}
//		CoreDataStack.shared.saveContext()
//
//		return safe
//	}
	
}


public struct FamilyTokenViewModel: Identifiable {
	public var id = UUID()
	
	public var address: String
	public var decimals: Int64
	public var name: String
	public var symbol: String
	public var family: Family?
	
	init?(managedObject: FamilyToken) {
		self.address = managedObject.address ?? ""
		self.decimals = managedObject.decimals
		self.name = managedObject.name ?? ""
		self.symbol = managedObject.symbol ?? "TOKEN"
		self.family = managedObject.family
	}
	
}
