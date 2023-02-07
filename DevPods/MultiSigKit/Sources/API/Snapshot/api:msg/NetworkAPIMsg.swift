//
//  NetworkAPIMsg.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/18/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit

class NetworkAPIMsg: NetworkAPI {
	
	override var baseURL: URL {
		URL(string: "https://snapshot.org")!.snapshotURLifIsTestnet(chain: WalletManager.shared.currentFamilyChain)
	}
	
	override var method: Moya.Method {
		return .post
	}
	
	override var path: String {
		return "/api/msg"
	}
	
}
