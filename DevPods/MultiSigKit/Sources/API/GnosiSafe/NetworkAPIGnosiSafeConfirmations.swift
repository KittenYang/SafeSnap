//
//  NetworkAPIGnosiSafeQueued.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/7/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit

class NetworkAPIGnosiSafeConfirmations: NetworkAPI {
	var signedSafeTxHash: String = ""
	var safeTxHash: String = ""
	
	override var baseURL: URL {
		URL(string: Constant.gnosisSafeBaseAPI)!
	}
	
	init(signedSafeTxHash: String, safeTxHash: String) {
		self.signedSafeTxHash = signedSafeTxHash
		self.safeTxHash = safeTxHash
	}
	
	required public init() {
		super.init()
	}
	
	override var method: Moya.Method {
		return Method.post
	}
	
	public override var task: Task {
		
		let dict = ["signedSafeTxHash":signedSafeTxHash]
		
		var data: Data?
		let checker = JSONSerialization.isValidJSONObject(dict)
		if checker {
			data = try? JSONSerialization.data(withJSONObject: dict, options: [])
		}
	
		return .requestData(data ?? Data())
		
	}
	
	override var path: String {
		return "/v1/chains/\(ChainManager.currentChain.rawValue)/transactions/\(safeTxHash)/confirmations"
	}
	
}

