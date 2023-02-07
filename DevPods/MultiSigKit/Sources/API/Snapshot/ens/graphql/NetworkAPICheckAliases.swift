//
//  NetworkAPISpaceInfo.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/8/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit
import web3swift

class NetworkAPICheckAliases:NetworkAPISnapshotGraphql {

	var address: String
	var alias: String

	init(address: String, alias: String) {
		self.address = address
		self.alias = alias
		
		let queryDict = [
			"operationName":"Aliases",
			"variables": [
				"address": address,
				"alias": alias
			],
			"query": "query Aliases($address: String!, $alias: String!) {\n  aliases(where: {address: $address, alias: $alias}) {\n    address\n    alias\n  }\n}"
		] as [String : Any]
		
		super.init(queryDict: queryDict)
	}
	
	required public init() {
		self.address = ""
		self.alias = ""
		super.init()
	}
	
}
