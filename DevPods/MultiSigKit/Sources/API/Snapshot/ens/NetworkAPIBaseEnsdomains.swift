//
//  NetworkAPIBaseEnsdomains.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/18/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit
import web3swift

open class NetworkAPIBaseEnsdomains:NetworkAPI {
	
	var queryDict:[String:Any]
	
	public init(queryDict: [String:Any]) {
		self.queryDict = queryDict
	}
	
	required public init() {
		self.queryDict = [:]
		super.init()
	}
	
	public override var method: Moya.Method {
		return .post
	}
	
	public override var task: Task {
		let dict = queryDict
		
		var data: Data?
		let checker = JSONSerialization.isValidJSONObject(dict)
		if checker {
			data = try? JSONSerialization.data(withJSONObject: dict, options: [])
		}

		return .requestData(data ?? Data())
	}
	
}
