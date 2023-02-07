//
//  SnapshotAliasResult.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/14/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    
import Foundation
import HandyJSON
import web3swift

public class SnapshotAliasResult: HandyJSON {
	public var aliases: [SnapshotAliasResultAliases]?
	
	public class SnapshotAliasResultAliases: HandyJSON {
		public var address: EthereumAddress?
		public var alias: EthereumAddress?
		
		public func mapping(mapper: HelpingMapper) {
			mapper <<<
				self.address <-- EthereumAddressTransform()
			mapper <<<
				self.alias <-- EthereumAddressTransform()
		}
		
		required public init() {}
	}
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.aliases <-- "data.aliases"
	}
	
	required public init() {}
}
