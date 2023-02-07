//
//  NetworkAPIGetVoteOfSpace.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit
import web3swift

class NetworkAPIGetVoteOfProposal: NetworkAPISnapshotGraphql {

	var proposalID:String
	var first:Int
	var address: String?
	var space: String?
	
	init(proposalID:String, first:Int, address:String?, space: String?) {
		self.proposalID = proposalID
		self.first = first
		self.address = address
		self.space = space?.wthETHSuffix
		
		var queryDict = [
			"operationName": "Votes",
			"variables": [
				"id": proposalID,
				"orderBy": "vp",
				"orderDirection": "desc",
				"first": first
			],
			"query": "query Votes($id: String!, $first: Int, $skip: Int, $orderBy: String, $orderDirection: OrderDirection, $voter: String, $space: String) {\n  votes(\n    first: $first\n    skip: $skip\n    where: {proposal: $id, vp_gt: 0, voter: $voter, space: $space}\n    orderBy: $orderBy\n    orderDirection: $orderDirection\n  ) {\n    ipfs\n    voter\n    choice\n    vp\n    vp_by_strategy\n    reason\n   created\n  }\n}"
		] as [String : Any]
		
		if let address {
			queryDict["voter"] = address
		}
		
		if let space {
			queryDict["space"] = space
		}
		
		super.init(queryDict: queryDict)
	}
	
	required public init() {
		self.proposalID = ""
		self.first = 1
		self.address = ""
		super.init()
	}
	
}

