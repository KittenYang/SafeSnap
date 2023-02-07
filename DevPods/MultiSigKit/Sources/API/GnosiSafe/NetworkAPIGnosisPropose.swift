//
//  NetworkAPIGnosisPropose.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/6/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import NetworkKit
import Moya
import web3swift


class NetworkAPIGnosisPropose: NetworkAPI {
		
	var safe: String
	var to: String
	var value: String = "0"
	var data: String
	var operation: Int = 0
	var nonce: String
	var safeTxGas: String = "0"
	var baseGas: String = "0"
	var gasPrice: String = "0"
	var gasToken: String = EthereumAddress.zero.address
	var refundReceiver: String = EthereumAddress.zero.address
	var safeTxHash: String
	var sender: String
	var origin: String?
	var signature: String = ""
	
	init(safe: String,
			 to: String,
			 value: String = "0",
			 data: Data,
			 operation: Int = 0,
			 nonce: String,
			 safeTxGas: String = "0",
			 baseGas: String = "0",
			 gasPrice: String = "0",
			 gasToken: String = EthereumAddress.zero.address,
			 refundReceiver: String = EthereumAddress.zero.address,
			 safeTxHash: String,
			 sender: String = WalletManager.shared.currentWallet?.address ?? "",
			 origin: String? = nil,
			 signature: String) {
		self.safe = safe
		self.to = to
		self.value = value
		self.data = data.toHexStringWithPrefix()
		self.operation = operation
		self.nonce = nonce
		self.safeTxGas = safeTxGas
		self.baseGas = baseGas
		self.gasPrice = gasPrice
		self.gasToken = gasToken
		self.refundReceiver = refundReceiver
		self.safeTxHash = safeTxHash
		self.sender = sender
		self.origin = origin
		self.signature = signature
	}
	
	required public init() {
		self.safe = ""
		self.to = ""
		self.data = ""
		self.nonce = ""
		self.safeTxHash = ""
		self.sender = ""
		super.init()
	}
	
	override var baseURL: URL {
		URL(string: Constant.gnosisSafeBaseAPI)!
	}
	
	override var method: Moya.Method {
		return Method.post
	}
	
	override var path: String {
		return "/v1/chains/\(WalletManager.shared.currentFamilyChain.rawValue)/transactions/\(safe)/propose"
	}
	
	public override var task: Task {
		
		var dict: [String: Any] = toJSON() ?? [:]
		if !dict.isEmpty {
			dict.removeValue(forKey: "isShowLoading")
			dict.removeValue(forKey: "safe")
		}
	
//		return .requestParameters(parameters: dict, encoding: URLEncoding.httpBody)
		
		var data: Data?
		let checker = JSONSerialization.isValidJSONObject(dict)
		if checker {
			data = try? JSONSerialization.data(withJSONObject: dict, options: [])
		}
	
		return .requestData(data ?? Data())
		
	}
	
}
