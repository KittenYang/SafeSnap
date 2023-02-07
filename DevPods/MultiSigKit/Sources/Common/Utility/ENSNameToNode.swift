//
//  ENSNameToNode.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/10/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import CryptoSwift

public extension String {
	// Unicode to String
	func utf8DecodedString()-> String {
		let data = self.data(using: .utf8)
		let message = String(data: data!, encoding: .nonLossyASCII) ?? ""
		return message
	}
	
	// String to Unicode
	func utf8EncodedString()-> String {
		let messageData = self.data(using: .nonLossyASCII)
		let text = String(data: messageData!, encoding: .utf8) ?? ""
		return text
	}

	func namehash() -> String {
		var node = ""
		for _ in 0..<32 {
			node += "00"
		}
		let name = self.utf8EncodedString()
		let labels = name.split(separator: ".")
		for label in labels.reversed() {
			let labelSha = String(label).sha3(.keccak256)
			node = (node + labelSha).toHexData().sha3(.keccak256).toHexString()
		}
		return node.add0xPrefix()
	}
}

public extension URL {
	func snapshotURLifIsTestnet(chain:Chain.ChainID, prefix testPrefix:String = "testnet") -> URL {
		guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true),
			  var host = components.host else {
			return self
		}
		
		if chain != .ethereumMainnet {
			if !host.contains(testPrefix) {
				host = testPrefix + "." + host
			}
			//			URL(string: "https://testnet.snapshot.org")!
			components.host = host
			return components.url ?? self
		}
		
		return self
	}
}

