//
//  NetworkAPISnapshotGraphql.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/18/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    
import Moya
import NetworkKit
import web3swift

class NetworkAPISnapshotGraphql: NetworkAPIBaseEnsdomains {
	
	public override init(queryDict: [String:Any]) {
		super.init(queryDict: queryDict)
	}
	
	required public init() {
		super.init(queryDict: [:])
	}
	
	override var method: Moya.Method {
		return .post
	}
		
	override var baseURL: URL {
		URL(string: "https://snapshot.org")!.snapshotURLifIsTestnet(chain: WalletManager.shared.currentFamilyChain)
	}

	override var path: String {
		return "/graphql"
	}
	
}


class NetworkAPISnapshotScore: NetworkAPIBaseEnsdomains {
	
	public override init(queryDict: [String:Any]) {
		super.init(queryDict: queryDict)
	}
	
	required public init() {
		super.init(queryDict: [:])
	}
	
	override var method: Moya.Method {
		return .post
	}
		
	override var baseURL: URL {
		URL(string: "https://score.snapshot.org")!
	}

	override var path: String {
		return ""
	}
	
}
