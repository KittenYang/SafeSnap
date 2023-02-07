//
//  AlscJSONKey.swift
//  AlscCodableJSON
//
//  Created by KittenYang on 6/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public struct AlscJSONKey : CodingKey {
	
	public var stringValue: String
	
	public var intValue: Int?
	
	public init?(stringValue: String) {
		self.stringValue = stringValue
		self.intValue = nil
	}
	
	public init?(intValue: Int) {
		self.stringValue = "\(intValue)"
		self.intValue = intValue
	}
	
	public init(stringValue: String, intValue: Int?) {
		self.stringValue = stringValue
		self.intValue = intValue
	}
	
	init(index: Int) {
		self.stringValue = "Index \(index)"
		self.intValue = index
	}
	
	static let `super` = AlscJSONKey(stringValue: "super")!
}
