//
//  SnapshotSubscriptions.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import HandyJSON
import web3swift

public class SnapshotSubscriptions: HandyJSON {
	public var subscriptions: [SnapshotVotesResultDetail]?
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.subscriptions <-- "data.subscriptions"
	}
	
	required public init() {}
}

//public class SnapshotSubscriptionDetail: HandyJSON {
//
//	public var ipfs: String?
//	public var voter: EthereumAddress?
//	public var choice: Int?
//	public var vp: Int?
//	public var vp_by_strategy: [Int]?
//	public var reason: String?
//
//	public func mapping(mapper: HelpingMapper) {
//		mapper <<<
//			self.voter <-- EthereumAddressTransform()
//	}
//
//	required public init() {}
//}

