//
//  NetworkAPISigTypedData.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/11/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit

class NetworkAPISigTypedData: NetworkAPIMsg {
	
	var address:String
	var sig:String
	var typedData:EIP712TypedData
	
	init(address: String, sig:String, typedData:EIP712TypedData) {
		self.address = address
		self.sig = sig
		self.typedData = typedData
	}
	
	required public init() {
		self.address = ""
		self.sig = ""
		self.typedData = .init(types: [:], primaryType: "", domain: .null, message: .null)
		super.init()
	}
	
	public override var task: Task {
		var dict:[String:Any] = [
			"address":address,
			"sig":sig
		]
		
		if var typedDataDict = try? typedData.asDictionary() {
			typedDataDict.removeValue(forKey: "primaryType")
			if var types = typedDataDict["types"] as? [String:Any] {
				types.removeValue(forKey: "EIP712Domain")
				typedDataDict["types"] = types
			}
			dict["data"] = typedDataDict
		}
		
		var data: Data?
		let checker = JSONSerialization.isValidJSONObject(dict)
		if checker {
			debugPrint("post body:\n\(dict.toJSONString() ?? "nil")")
			data = try? JSONSerialization.data(withJSONObject: dict, options: [])
		}
	
		return .requestData(data ?? Data())
	}
	
//	override var headers: [String : String]? {
//		var h = super.headers
//		let new = ["authority":"testnet.snapshot.org",
//				"accept": "application/json",
//				"accept-encoding": "gzip, deflate, br",
//				"accept-language": "zh-CN,zh;q=0.9,en;q=0.8",
//				"content-length": "1053",
//				"content-type": "application/json",
//				"origin": "https://demo.snapshot.org",
//				"referer": "https://demo.snapshot.org/",
//				"sec-ch-ua": "\"Google Chrome\";v=\"107\", \"Chromium\";v=\"107\", \"Not=A?Brand\";v=\"24\"",
//				"sec-ch-ua-mobile": "?0",
//				"sec-ch-ua-platform": "macOS",
//				"sec-fetch-dest": "empty",
//				"sec-fetch-mode": "cors",
//				"sec-fetch-site": "same-site",
//				"user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
//		]
//
//		h?.merge(dict: new)
//		return h
//	}
	
}

extension Encodable {
  func asDictionary() throws -> [String: Any] {
	let data = try JSONEncoder().encode(self)
	guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
	  throw NSError()
	}
	return dictionary
  }
}
