//
//  NetworkAPIDownloadJSON.swift
//  GisKit
//
//  Created by Qitao Yang on 2020/10/19.
//

import Moya
import NetworkKit

class NetworkAPIGnosisSafeInfo: NetworkAPI {
	
	override var baseURL: URL {
		URL(string: Constant.gnosisSafeBaseAPI)!
	}
	
	var address: String
	
	var chain: Chain.ChainID
	
	init(address: String, chain: Chain.ChainID) {
		self.address = address
		self.chain = chain
	}
	
	required public init() {
		self.address = ""
		self.chain = .ethereumMainnet
		super.init()
	}
	
	override var path: String {
		return "/v1/chains/\(chain.rawValue)/safes/\(address)"
	}
	
	
	public override var task: Task {
		var dict: [String: Any] = toJSON() ?? [:]
		if !dict.isEmpty {
			dict.removeValue(forKey: "isShowLoading")
			dict.removeValue(forKey: "chain")
			dict.removeValue(forKey: "address")
		}

		return .requestParameters(parameters: dict, encoding: URLEncoding.queryString)//.requestData(data ?? Data())
	}
	
}

