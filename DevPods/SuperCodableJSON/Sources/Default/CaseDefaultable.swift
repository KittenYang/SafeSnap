//
//  CaseDefaultable.swift
//  SuperCodableJSON
//
//  Created by KittenYang on 6/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public protocol EnumDefaultable: RawRepresentable, Defaultable {
	
	// 设置全局枚举默认值
	static var globalDefaultCase: Self { get }

}

public extension EnumDefaultable {
	static var defaultValue: Self {
		_getDefaultValue(globalDefaultCase)
	}
}


public extension EnumDefaultable where Self: Decodable, Self.RawValue: Decodable {
	
	init(from decoder: Decoder) throws {
		guard let _decoder = decoder as? _SuperJSONDecoder else {
			let container = try decoder.singleValueContainer()
			let rawValue = try container.decode(RawValue.self)
			self = Self.init(rawValue: rawValue) ?? Self.defaultValue
			return
		}
		
		self = try _decoder.decodeCase(Self.self)
	}
}

private extension _SuperJSONDecoder {
	
	func decodeCase<T>(_ type: T.Type) throws -> T
	where T: EnumDefaultable,
				T: Decodable,
				T.RawValue: Decodable
	{
		guard !decodeNil(), !storage.containers.isEmpty, storage.topContainer is T.RawValue else {
			// json value == null | value not found
			return T.defaultValue
		}
		
		if let number = storage.topContainer as? NSNumber,
			 (number === kCFBooleanTrue || number === kCFBooleanFalse) {
			guard let rawValue = number.boolValue as? T.RawValue else {
				return T.defaultValue
			}
			
			return T.init(rawValue: rawValue) ?? T.defaultValue
		}
		
		let rawValue = try decode(T.RawValue.self)
		return T.init(rawValue: rawValue) ?? T.defaultValue
	}
}

