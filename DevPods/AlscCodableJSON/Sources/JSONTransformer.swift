//
//  JSONTransformer.swift
//  AlscCodableJSON
//
//  Created by KittenYang on 6/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public protocol JSONTransformer {
	
	func transform(_ decoder: AlscDecoder) throws -> Bool
	
	func transform(_ decoder: AlscDecoder) throws -> Int
	
	func transform(_ decoder: AlscDecoder) throws -> Int8
	
	func transform(_ decoder: AlscDecoder) throws -> Int16
	
	func transform(_ decoder: AlscDecoder) throws -> Int32
	
	func transform(_ decoder: AlscDecoder) throws -> Int64
	
	func transform(_ decoder: AlscDecoder) throws -> UInt
	
	func transform(_ decoder: AlscDecoder) throws -> UInt8
	
	func transform(_ decoder: AlscDecoder) throws -> UInt16
	
	func transform(_ decoder: AlscDecoder) throws -> UInt32
	
	func transform(_ decoder: AlscDecoder) throws -> UInt64
	
	func transform(_ decoder: AlscDecoder) throws -> Float
	
	func transform(_ decoder: AlscDecoder) throws -> Double
	
	func transform(_ decoder: AlscDecoder) throws -> String
	
	func transform(_ decoder: AlscDecoder) throws -> Date
	
	func transform(_ decoder: AlscDecoder) throws -> Data
	
	func transform(_ decoder: AlscDecoder) throws -> URL
	
	func transform(_ decoder: AlscDecoder) throws -> Decimal
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> Bool?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> Int?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> Int8?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> Int16?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> Int32?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> Int64?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> UInt?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> UInt8?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> UInt16?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> UInt32?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> UInt64?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> Float?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> Double?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> String?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> Date?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> Data?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> URL?
	
	func transformIfPresent(_ decoder: AlscDecoder) throws -> Decimal?
	
	func transformIfPresent<T: Decodable>(_ decoder: AlscDecoder) throws -> T?
}

// MARK: Helper
private extension JSONTransformer {
	func _losslessStringTypeSafeTransfer<T>(type: T.Type, decoder: AlscDecoder) throws -> T where T: Defaultable & LosslessStringConvertible {
		guard !decoder.decodeNil() else { return T.defaultValue }
		
		// string -> int
		if let stringValue = try decoder.decodeIfPresent(String.self), let result = T(stringValue) {
			return result
		}
		
		// bool -> int
		if let boolValue = try decoder.decodeIfPresent(Bool.self), let result = T(boolValue ? "1" : "0") {
			return result
		}
		
		// float -> int
		if let floatValue = try decoder.decodeIfPresent(Float.self), let result = T("\(floatValue)") {
			return result
		}
		
		// double -> int
		if let doubleValue = try decoder.decodeIfPresent(Double.self), let result = T("\(doubleValue)") {
			return result
		}
		
		return T.defaultValue
	}
	
}

// MARK: 默认转换实现类。外部如果修改其中个别逻辑，只需要继承 Transformer 基类，重写对应方法
open class Transformer: JSONTransformer {
	public init() {}
	
	// MARK: non-optional Type
	// 布尔值容错+默认值
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> Bool {
		// null -> false
		if decoder.decodeNil() {
			return false
		}
		
		// int -> bool
		if let intValue = try decoder.decodeIfPresent(Int64.self) {
			return intValue != 0
		}
		if let intValue = try decoder.decodeIfPresent(Int.self) {
			return intValue != 0
		}
		
		// double -> bool
		if let intValue = try decoder.decodeIfPresent(Double.self) {
			return intValue != 0
		}
		if let intValue = try decoder.decodeIfPresent(Float.self) {
			return intValue != 0
		}
		
		// string -> bool
		if let strValue = try decoder.decodeIfPresent(String.self) {
			return (strValue.lowercased() as NSString).boolValue
		}
		
		return Bool.defaultValue
	}
	
