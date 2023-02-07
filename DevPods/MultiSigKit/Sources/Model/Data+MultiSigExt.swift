//
//  Data+MultiSigExt.swift
//  family-dao
//
//  Created by KittenYang on 8/3/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import CryptoSwift
import web3swift
import BigInt

// MARK: - Hex String to Data conversion
public extension Data {
	
	/// Creates data from hex string, padding to even byte character count from the left with 0.
	/// For example, "0x1" will become "0x01".
	///
	/// - Parameter ethHex: hex string.
	init(ethHex: String) {
		var value = ethHex
		while value.hasPrefix("0x") || value.hasPrefix("0X") { value = String(value.dropFirst(2)) }
		// if ethHex is not full byte, Data(hex:) adds nibble at the end, but we need it in the beginning
		let paddingToByte = value.count % 2 == 1 ? "0" : ""
		value = paddingToByte + value
		self.init(hex: value)
	}
	
	init?(exactlyHex hex: String) {
		var value = hex.lowercased()
		if value.hasPrefix("0x") {
			value.removeFirst(2)
		}
		guard value.rangeOfCharacter(from: CharacterSet.hexadecimals.inverted) == nil else {
			return nil
		}
		self.init(hex: hex)
	}
	
	func toHexStringWithPrefix() -> String {
		"0x" + toHexString()
	}
	
	/// Pads data with `value` from the left to total width of `count`
	///
	/// - Parameters:
	///   - count: total padded with=
	///   - value: padding value, default is 0
	/// - Returns: padded data of size `count`
	func leftPadded(to count: Int, with value: UInt8 = 0) -> Data {
		if self.count >= count { return self }
		return Data(repeating: value, count: count - self.count) + self
	}
	
	func rightPadded(to count: Int, with value: UInt8 = 0) -> Data {
		if self.count >= count { return self }
		return self + Data(repeating: value, count: count - self.count)
	}
	
	func endTruncated(to count: Int) -> Data {
		guard self.count > count else { return self }
		return prefix(count)
	}
	
	init?(randomOfSize count: Int) {
		var bytes: [UInt8] = .init(repeating: 0, count: count)
		let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		guard result == errSecSuccess else {
			return nil
		}
		self.init(bytes)
	}
}

extension CharacterSet {
	static var hexadecimalNumbers: CharacterSet {
		return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	}
	
	static var hexadecimalLetters: CharacterSet {
		return ["a", "b", "c", "d", "e", "f", "A", "B", "C", "D", "E", "F"]
	}
	
	static var hexadecimals: CharacterSet {
		return hexadecimalNumbers.union(hexadecimalLetters)
	}
}

struct EthHasher {
	static func hash(_ msg: Data) -> Data {
		let result = SHA3(variant: .keccak256).calculate(for: Array(msg))
		return Data(result)
	}
	
	static func hash(_ msg: String) -> Data {
		hash(msg.data(using: .utf8)!)
	}
}


extension Web3Signer {
	/// data 不带 Ethereum Signed Message 前缀的签名
	public static func signPersonalMessage2(_ personalMessage: Data,
											keystore: AbstractKeystore,
											account: EthereumAddress,
											password: String,
											useExtraEntropy: Bool = false) throws -> Data? {
		var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
		
		defer { Data.zero(&privateKey) }
		//		guard let hash = Web3.Utils.hashPersonalMessage(personalMessage) else { return nil }
		let (compressedSignature, _) = SECP256K1.signForRecovery(hash: personalMessage, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
		return compressedSignature
	}
	
	public static func signTypedMessage(typedData: EIP712TypedData, wallet: Wallet?) -> String? {
		guard var wallet = wallet,
			  let account = wallet.ethereumAddress else {
			return nil
		}
		
		let typedOBJ = typedData
		
		var signatureString: String?
		
		do {
			let sig = try Web3Signer.signPersonalMessage2(typedOBJ.digest, keystore: wallet.keystore, account: account, password: WalletManager.currentPwd, useExtraEntropy: false)
			signatureString = sig?.toHexStringWithPrefix()
			print("\(signatureString ?? "nil")\n============== 👆🏻signatureString👆🏻 ============")
			return signatureString
		} catch  {
			debugPrint(error)
			return nil
		}
	}
}

public extension String {
	func convertToBigUInt() -> BigUInt? {
		return Web3.Utils.parseToBigUInt(self, decimals: WalletManager.currentFamilyTokenDecimals)
	}
}

public extension BigUInt {
	func SimplifiedString(decimals: Int = WalletManager.currentFamilyTokenDecimals) -> String {
//		Web3.Utils.formatToEthereumUnits(ownerBalance)
		return Web3.Utils.formatToPrecision(self, numberDecimals: decimals) ?? self.description
	}
}

public extension BigInt {
	func SimplifiedString(decimals: Int = WalletManager.currentFamilyTokenDecimals) -> String {
		return Web3.Utils.formatToPrecision(self, numberDecimals: decimals) ?? self.description
	}
}
