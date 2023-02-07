//
//  SnapshotSpaceInfo.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/8/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import HandyJSON
import web3swift

public class SnapshotSpaceInfo: HandyJSON {
	
	public var spaces: [SnapshotSpaceInfoDetail]?
	
	public class SnapshotSpaceInfoDetail: HandyJSON, CustomDebugStringConvertible {
		public var id: String?//rillafi.eth
		public var name: String?
		public var about: String?
		public var network: String?
		public var symbol: String?
		public var terms: String?
		public var skin: String?
		public var avatar: String?
		public var twitter: String?
		public var website: String?
		public var github: String?
		public var `private`: Bool?
		public var domain: String?
		
		public var members:[EthereumAddress]?
		public var admins:[EthereumAddress]?
		public var categories: [String]?
		
		public var plugins: String?
		public var followersCount: Int?
		public var parent: String?
		public var children: [String]?
		public var voting: SnapshotSpaceInfoDetailVoting?
		
		public var strategies: [SnapshotSpaceInfoDetailStrategy]?
		
		public var validation: SnapshotSpaceInfoDetailValidation?
		public var filters: SnapshotSpaceInfoDetailFilters?
		public var treasuries: [String]?
		
		public class SnapshotSpaceInfoDetailStrategy: HandyJSON {
			public enum Strategy: String, HandyJSONEnum {
				case erc20_balance_of = "erc20-balance-of"
				case erc721 = "erc721"
				case erc1155_balance_of = "erc1155-balance-of"
				case whitelist = "whitelist"
				case ticket = "ticket"
				case eth_balance = "eth-balance"
			}
			public var name: Strategy?
			public var network: String?
			public var params:SnapshotSpaceInfoDetailStrategyParam?
			
			public class SnapshotSpaceInfoDetailStrategyParam: HandyJSON {
				public var symbol: String?
				public var address: EthereumAddress?
				public var network: Chain.ChainID?
				public var decimals: Int?
				
				public func mapping(mapper: HelpingMapper) {
					mapper <<<
						self.address <-- EthereumAddressTransform()
				}
				
				required public init() {}
			}
			
			required public init() {}
		}
		
		required public init() {}
		
		public func mapping(mapper: HelpingMapper) {
			mapper <<<
				self.members <-- EthereumAddressArrayTransform()
			mapper <<<
				self.admins <-- EthereumAddressArrayTransform()
		}
		
		public var debugDescription: String {
			return name ?? ""
		}
	}
	
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.spaces <-- "data.spaces"
	}
	
	required public init() {}
	
}

public class SnapshotSpaceInfoDetailVoting: HandyJSON {
	
	public var delay: String?
	public var period: String?
	public var type: String?
	public var quorum: String?
	public var hideAbstain: Bool?
	
	required public init() {}
}

public class SnapshotSpaceInfoDetailValidation: HandyJSON {
	
	public var name: String?
	public var params: [String:String]?
	
	required public init() {}
}

public class SnapshotSpaceInfoDetailFilters: HandyJSON {
	
	public var minScore: Int?
	public var onlyMembers: Bool?
	
	required public init() {}
}
