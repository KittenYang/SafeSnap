//
//  SafeInfo.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/7/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import HandyJSON
import web3swift

/*
 {
		 "address": {
				 "value": "0x7860e1F21b84D17A364A6CCc653701a2cCc1Ba6b"
		 },
		 "chainId": "4",
		 "nonce": 0,
		 "threshold": 2,
		 "owners": [
				 {
						 "value": "0xab5eAE09AaEF48313fd8a030522A5D2b241df18c"
				 },
				 {
						 "value": "0x36A7784B4C97f77D32e754Df78183df9Ad8a7604"
				 }
		 ],
		 "implementation": {
				 "value": "0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552"
		 },
		 "modules": null,
		 "fallbackHandler": {
				 "value": "0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4"
		 },
		 "guard": null,
		 "version": "1.3.0",
		 "implementationVersionState": "UP_TO_DATE",
		 "collectiblesTag": "1659706713",
		 "txQueuedTag": "1659637040",
		 "txHistoryTag": "1659287375"
 }
 */
public class SafeInfo: HandyJSON {
	public var address: String?
	public var chainId: String?
	public var nonce: Int?
	public var threshold: Int?
	public var modules: String?
	public var fallbackHandler: String?
	public var `guard`: String?
	public var version: String?
	public var implementationVersionState: String?
	public var collectiblesTag: Date?
	public var txQueuedTag: Date?
	public var txHistoryTag: Date?
	public var owners: [EthereumAddress]?
	public var implementation: String?
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.address <-- "address.value"
		mapper <<<
			self.implementation <-- "implementation.value"
		mapper <<<
			self.fallbackHandler <-- "fallbackHandler.value"
		mapper <<<
			self.collectiblesTag <-- YMDDateFormatTransform()
		mapper <<<
			self.txQueuedTag <-- YMDDateFormatTransform()
		mapper <<<
			self.txHistoryTag <-- YMDDateFormatTransform()
		mapper <<<
			self.owners <--  EthereumAddressArrayTransform()
	}
	
	required public init() {}
}
