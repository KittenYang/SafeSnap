// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

/// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md
import Foundation
import BigInt
import CryptoSwift
import web3swift

//https://github.com/AlphaWallet/alpha-wallet-ios/blob/41ad92e3b9301b9f98f2bd2e0daecae881b4d218/modules/AlphaWalletFoundation/AlphaWalletFoundation/EtherClient/EIP712TypedData.swift
/// A struct represents EIP712 type tuple
public struct EIP712Type: Codable {
	let name: String
	let type: String
}

/// A struct represents EIP712 TypedData
public struct EIP712TypedData: Codable {
	public let types: [String: [EIP712Type]]
	public let primaryType: String
	public let domain: JSON
	public let message: JSON

	public var domainName: String {
		switch domain {
		case .object(let dictionary):
			switch dictionary["name"] {
			case .string(let value):
				return value
			case .array, .object, .number, .bool, .null, .none:
				return ""
			}
		case .array, .string, .number, .bool, .null:
			return ""
		}
	}

	public var domainVerifyingContract: web3swift.EthereumAddress? {
		switch domain {
		case .object(let dictionary):
			switch dictionary["verifyingContract"] {
			case .string(let value):
				//We need it to be unchecked because test sites like to use 0xCcc..cc
				return web3swift.EthereumAddress(value)
			case .array, .object, .number, .bool, .null, .none:
				return nil
			}
		case .array, .string, .number, .bool, .null:
			return nil
		}
	}
}

extension EIP712TypedData {
	/// Sign-able hash for an `EIP712TypedData`
	var digest: Data {
		let ERC191MagicByte = Data([0x19])
		let ERC191Version1Byte = Data([0x01])
		return Crypto.hash(
			[ERC191MagicByte,
			 ERC191Version1Byte,
			 hashStruct(domain, type: "EIP712Domain"),
			 hashStruct(message, type: primaryType)
			].reduce(Data()) { $0 + $1 }
		)
	}

	/// Recursively finds all the dependencies of a type
	public func findDependencies(primaryType: String, dependencies: Set<String> = Set<String>()) -> Set<String> {
		let primaryType = primaryType.dropTrailingSquareBrackets
		var found = dependencies
		guard !found.contains(primaryType),
			let primaryTypes = types[primaryType] else {
				return found
		}
		found.insert(primaryType)
		for type in primaryTypes {
			findDependencies(primaryType: type.type, dependencies: found)
				.forEach { found.insert($0) }
		}
		return found
	}

	/// Encode a type of struct
	func encodeType(primaryType: String) -> Data {
		var depSet = findDependencies(primaryType: primaryType)
		depSet.remove(primaryType)
		let sorted = [primaryType] + Array(depSet).sorted()
		let encoded = sorted.compactMap { type in
			guard let values = types[type] else { return nil }
			let param = values.map { "\($0.type) \($0.name)" }.joined(separator: ",")
			return "\(type)(\(param))"
		}.joined()
		return encoded.data(using: .utf8) ?? Data()
	}

	/// Encode an instance of struct
	///
	/// Implemented with `ABIEncoder` and `ABIValue`
	func encodeData(data: JSON, type: String) -> Data {
		let encoder = ABIEncoder()
		var values: [ABIValue] = []
		do {
			if let valueTypes = types[type] {
				for field in valueTypes {
					guard let value = data[field.name] else { continue }
					if let encoded = try encodeField(value: value, type: field.type) {
						values.append(encoded)
					}
				}
			}
			try encoder.encode(tuple: values)
		} catch {
			//no op
		}
		return encoder.data
	}

