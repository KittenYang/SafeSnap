//
//  TokenContractInfo.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/11/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import HandyJSON
import web3swift
import BigInt

public class TokenContractInfo: HandyJSON, CustomStringConvertible {
	
	public var data:[TokenContractInfoData]?
	
	public class TokenContractInfoData: HandyJSON, CustomStringConvertible {
		public var contract_decimals:Int?
		public var contract_name:String?
		public var contract_ticker_symbol:String?
		public var contract_address:EthereumAddress?
		public var logo_url:String?
		public var update_at:Date?
		public var totalSupply:BigUInt?
		
		public func mapping(mapper: HelpingMapper) {
			mapper <<<
				self.update_at <-- ISO8601SSSDateTransform()
			mapper <<<
				self.contract_address <-- EthereumAddressTransform()
		}
		
		public var description: String {
			return self.toJSONString() ?? "null"
		}
		
		required public init() {}
		
	}
	
	public var description: String {
		return toJSONString() ?? "null"
	}
	
	required public init() {}
	
}

open class ISO8601SSSDateTransform: DateFormatterTransform {

	public init() {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

		super.init(dateFormatter: formatter)
	}

}

open class ISO8601sszDateTransform: DateFormatterTransform {
	public init() {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'z'"

		super.init(dateFormatter: formatter)
	}
}

open class ISO8601ssZDateTransform: DateFormatterTransform {
	public init() {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

		super.init(dateFormatter: formatter)
	}
}
