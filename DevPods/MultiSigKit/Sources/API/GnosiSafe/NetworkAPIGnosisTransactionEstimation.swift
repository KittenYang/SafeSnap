//
//  NetworkAPIGnosisTransactionEstimation.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/7/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit

class NetworkAPIGnosisTransactionEstimation: NetworkAPI {
	var to: String
	var operation: Int = 0
	var value: String = "0"
	let data = "0x" //TODO: 这里不是写死，而是上报紧跟着交易的 tx 数据

	override var baseURL: URL {
		URL(string: Constant.gnosisSafeBaseAPI)!
	}
	
	init(address: String) {
		self.to = address
	}
	
	required public init() {
		self.to = ""
		super.init()
	}
	
	override var method: Moya.Method {
		return .post
	}
	
	override var path: String {
		return "/v1/chains/\(WalletManager.shared.currentFamilyChain.rawValue)/safes/\(to)/multisig-transactions/estimations"
	}
	
}
