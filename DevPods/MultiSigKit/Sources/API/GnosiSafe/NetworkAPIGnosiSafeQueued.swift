//
//  NetworkAPIGnosiSafeQueued.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/7/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Moya
import NetworkKit

public class NetworkAPIGnosiSafeQueued: NetworkAPI {
	public var address: String
	public var cursor: Cursor?
	
	public struct Cursor {
		public var limit: Int
		public var offset: Int
		public var timezone_offset: Int?
		public var trusted: Bool?
	}

	//	 https://safe-client.safe.global/v1/chains/5/safes/0xE37670f8c186E763545a1E1d5EfDAE745127d0E4/transactions/queued?cursor=limit%3D20%26offset%3D0&timezone_offset=0&trusted=true"
	// cursor=limit=20&offset=20&timezone_offset=0&trusted=true
	public override var baseURL: URL {
		URL(string: "https://safe-client.safe.global")!
	}
	
	public init(address: String, cursor: Cursor?) {
		self.address = address
		self.cursor = cursor
	}
	
	required public init() {
		self.address = ""
		super.init()
	}
	
	public override var path: String {
		return "/v1/chains/\(WalletManager.shared.currentFamilyChain.rawValue)/safes/\(address)/transactions/queued"
	}
	
	public override var task: Task {
		
		var dict: [String: Any] = toJSON() ?? [:]
		if !dict.isEmpty {
			dict.removeValue(forKey: "isShowLoading")
			dict.removeValue(forKey: "cursor")
			dict.removeValue(forKey: "address")
		}
		if let limit = cursor?.limit, let offset = cursor?.offset {
			dict["cursor"] = "limit=\(limit)&offset=\(offset)"
			dict["timezone_offset"] = "0"
			dict["trusted"] = "true"			
		}

		return .requestParameters(parameters: dict, encoding: URLEncoding.queryString)//.requestData(data ?? Data())
		
	}
	
}

