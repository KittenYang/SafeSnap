//
//  NetworkAPIGetSpaceAllProposal.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/18/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit
import web3swift

class NetworkAPIGetSpaceAllProposal:NetworkAPISnapshotGraphql {

	var domain: String
	var first: Int
	var skip: Int

	init(domain: String, first: Int, skip: Int) {
		self.domain = domain.wthETHSuffix.lowercased()
		self.first = first
		self.skip = skip
		
		let queryDict = [
			"query": "query { proposals (first: \(self.first), skip: \(self.skip), where: {space_in: [\"\(self.domain)\"]}) { id author title body state created start end votes space { id } } }"
		] as [String : Any]
		
		super.init(queryDict: queryDict)
	}
	
	required public init() {
		self.domain = ""
		self.first = 100
		self.skip = 0
		super.init()
	}
	
}
