//
//  NetworkAPIGnosisBalance.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/7/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit

class NetworkAPIGnosisBalance: NetworkAPI {
	var address: String
	var exclude_spam = true
	var trusted = false
	
	override var baseURL: URL {
		URL(string: Constant.gnosisSafeBaseAPI)!
	}
	
	init(address: String) {
		self.address = address
	}
	
	required public init() {
		self.address = ""
		super.init()
	}
	
	override var path: String {
		return "/v1/chains/\(WalletManager.shared.currentFamilyChain.rawValue)/safes/\(address)/balances/USD"
	}
	
}
