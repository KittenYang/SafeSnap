//
//  CreateSnapshotAPIMsgResult.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/11/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import HandyJSON
import web3swift

public class CreateSnapshotAPIMsgResult: HandyJSON {
	
	public var id:EthereumAddress?
	public var ipfs:String?
	public var relayer: CreateSnapshotAPIMsgResultRelayer?
	
	public class CreateSnapshotAPIMsgResultRelayer: HandyJSON {
		public var address:EthereumAddress?
		public var receipt:String?

		public func mapping(mapper: HelpingMapper) {
			mapper <<<
				self.address <-- EthereumAddressTransform()
		}
		
		required public init() {}
	}
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.id <-- EthereumAddressTransform()
	}
	
	required public init() {}
	
	public var isValid: Bool {
		if ipfs != nil || relayer?.address != nil {
			return true
		}
		return false
	}
	
}
