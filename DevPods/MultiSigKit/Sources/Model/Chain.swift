//
//  Chain.swift
//  family-dao
//
//  Created by KittenYang on 7/18/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift
import CoreData
import BigInt
import HandyJSON

//public enum AppChain: String, CaseIterable {
//	case Ethereum
//	case Goerli
//
//	public var chainID: Int {
//		switch self {
//		case .Ethereum:
//			return 1
//		case .Goerli:
//			return 5
//		}
//	}
//}

public class Chain: Codable {
	public var blockExplorerUrlAddress: String?
	public var blockExplorerUrlTxHash: String?
	public var ensRegistryAddress: String?
	public var featuresCommaSeparated: String?
	public var id: String?
	public var l2: Bool = true
	public var name: String?
	public var rpcUrl: URL?
	public var rpcUrlAuthentication: String?
	public var shortName: String?
//	public var gasPriceSource: NSOrderedSet?
	public var nativeCurrency: ChainToken?
}

public extension Chain {
	enum ChainID: String, CaseIterable, Codable, RawRepresentable, HandyJSONEnum {
		case ethereumMainnet = "1"
		case ethereumRopsten = "3"
		case ethereumRinkeby = "4"
		case ethereumGoerli  = "5"
		case ethereumKovan = "42"
		case polygon = "137"
		case xDai = "100"
		case bsc = "56"
		case arbitrum = "42161"
		case avalanche = "43114"
		case optimism = "10"
		
		public static let web3provider_mainnet = Web3.InfuraMainnetWeb3(accessToken: Constant.InfuraToken)
		public static var web3provider_rinkeby = Web3.InfuraRinkebyWeb3(accessToken: Constant.InfuraToken)
		public static var web3provider_ropsten = Web3.InfuraRopstenWeb3(accessToken: Constant.InfuraToken)
		public static var web3provider_kovan   = Web3.InfuraKovanWeb3(accessToken: Constant.InfuraToken)
		public static var web3provider_goerli  = Web3.InfuraGoerliWeb3(accessToken: Constant.InfuraToken)
		
		public var web3Networks: web3swift.Networks {
			switch self {
			case .ethereumMainnet:
				return .Mainnet
			case .ethereumGoerli:
				return .Goerli
			case .ethereumRinkeby:
				return .Rinkeby
			case .ethereumRopsten:
				return .Ropsten
			case .ethereumKovan:
				return .Kovan
			default:
				let bigint = BigUInt(self.rawValue) ?? 0
				return .Custom(networkID: bigint)
			}
		}
	}
}

/*
 MARK: —————————————————————————————————— ChainToken ——————————————————————————————————————
 */
public class ChainToken: Codable {
	public var decimals: Int32 = 18
	public var logoUrl: URL?
	public var name: String?
	public var symbol: String?
	public weak var chain: Chain?
}


public extension EthereumAddress {
	var data32: Data {
		Data(repeating: 0, count: 32 - addressData.count) + addressData
	}
}

public extension String {
	func ethereumAddress() -> EthereumAddress? {
		return EthereumAddress(self)
	}
	
	var data32:Data {
		return Data(ethHex:self)
	}
	
	func toHexData() -> Data {
		return Data(hex: self)
	}
	
	func etherAddressDisplay() -> Self {
		self.replacingRange(indexFromStart: 8, indexFromEnd: 4)
	}
	
	func replacingRange(indexFromStart: Int, indexFromEnd: Int, replacing: String = "...") -> Self {
		return self.replacingOccurrences(of: self.dropFirst(indexFromStart).dropLast(indexFromEnd), with: replacing)
	}
	
	func replacingRange2(indexFromStart: Int, indexFromEnd: Int, replacing: String = "...") -> Self {
		return String(self.prefix(indexFromStart)) + replacing + String(self.suffix(indexFromEnd))
	}
	
}

