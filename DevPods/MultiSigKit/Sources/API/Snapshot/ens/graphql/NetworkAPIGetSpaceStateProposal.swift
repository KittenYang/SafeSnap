//
//  NetworkAPIGetSpaceStateProposal.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit
import web3swift

class NetworkAPIGetSpaceStateProposal: NetworkAPISnapshotGraphql {

	var domain: String
	var first: Int
	var skip: Int
	var state: SnapshotProposalInfo.ProposalState
	var startDate: Date?
	var author_in: [String]?
	
	init(domain: String, first: Int, skip: Int, state: SnapshotProposalInfo.ProposalState, startDate: Date?, author_in: [String]?) {
		self.domain = domain.wthETHSuffix.lowercased()
		self.first = first
		self.skip = skip
		self.state = state
		self.startDate = startDate
		self.author_in = author_in
		
		var queryDict = [
			"operationName": "Proposals",
			"variables": [
				"first": self.first,
				"skip": self.skip,
				"state": self.state.rawValue,
				"space_in": [self.domain]
			],
			"query": "query Proposals($first: Int!, $skip: Int!, $state: String!, $space: String, $space_in: [String], $author_in: [String], $start_gte: Int) {\n  proposals(\n    first: $first\n    skip: $skip\n    where: {space: $space, state: $state, space_in: $space_in, author_in: $author_in, start_gte: $start_gte}\n  ) {\n    id\n    ipfs\n    title\n    body\n    start\n    end\n    state\n    author\n    created\n    choices\n    space {\n      id\n      name\n      members\n      avatar\n      symbol\n    }\n    scores_state\n    scores_total\n    scores\n    votes\n    quorum\n    symbol\n  }\n}"
		] as [String : Any]
		
		if let startDate = self.startDate {
			queryDict["start_gte"] = Int(startDate.timeIntervalSince1970)
		}
		if let author_in = self.author_in {
			queryDict["author_in"] = author_in
		}
		
		super.init(queryDict: queryDict)
	}
	
	required public init() {
		self.domain = ""
		self.first = 10
		self.skip = 0
		self.state = .active
		self.startDate = Date(timeIntervalSince1970: 1663933035)
		super.init()
	}
	
}
