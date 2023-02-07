//
//  AlscJSONKeysConverter.swift
//  AlscCodableJSON
//
//  Created by KittenYang on 6/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

struct AlscJSONKeysConverter {
	let container: [[String]: String]
	
	init(_ container: [[String]: String]) {
		self.container = container
	}
	
	func callAsFunction(_ codingPath: [CodingKey]) -> CodingKey {
		guard !codingPath.isEmpty else { return AlscJSONKey.super }
		
		let stringKeys = codingPath.map { $0.stringValue }
		
		guard container.keys.contains(stringKeys) else { return codingPath.last! }
		
		return AlscJSONKey(stringValue: container[stringKeys]!, intValue: nil)
	}
}

