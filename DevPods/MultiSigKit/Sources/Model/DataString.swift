//
//  DataString.swift
//  family-dao
//
//  Created by KittenYang on 8/3/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import BigInt

public typealias UInt256 = BigUInt
public typealias Int256 = BigInt

//struct DataString: Hashable, Codable {
//	let data: Data
//
//	init(_ data: Data) {
//		self.data = data
//	}
//
//	init(hex: String) {
//		self.data = Data(hex: hex)
//	}
//
//	init(from decoder: Decoder) throws {
//		let container = try decoder.singleValueContainer()
//		let string = try container.decode(String.self)
//		data = Data(hex: string)
//	}
//
//	func encode(to encoder: Encoder) throws {
//		var container = encoder.singleValueContainer()
//		try container.encode(data.toHexStringWithPrefix())
//	}
//
//}
//
//extension DataString: ExpressibleByStringLiteral {
//	init(stringLiteral value: StringLiteralType) {
//		self.init(Data(ethHex: value))
//	}
//}
//
//extension DataString: CustomStringConvertible {
//	var description: String {
//		data.toHexStringWithPrefix()
//	}
//}

public extension UInt256 {
	var data32: Data {
		Data(ethHex: String(self, radix: 16)).leftPadded(to: 32).suffix(32)
	}
}

public extension Int {
	var data32: Data {
		Data(ethHex: String(UInt256(self), radix: 16)).leftPadded(to: 32).suffix(32)
	}
}

public extension UInt {
	var data32: Data {
		Data(ethHex: String(UInt256(self), radix: 16)).leftPadded(to: 32).suffix(32)
	}
}

public extension TimeInterval {
	var data32: Data {
		Data(ethHex: String(UInt256(self), radix: 16)).leftPadded(to: 32).suffix(32)
	}
}
