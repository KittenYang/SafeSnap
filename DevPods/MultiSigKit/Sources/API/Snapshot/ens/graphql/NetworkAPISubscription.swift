//
//  NetworkAPISubscription.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit
import web3swift

class NetworkAPISubscription:NetworkAPISnapshotGraphql {

	var address: String = ""
	var space: String = ""

	init(address: String, space: String) {
		self.address = address
		self.space = space
		let queryDict = [
			"operationName":"Subscriptions",
			"variables": [
				"address": address,
				"space": space
			],
			"query": "query Subscriptions($space: String, $address: String) {\n  subscriptions(where: {space: $space, address: $address}) {\n    id\n    address\n    space {\n      id\n    }\n  }\n}"
		] as [String : Any]
		
		super.init(queryDict: queryDict)
	}
	
	required public init() {
		super.init()
	}

}

