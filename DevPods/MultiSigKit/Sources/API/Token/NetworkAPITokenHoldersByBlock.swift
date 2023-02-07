//
//  NetworkAPITokenHoldersByBlock.swift
//  MultiSigKit
//
//  Created by KittenYang on 1/29/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit
import web3swift
import BigInt

//API DOCs: https://www.covalenthq.com/docs/api/#/0/Get%20token%20balances%20for%20address/USD/1
class NetworkAPITokenHoldersByBlock: NetworkAPI {
	
	//https://api.covalenthq.com/v1/5/tokens/0x6C7C1D31B3FAd6a8F491A425480023571E25d1F2/token_holders/?key=ckey_2d082caf47f04a46947f4f212a8&block-height=8391947
	override var baseURL: URL {
		URL(string: "https://api.covalenthq.com")!
	}
	
	override var path: String {
		
		return "/v1/\(WalletManager.shared.currentFamilyChain.rawValue)/tokens/\(tokenAddress.address)/token_holders/"
	}
	
	var tokenAddress: EthereumAddress
	var blockHeight: BigUInt
	
	init(tokenAddress: EthereumAddress,blockHeight: BigUInt) {
		self.tokenAddress = tokenAddress
		self.blockHeight = blockHeight
	}
	
	required public init() {
		self.tokenAddress = .ethZero
		self.blockHeight = BigUInt("0")
		super.init()
	}
	
	override var task: Task {
		return .requestParameters(parameters: ["key":"ckey_2d082caf47f04a46947f4f212a8","block-height":blockHeight], encoding: URLEncoding.queryString)
	}
	
}
