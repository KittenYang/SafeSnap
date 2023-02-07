//
//  NetworkAPITokenInfo.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/11/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit

class NetworkAPITokenInfo: NetworkAPI {
	
	//	https://api.covalenthq.com/v1/pricing/historical_by_addresses_v2/5/USD/0xf02b3087F3c58441d410bdD1a11D3663D46C3cE2/?quote-currency=USD&format=JSON&key=ckey_2d082caf47f04a46947f4f212a8
	override var baseURL: URL {
		URL(string: "https://api.covalenthq.com")!
	}
	
	var address: String
	
	init(address: String) {
		self.address = address
	}
	
	required public init() {
		self.address = ""
		super.init()
	}
	
	override var task: Task {
		
//		var dict: [String: Any] = toJSON() ?? [:]
//		if !dict.isEmpty {
//			dict.removeValue(forKey: "isShowLoading")
//			dict.removeValue(forKey: "safe")
//		}
//
		//		return .requestParameters(parameters: dict, encoding: URLEncoding.httpBody)
		
//		var data: Data?
//		let checker = JSONSerialization.isValidJSONObject(dict)
//		if checker {
//			data = try? JSONSerialization.data(withJSONObject: dict, options: [])
//		}
		
		return .requestParameters(parameters: ["quote-currency":"USD","format":"JSON","key":"ckey_2d082caf47f04a46947f4f212a8"], encoding: URLEncoding.queryString)
		
	}
	
	override var path: String {
		return "/v1/pricing/historical_by_addresses_v2/\(WalletManager.shared.currentFamilyChain.rawValue)/USD/\(address)/"
	}
}


class NetworkAPISpaceStatus: NetworkAPI {
	
	//https://cdn.stamp.fyi/clear/space/family-dao-dev-1.eth
	override var baseURL: URL {
		URL(string: "https://cdn.stamp.fyi")!
	}
	
	var domain: String
	
	init(domain: String) {
		self.domain = domain
	}
	
	required public init() {
		self.domain = ""
		super.init()
	}
	
	override var path: String {
		return "/clear/space/\(domain)"
	}
}
