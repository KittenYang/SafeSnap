//
//  SafeBalance.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/7/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import HandyJSON
import web3swift
import BigInt

/*
 {
		 "fiatTotal": "0",
		 "items": [
				 {
						 "tokenInfo": {
								 "type": "NATIVE_TOKEN",
								 "address": "0x0000000000000000000000000000000000000000",
								 "decimals": 18,
								 "symbol": "ETH",
								 "name": "Ether",
								 "logoUri": "https://safe-transaction-assets.gnosis-safe.io/chains/4/currency_logo.png"
						 },
						 "balance": "0",
						 "fiatBalance": "0.00000",
						 "fiatConversion": "1677.3960242"
				 },
				 {
						 "tokenInfo": {
								 "type": "ERC20",
								 "address": "0x3f5faec54Be9beD1756D53818a2c4eaEf6827B56",
								 "decimals": 18,
								 "symbol": "FAMD1",
								 "name": "Family-DAO-1",
								 "logoUri": "https://safe-transaction-assets.gnosis-safe.io/tokens/logos/0x3f5faec54Be9beD1756D53818a2c4eaEf6827B56.png"
						 },
						 "balance": "1000000000000000000000000",
						 "fiatBalance": "0.00000",
						 "fiatConversion": "0.0"
				 }
		 ]
 }
 */
public class SafeBalance: HandyJSON {
	public var fiatTotal: String?
	public var items: [SafeBalanceItem]?
	
	public class SafeBalanceItem: HandyJSON {
		public var tokenInfo: SafeBalanceTokenInfo?
		public var balance: String?
		public var fiatBalance: String?
		public var fiatConversion: String?
		
		required public init() {}
	}
	
	public class SafeBalanceTokenInfo: HandyJSON {
		public enum TokenType: String, HandyJSONEnum {
			case native = "NATIVE_TOKEN"
			case erc20 = "ERC20"
		}
		
		public var type: TokenType?
		public var address: String?
		public var decimals: Int64?
		public var symbol: String?
		public var name: String?
		public var logoUri: String?
		
		required public init() {}
	}
	required public init() {}
	
}
