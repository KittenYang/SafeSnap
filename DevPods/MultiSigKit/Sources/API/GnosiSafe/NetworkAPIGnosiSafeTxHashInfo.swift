//
//  NetworkAPIGnosiSafeTxHashInfo.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/7/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit

class NetworkAPIGnosiSafeTxHashInfo: NetworkAPI {
	
	let safeTxHash: String
	
	override var baseURL: URL {
		URL(string: Constant.gnosisSafeBaseAPI)!
	}
	
	init(safeTxHash: String) {
		self.safeTxHash = safeTxHash
	}
	
	required public init() {
		self.safeTxHash = ""
		super.init()
	}
	
	override var path: String {
		return "/v1/chains/\(WalletManager.shared.currentFamilyChain.rawValue)/transactions/\(safeTxHash)"
	}
	
}
