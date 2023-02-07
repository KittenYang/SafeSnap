//
//  EIP721+String.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/18/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

extension String {
	var dropTrailingSquareBrackets: String {
		if let i = firstIndex(of: "["), hasSuffix("]") {
			return String(self[startIndex..<i])
		} else {
			return self
		}
	}
	
	public var drop0x: String {
		if count > 2 && substring(with: 0..<2) == "0x" {
			return String(dropFirst(2))
		}
		return self
	}
	
	internal var add0x: String {
		if hasPrefix("0x") {
			return self
		} else {
			return "0x" + self
		}
	}
	
	internal func substring(from: Int) -> String {
		let fromIndex = index(from: from)
		return String(self[fromIndex...])
	}
	
	internal func substring(to: Int) -> String {
		let toIndex = index(from: to)
		return String(self[..<toIndex])
	}
	
	internal func substring(with r: Range<Int>) -> String {
		let startIndex = index(from: r.lowerBound)
		let endIndex = index(from: r.upperBound)
		return String(self[startIndex..<endIndex])
	}
	
	internal func index(from: Int) -> Index {
		return index(startIndex, offsetBy: from)
	}
}

extension StringProtocol {
	func chunked(into size: Int) -> [SubSequence] {
		var chunks: [SubSequence] = []
		
		var i = startIndex
		
		while let nextIndex = index(i, offsetBy: size, limitedBy: endIndex) {
			chunks.append(self[i ..< nextIndex])
			i = nextIndex
		}
		
		let finalChunk = self[i ..< endIndex]
		
		if finalChunk.isEmpty == false {
			chunks.append(finalChunk)
		}
		
		return chunks
	}
}


extension Data {
	//NOTE: as minimum chunck is as min time it will be executed, during testing we found that optimal chunck size is 100, but seems it could be optimized more, execution time (0.2 seconds), pretty good and doesn't block UI
	public init(_hex value: String) {
		let chunkSize: Int = 100
		if value.count > chunkSize {
			self = value.chunked(into: chunkSize).reduce(NSMutableData()) { result, chunk -> NSMutableData in
				let part = Data.data(from: String(chunk))
				result.append(part)
				
				return result
			} as Data
		} else {
			self = Data.data(from: value)
		}
	}
	
	//NOTE: renamed to `_hex` because CryptoSwift has its own implementation of `.init(hex:)` that instantiates Data() object with additionaly byte at the end. That brokes `signing` in app. Not sure that this is good name.
	private static func data(from hex: String) -> Data {
		let len = hex.count / 2
		var data = Data(capacity: len)
		for i in 0..<len {
			let from = hex.index(hex.startIndex, offsetBy: i*2)
			let to = hex.index(hex.startIndex, offsetBy: i*2 + 2)
			let bytes = hex[from ..< to]
			if var num = UInt8(bytes, radix: 16) {
				data.append(&num, count: 1)
			}
		}
		return data
	}
}
