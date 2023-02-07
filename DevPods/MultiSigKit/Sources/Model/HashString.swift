//
//  HashString.swift
//  family-dao
//
//  Created by KittenYang on 8/3/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public struct HashString: Hashable, Codable {
	let hash: Data
	
	enum HashStringError: String, Error {
		case wrongHashLength = "Hash length should be 32 bytes"
	}
	
	init(_ hash: Data) {
		self.hash = hash
	}
	
	init(hex: String) throws {
		let data = Data(hex: hex)
		guard data.count == 32 else { throw HashStringError.wrongHashLength }
		self.hash = data
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let string = try container.decode(String.self)
		try self.init(hex: string)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(hash.toHexStringWithPrefix())
	}
	
}

extension HashString: CustomStringConvertible {
	public var description: String {
		hash.toHexStringWithPrefix()
	}
}

