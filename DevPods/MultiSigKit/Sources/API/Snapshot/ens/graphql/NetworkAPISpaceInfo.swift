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

class NetworkAPISpaceInfo:NetworkAPISnapshotGraphql {

	var eth_domain_names: [String] = []

	init(eth_domain_names: [String]) {
		var names = [String]()
		eth_domain_names.forEach { name in
			names.append("\(name.lowercased())")
		}
		self.eth_domain_names = names
		let queryDict = [
			"operationName":"Spaces",
			"variables": [
				"id_in": eth_domain_names
			],
			"query": "query Spaces($id_in: [String]) {\n  spaces(where: {id_in: $id_in}, first: 200) {\n    id\n    name\n    about\n    network\n    symbol\n    network\n    terms\n    skin\n    avatar\n    twitter\n    website\n    github\n    private\n    domain\n    members\n    admins\n    categories\n    plugins\n    followersCount\n    parent {\n      id\n      name\n      avatar\n      followersCount\n      children {\n        id\n      }\n    }\n    children {\n      id\n      name\n      avatar\n      followersCount\n      parent {\n        id\n      }\n    }\n    voting {\n      delay\n      period\n      type\n      quorum\n      hideAbstain\n    }\n    strategies {\n      name\n      network\n      params\n    }\n    validation {\n      name\n      params\n    }\n    filters {\n      minScore\n      onlyMembers\n    }\n    treasuries {\n      name\n      address\n      network\n    }\n  }\n}"
		] as [String : Any]
		
		super.init(queryDict: queryDict)
	}
	
	required public init() {
		super.init()
	}

}
