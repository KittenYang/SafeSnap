//
//  Defaultable.swift
//  SuperCodableJSON
//
//  Created by KittenYang on 6/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public protocol Defaultable {
	static var defaultValue: Self { get }
}

func _getDefaultValue<T>(_ defaultValue:T) -> T /*where T: Defaultable*/ {
	if Thread.current.SupersCurrentDecoding {
		return Thread.current.SupersWrapperInfos.last?.first?.defaultValue as? T ?? defaultValue
	} else {
		return defaultValue
	}
}

extension Array: Defaultable {
	public static var defaultValue: Array {
		return _getDefaultValue([])
	}
}

extension Dictionary: Defaultable where Key == String {
	public static var defaultValue: Dictionary {
		return _getDefaultValue([:])
	}
}

extension Optional: Defaultable where Wrapped: Defaultable {
	public static var defaultValue: Optional<Wrapped> {
		return _getDefaultValue(nil)
	}
}

extension Bool: Defaultable {
	public static var defaultValue: Bool {
		return _getDefaultValue(false)
	}
}

extension Int: Defaultable {
	public static var defaultValue: Int {
		return _getDefaultValue(Self(0))
	}
}

extension Int8: Defaultable {
	public static var defaultValue: Int8 {
		return _getDefaultValue(Self(0))
	}
}

extension Int16: Defaultable {
	public static var defaultValue: Int16 {
		return _getDefaultValue(Self(0))
	}
}

extension Int32: Defaultable {
	public static var defaultValue: Int32 {
		return _getDefaultValue(Self(0))
	}
}

extension Int64: Defaultable {
	public static var defaultValue: Int64 {
		return _getDefaultValue(Self(0))
	}
}

extension UInt: Defaultable {
	public static var defaultValue: UInt {
		return _getDefaultValue(Self(0))
	}
}

extension UInt8: Defaultable {
	public static var defaultValue: UInt8 {
		return _getDefaultValue(Self(0))
	}
}

extension UInt16: Defaultable {
	public static var defaultValue: UInt16 {
		return _getDefaultValue(Self(0))
	}
}

extension UInt32: Defaultable {
	public static var defaultValue: UInt32 {
		return _getDefaultValue(Self(0))
	}
}

extension UInt64: Defaultable {
	public static var defaultValue: UInt64 {
		return _getDefaultValue(Self(0))
	}
}

extension Float: Defaultable {
	public static var defaultValue: Float {
		return _getDefaultValue(Self(0))
	}
}

extension Double: Defaultable {
	public static var defaultValue: Double {
		return _getDefaultValue(Self(0))
	}
}

extension String: Defaultable {
	public static var defaultValue: String {
		return _getDefaultValue("")
	}
}

extension Date: Defaultable {
	public static var defaultValue: Date {
		return _getDefaultValue(Date(timeIntervalSinceReferenceDate: 0))
	}
	
	static func defaultValue(for strategy: JSONDecoder.DateDecodingStrategy) -> Date {
		switch strategy {
		case .secondsSince1970, .millisecondsSince1970:
			return _getDefaultValue(Date(timeIntervalSince1970: 0))
		default:
			return defaultValue
		}
	}
}

extension Data: Defaultable {
	public static var defaultValue: Data {
		return _getDefaultValue(Data())
	}
}

extension Decimal: Defaultable {
	public static var defaultValue: Decimal {
		return _getDefaultValue(Decimal(0))
	}
}

extension URL: Defaultable {
	public static var defaultValue: URL {
		return _getDefaultValue(URL(fileURLWithPath: ""))
	}
}

