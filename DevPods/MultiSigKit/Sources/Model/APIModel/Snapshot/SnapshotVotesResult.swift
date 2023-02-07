//
//  SnapshotVotesResult.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import HandyJSON
import web3swift

/*
 {
	 "data": {
		 "votes": [
			 {
				 "ipfs": "bafkreihjrc5gjkv66eqqjgzk54sfimy4om6mlr37fg5eew3q72lucezy5m",
				 "voter": "0xfa2B2E4348d6af2d6cd33a5e7dcb5E4eAaC477BC",
				 "choice": 1,
				 "vp": 62,
				 "vp_by_strategy": [
					 62
				 ],
				 "reason": "",
				 "created": 1670147739
			 }
		 ]
	 }
 }
 */
public class SnapshotVotesResult: HandyJSON {
	public var votes: [SnapshotVotesResultDetail]?
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.votes <-- "data.votes"
	}
	
	required public init() {}
}

public class SnapshotVotesResultDetail: HandyJSON, Hashable, Identifiable {
	public static func == (lhs: SnapshotVotesResultDetail, rhs: SnapshotVotesResultDetail) -> Bool {
		return lhs.ipfs == rhs.ipfs && lhs.choice == rhs.choice && lhs.voter == rhs.voter && lhs.vp == rhs.vp && lhs.created == rhs.created
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(ipfs)
		hasher.combine(choice)
		hasher.combine(voter)
		hasher.combine(vp)
		hasher.combine(created)
	}
	
	public var ipfs: String?
	public var voter: EthereumAddress?
	public var choice: Int?
	public var vp: Int?
	public var vp_by_strategy: [Int]?
	public var vp_state: String?
	public var reason: String?
	public var created: Date?
	
	public var id: String {
		return "\(created?.timeIntervalSince1970 ?? 0)_\(reason ?? "")_\(vp ?? 0)_\(ipfs ?? "")_\(voter?.address ?? "")_\(choice ?? 0)"
	}
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.voter <-- EthereumAddressTransform()
		mapper <<<
			self.created <-- DateTransform()
	}
	
	required public init() {}
}


public class SnapshotScoreResult: HandyJSON {

	public var jsonrpc: String?
	public var result: SnapshotVotesResultDetail?
	public var id: String?
	public var cache: Bool?
	
	required public init() {}
}