	// Int值容错+默认值
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> Int {
		return try _losslessStringTypeSafeTransfer(type: Int.self, decoder: decoder)
	}
	
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> Int8 {
		return try _losslessStringTypeSafeTransfer(type: Int8.self, decoder: decoder)
	}
	
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> Int16 {
		return try _losslessStringTypeSafeTransfer(type: Int16.self, decoder: decoder)
	}
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> Int32 {
		return try _losslessStringTypeSafeTransfer(type: Int32.self, decoder: decoder)
	}
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> Int64 {
		return try _losslessStringTypeSafeTransfer(type: Int64.self, decoder: decoder)
	}
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> UInt {
		return try _losslessStringTypeSafeTransfer(type: UInt.self, decoder: decoder)
	}
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> UInt8 {
		return try _losslessStringTypeSafeTransfer(type: UInt8.self, decoder: decoder)
	}
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> UInt16 {
		return try _losslessStringTypeSafeTransfer(type: UInt16.self, decoder: decoder)
	}
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> UInt32 {
		return try _losslessStringTypeSafeTransfer(type: UInt32.self, decoder: decoder)
	}
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> UInt64 {
		return try _losslessStringTypeSafeTransfer(type: UInt64.self, decoder: decoder)
	}
	
	// 浮点值容错+默认值
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> Float {
		return try _losslessStringTypeSafeTransfer(type: Float.self, decoder: decoder)
	}
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> Double {
		return try _losslessStringTypeSafeTransfer(type: Double.self, decoder: decoder)
	}
	
	
	// String 值容错+默认值
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> String {
		guard !decoder.decodeNil() else { return String.defaultValue }
		
		//int -> string
		if let intValue = try decoder.decodeIfPresent(Int.self) {
			return String(intValue)
		} else if let doubleValue = try decoder.decodeIfPresent(Double.self) {
			//double -> string
			return String(doubleValue)
		} else if let boolValue = try decoder.decodeIfPresent(Bool.self) {
			//bool -> string
			return String(boolValue)
		}
		
		return String.defaultValue
	}
	
	
	// Date 值默认值+容错
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> Date {
		guard let decoder = decoder as? _AlscJSONDecoder else { return Date.defaultValue }
		
		var tm: TimeInterval?
		//int -> Date
		if let intValue = try decoder.decodeIfPresent(Int.self) {
			tm = TimeInterval(intValue)
		} else if let doubleValue = try decoder.decodeIfPresent(Double.self) {
			//double -> Date
			tm = doubleValue
		} else if let strValue = try decoder.decodeIfPresent(String.self), let doubleValue = Double(strValue)  {
			//string -> Date
			tm = doubleValue
		}
		if let tm = tm {
			var intTm = Int(tm)
			if "\(intTm)".count - "\(Int(Date().timeIntervalSince1970))".count != 0 {
				intTm = (intTm/1000)
			}
			return Date(timeIntervalSince1970: TimeInterval(intTm))
		}
		
		return Date.defaultValue(for: decoder.options.dateDecodingStrategy)
	}
	
	// Data 值默认值
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> Data {
		return Data.defaultValue
	}
	
	// URL 值默认值+容错
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> URL {
		guard !decoder.decodeNil() else { return URL.defaultValue }
		
		//string -> URL
		if let strValue = try decoder.decodeIfPresent(String.self)?.lowercased() {
			return URL(string: strValue) ?? URL(fileURLWithPath: strValue)
		}
		
		return URL.defaultValue
	}
	
	// Decimal 值默认值
	@inline(__always)
	open func transform(_ decoder: AlscDecoder) throws -> Decimal {
		return Decimal.defaultValue
	}
	
	
	// MARK: Optional Type
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> Bool? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> Int? {
		guard !decoder.decodeNil() else {
			return Optional.defaultValue
			/*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> Int8? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> Int16? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> Int32? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> Int64? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> UInt? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> UInt8? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> UInt16? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> UInt32? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> UInt64? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> Float? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> Double? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> String? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		
		//json 有值，优先读取 json 里的值，并做类型容错处理
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> Date? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> Data? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> URL? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent(_ decoder: AlscDecoder) throws -> Decimal? {
		guard !decoder.decodeNil() else { return Optional.defaultValue /*json 无值，走用户设置的默认值*/ }
		return try? transform(decoder)
	}
	
	@inline(__always)
	open func transformIfPresent<T: Decodable>(_ decoder: AlscDecoder) throws -> T? {
		guard !decoder.decodeNil() else {
			return _getDefaultValue(nil)
			/*json 无值，走用户设置的默认值*/ }
		return nil
	}
	
}