	func encodeField(value: JSON, type: String) throws -> ABIValue? {
		if isStruct(type) {
			let nestEncoded = hashStruct(value, type: type)
			return try ABIValue(nestEncoded, type: .bytes(32))
			//Can't check for "[]" because we want to support static arrays: Type[n]
		} else if let indexOfOpenBracket = type.firstIndex(of: "["), type.hasSuffix("]"), case let .array(elements) = value {
			var encodedElements: Data = .init()
			let elementType = String(type[type.startIndex..<indexOfOpenBracket])
			for each in elements {
				if let value = try encodeField(value: each, type: elementType) {
					let encoder = ABIEncoder()
					try encoder.encode(value)
					encodedElements += encoder.data
				}
			}
			return try ABIValue(Crypto.hash(encodedElements), type: .bytes(32))
		} else if let value = makeABIValue(data: value, type: type) {
			return value
		} else {
			return nil
		}
	}

	/// Helper func for `encodeData`
	private func makeABIValue(data: JSON?, type: String) -> ABIValue? {
		if type == "string", let value = data?.stringValue, let valueData = value.data(using: .utf8) {
			return try? ABIValue(Crypto.hash(valueData), type: .bytes(32))
		} else if type == "bytes", let value = data?.stringValue {
			let data = Data(_hex: value.drop0x)
			return try? ABIValue(Crypto.hash(data), type: .bytes(32))
		} else if type == "bool", let value = data?.boolValue {
			return try? ABIValue(value, type: .bool)
			//Using `AlphaWallet.Address(uncheckedAgainstNullAddress:)` instead of `AlphaWallet.Address(string:)` because EIP712v3 test pages like to use the contract 0xb...b which fails the burn address check
		} else if type == "address", let value = data?.stringValue, let address = web3swift.EthereumAddress(value) {
			return try? ABIValue(address, type: .address)
		} else if type.starts(with: "uint") {
			let size = parseIntSize(type: type, prefix: "uint")

			guard size > 0 else { return nil }

			if let numberValue = data?.numberValue {
				switch numberValue {
				case let .int(value):
					return try? ABIValue(value, type: .uint(bits: size))
				case let .double(value):
					return try? ABIValue(Int(value), type: .uint(bits: size))
				}
			} else if let value = data?.stringValue,
					  let bigInt = BigUInt(value: value) {
				return try? ABIValue(bigInt, type: .uint(bits: size))
			}
		} else if type.starts(with: "int") {
			let size = parseIntSize(type: type, prefix: "int")

			guard size > 0 else { return nil }

			if let numberValue = data?.numberValue {
				switch numberValue {
				case let .int(value):
					return try? ABIValue(value, type: .uint(bits: size))
				case let .double(value):
					return try? ABIValue(Int(value), type: .uint(bits: size))
				}
			} else if let value = data?.stringValue,
					  let bigInt = BigInt(value: value) {
				return try? ABIValue(bigInt, type: .int(bits: size))
			}
		} else if type.starts(with: "bytes") {
			if let length = Int(type.dropFirst("bytes".count)), let value = data?.stringValue {
				if value.starts(with: "0x"){
					let hex = Data(hex: value)
					return try? ABIValue(hex, type: .bytes(length))
				} else {
					return try? ABIValue(Data(Array(value.utf8)), type: .bytes(length))
				}
			}
		}
		return nil
	}

	/// Helper func for encoding uint / int types
	private func parseIntSize(type: String, prefix: String) -> Int {
		guard type.starts(with: prefix),
			let size = Int(type.dropFirst(prefix.count)) else {
			return -1
		}

		if size < 8 || size > 256 || size % 8 != 0 {
			return -1
		}
		return size
	}

	private func isStruct(_ fieldType: String) -> Bool {
		types[fieldType] != nil
	}

	private func hashStruct(_ data: JSON, type: String) -> Data {
		return Crypto.hash(typeHash(type) + encodeData(data: data, type: type))
	}

	private func typeHash(_ type: String) -> Data {
		return Crypto.hash(encodeType(primaryType: type))
	}
}


class Crypto {
	static func hash(_ data: Data) -> Data {
		return data.sha3(.keccak256)
	}
}
