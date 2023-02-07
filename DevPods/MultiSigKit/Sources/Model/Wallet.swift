//
//  Wallet.swift
//  family-dao
//
//  Created by KittenYang on 6/26/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift
import Defaults

public struct Wallet:Codable, Defaults.Serializable, Equatable {
	public let address: String
	public let data: Data
	public var name: String
	public let mnemonics: String?
	/// 是从助记词生成的还是私钥生成的；true: 助记词；false: 私钥
	public let isHD: Bool

	public lazy var keystore: AbstractKeystore = {
		if isHD {
			return BIP32Keystore(data)!
		} else {
			return EthereumKeystoreV3(data)!
		}
	}()
	
	public lazy var keystoreManager: KeystoreManager? = {
		switch keystore {
		case let ks as BIP32Keystore:
			return KeystoreManager([ks])
		case let ks as EthereumKeystoreV3:
			return KeystoreManager([ks])
		case let ks as PlainKeystore:
			return KeystoreManager([ks])
		default:
			return nil
		}
	}()
	
	public var ethereumAddress: EthereumAddress? {
		guard let ethereumAddress = EthereumAddress(address) else {
			return nil
		}
		return ethereumAddress
	}
	
	public lazy var privateKey: String? = {
		if let _private = try? getPrivateKey(password: WalletManager.currentPwd) {
			return _private
		}
		return nil
	}()
	
	mutating func getPrivateKey(password: String) throws -> String? {
		guard let ethereumAddress = ethereumAddress else {
			return nil
		}
		do {
			return try keystoreManager?.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
		} catch let error {
			debugPrint("getPrivateKey Error: \(error)")
			return nil
		}
	}
}

public extension Wallet {
	static var preview: Wallet = {
		return Wallet(address: "0x8c25Ea1f2740CB1E66ad25252247177bc1ec701c", data: Data(), name: "测试账户", mnemonics: "dasd 22 212 22 asd 43543 543 dasd 453 545 sfdf fsdf 4432", isHD: true)
	}()
	
	static var preview2: Wallet = {
		return Wallet(address: "0x5662250d7c9c9130a7c5799da350778a54e2bc9e", data: Data(), name: "小可爱", mnemonics: "dasd 22 212 22 asd 43543 543 dasd 453 545 sfdf fsdf 4432", isHD: false)
	}()
	
	static var preview3: Wallet = {
		return Wallet(address: "0x36A7784B4C97f77D32e754Df78183df9Ad8a7604", data: Data(), name: "小可爱", mnemonics: "dasd 22 212 22 asd 43543 543 dasd 453 545 sfdf fsdf 4432", isHD: false)
	}()
}

//struct HDKey {
//	let name: String?
//	let address: String
//}
//
//struct ERC20Token {
//	var name: String
//	var address: String
//	var decimals: String
//	var symbol: String
//}

