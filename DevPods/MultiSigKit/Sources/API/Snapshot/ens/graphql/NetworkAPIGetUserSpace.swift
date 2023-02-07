//
//  NetworkAPIGetUserSpace.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit
import web3swift

class NetworkAPIGetUserSpace:NetworkAPISnapshotGraphql {

	var address: String

	init(address: String) {
		self.address = address
		
		let queryDict = [
			"operationName": "Follows",
			"variables": [
				"follower_in": address
			],
			"query": "query Follows($space_in: [String], $follower_in: [String]) {\n  follows(where: {space_in: $space_in, follower_in: $follower_in}, first: 500) {\n    id\n    follower\n    space {\n      id\n    }\n  }\n}"
		] as [String : Any]
		
		super.init(queryDict: queryDict)
	}
	
	required public init() {
		self.address = ""
		super.init()
	}
	
}
