//
//  Erc20TokenHolders.swift
//  MultiSigKit
//
//  Created by KittenYang on 1/29/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import HandyJSON
import BigInt
import web3swift

public class Erc20TokenHoldersDataItem: HandyJSON {
	public var contract_decimals: Int?
	public var contract_name: String?
	public var contract_ticker_symbol: String?
	public var contract_address: EthereumAddress?
	public var supports_erc: Bool?
	public var logo_url: URL?
	public var address: EthereumAddress?
	public var balance: BigUInt?
	public var total_supply: BigUInt?
	public var block_height: BigUInt?
	
	required public init() {}
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.contract_address <-- EthereumAddressTransform()
		mapper <<<
			self.address <-- EthereumAddressTransform()
		mapper <<<
			self.balance <-- BigUIntTransform()
		mapper <<<
			self.total_supply <-- BigUIntTransform()
		mapper <<<
			self.block_height <-- BigUIntTransform()
	}
}
