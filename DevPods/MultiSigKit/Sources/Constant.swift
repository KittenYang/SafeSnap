//
//  Constant.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/6/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift
import BigInt

public struct Constant {
	
	public static let AppContainerID = "AppContainer"
	public static let AppContainerSheetID = "AppContainerSheetID"
	
	public static let gnosisSafeBaseAPI = "https://safe-client.safe.global" //"https://safe-client.gnosis.io"
	
	public static func ethHashAvatar(address: String, length:CGFloat) -> URL {
		URL(string:"https://cdn.stamp.fyi/token/\(address)?s=\(length)")!
	}
	
	// 发币工厂合约，通过 scafford deploy
	public static let TokenFactoryAddress = "0xB628b362f872f5ed34cefa500Fc7ad541dEC83eb"
//	rinkeby: "0xB628b362f872f5ed34cefa500Fc7ad541dEC83eb"
//  goerli : "0xB628b362f872f5ed34cefa500Fc7ad541dEC83eb"
	
	public static let ENSName721TokenAddress = "0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85"
	
	public static let defaultTokenDecimals: Int = 18
	
	public static let DefaultEIP712SafeAppTxTypeHash =
			Data(ethHex: "0xbb8310d486368db6bd6f849402fdd73ad53d316b5a4b2644ad6efe0f941286d8")
	
	enum DomainSeparatorTypeHash {
		static let v1_1_1 = Data(ethHex: "0x035aff83d86937d35b32e04f0ddc6ff469290eef2f1b692d8a815c89404d4749")
		static let v1_3_0 = Data(ethHex: "0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218")
	}
	
	public static func domainData(for safe: EthereumAddress, chainId: String) -> Data {
		let chainIdData = UInt256(chainId, radix: 10)!.data32
		return DomainSeparatorTypeHash.v1_3_0 + chainIdData + safe.data32
	}
	
}

public extension EthereumAddress {
	static let ethZero = EthereumAddress("0x0000000000000000000000000000000000000000")!
	static let preview1 = EthereumAddress("0x1111111111111111111111111111111111111111")!
	static let preview2 = EthereumAddress("0x2222222222222222222222222222222222222222")!
}
