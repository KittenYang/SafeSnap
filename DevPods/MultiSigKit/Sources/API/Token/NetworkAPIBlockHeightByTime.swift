//
//  NetworkAPIBlockHeightByTime.swift
//  MultiSigKit
//
//  Created by KittenYang on 1/28/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit

class NetworkAPIBlockHeightByTime: NetworkAPI {
	
	//https://api.covalenthq.com/v1/5/block_v2/2023-01-29T15:04:57z/2023-01-29T15:05:57z/?format=JSON&key=ckey_2d082caf47f04a46947f4f212a8
	// eg: 2020-01-01 or 2020-01-01T03:36:50z
	override var baseURL: URL {
		URL(string: "https://api.covalenthq.com")!
	}
	
	override var path: String {
		let from:String = ISO8601sszDateTransform().dateFormatter.string(from: fromDate)
		let to:String = ISO8601sszDateTransform().dateFormatter.string(from: toDate)

		return "/v1/\(WalletManager.shared.currentFamilyChain.rawValue)/block_v2/\(from)/\(to)/"
	}
	
	var fromDate: Date = .init()
	var toDate: Date = .init()
	
	init(fromDate: Date,toDate: Date) {
		self.fromDate = fromDate
		self.toDate = toDate
	}
	
	required public init() {
		super.init()
	}
	
	override var task: Task {
		return .requestParameters(parameters: ["key":"ckey_2d082caf47f04a46947f4f212a8"], encoding: URLEncoding.queryString)
	}
	
}
