//
//  NetworkAPIGetScore.swift
//  MultiSigKit
//
//  Created by KittenYang on 12/4/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit
import web3swift
import BigInt

class NetworkAPIGetScore: NetworkAPISnapshotScore {
	
	var api_method: String
	
	init(domain:String,
		 api_method: String,
		 address: String,
		 strategy: SnapshotSpaceInfo.SnapshotSpaceInfoDetail.SnapshotSpaceInfoDetailStrategy,
		 blockNumber:String) {
		self.api_method = api_method
		
		let sJson = strategy.toJSON() ?? [String:Any]()
		let queryDict = [
			"jsonrpc":"2.0",
			"method":api_method,
			"params":[
				"address": address,
				"network": WalletManager.shared.currentFamilyChain.rawValue,
				"strategies":[
					sJson
				],
				"snapshot": Int(BigUInt(blockNumber) ?? 0),
				"space": domain.wthETHSuffix.lowercased(),
				"delegation": false
			]
//			"id": nil
		] as [String : Any]
		
		super.init(queryDict: queryDict)
	}
	
	required public init() {
		self.api_method = ""
		super.init()
	}
}
