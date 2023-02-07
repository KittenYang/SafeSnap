//
//  SnapshotUserSpaceFollows.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import HandyJSON
import web3swift

public class SnapshotUserSpaceFollows: HandyJSON {
	public var follows: [SnapshotUserSpaceFollowsDetail]?
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.follows <-- "data.follows"
	}
	
	required public init() {}
}


public class SnapshotUserSpaceFollowsDetail: HandyJSON {
	public var id: String?
	public var follower: EthereumAddress?
	public var space: SnapshotSpaceInfo.SnapshotSpaceInfoDetail?
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.follower <-- EthereumAddressTransform()
	}
	
	required public init() {}
}
