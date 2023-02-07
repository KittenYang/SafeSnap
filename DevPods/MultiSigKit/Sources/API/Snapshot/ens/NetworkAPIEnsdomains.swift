//
//  NetworkAPIEnsdomains.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/4/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit
import web3swift

class NetworkAPIEnsdomains:NetworkAPIBaseEnsdomains {
	
	var address: String = ""

 	init(address: String) {
		self.address = address.lowercased()//坑：必须小写！！
		let queryDict = [
			"operationName":"Domain",
			"variables": [
				"id": "\(self.address)"
			],
			"query": "query Domain($id: String!) {\n  account(id: $id) {\n    domains {\n      name\n    }\n  }\n}"
		] as [String : Any]
		
		super.init(queryDict: queryDict)
	}
	
	required public init() {
		super.init()
	}
	
	override var method: Moya.Method {
		return .post
	}
		
	override var baseURL: URL {
		URL(string: "https://api.thegraph.com")!
	}

	override var path: String {
		return "/subgraphs/name/ensdomains/ens\(WalletManager.shared.currentFamilyChain.web3Networks.name)"
	}
	
}
