//
//  _SuperJSONDecoder+Decode.swift
//  SuperCodableJSON
//
//  Created by KittenYang on 6/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

extension _SuperJSONDecoder {
	
	func decodeAsDefaultValue<T: Decodable>() throws -> T {
		if let array = [] as? T {
			return array
		} else if let string = String.defaultValue as? T {
			return string
		} else if let bool = Bool.defaultValue as? T {
			return bool
		} else if let int = Int.defaultValue as? T {
			return int
		}else if let double = Double.defaultValue as? T {
			return double
		} else if let date = Date.defaultValue(for: options.dateDecodingStrategy) as? T {
			return date
		} else if let data = Data.defaultValue as? T {
			return data
		} else if let decimal = Decimal.defaultValue as? T {
			return decimal
		} else if let url = URL.defaultValue as? T {
			return url
		} else if let object = try? unbox([:], as: T.self) {
			return object
		}
		
		let context = DecodingError.Context(
			codingPath: codingPath,
			debugDescription: "Key: <\(codingPath)> cannot be decoded as default value.")
		throw DecodingError.dataCorrupted(context)
	}
}

// MARK: decode
extension _SuperJSONDecoder {
	
	func decode(as type: Date.Type) throws -> Date {
		if let date = try unbox(storage.topContainer, as: type) { return date }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return Date.defaultValue(for: options.dateDecodingStrategy)
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	func decode(as type: Data.Type) throws -> Data {
		if let data = try unbox(storage.topContainer, as: type) { return data }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return Data.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	func decode(as type: Decimal.Type) throws -> Decimal {
		if let decimal = try unbox(storage.topContainer, as: type) { return decimal }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return Decimal.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	func decode(as type: URL.Type) throws -> URL {
		if let url = try unbox(storage.topContainer, as: type) { return url }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return URL.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	
}

// MARK: decodeIfPresent
extension _SuperJSONDecoder {
	
	func decodeIfPresent<K: CodingKey>(
		_ value: Any,
		as type: Date.Type,
		forKey key: K) throws -> Date? {
			if let date = try unbox(value, as: type) { return date }
			
			switch options.valueNotFoundDecodingStrategy {
			case .throw:
				throw DecodingError.Keyed.keyNotFound(key, codingPath: codingPath)
			case .useDefaultValue:
				return nil
			case .custom(let transformer):
				storage.push(container: value)
				defer { storage.popContainer() }
				return try transformer.transformIfPresent(self)
			}
		}
	
	func decodeIfPresent<K: CodingKey>(
		_ value: Any,
		as type: Data.Type,
		forKey key: K) throws -> Data? {
			if let data = try unbox(value, as: type) { return data }
			
			switch options.valueNotFoundDecodingStrategy {
			case .throw:
				throw DecodingError.Keyed.keyNotFound(key, codingPath: codingPath)
			case .useDefaultValue:
				return nil
			case .custom(let transformer):
				storage.push(container: value)
				defer { storage.popContainer() }
				return try transformer.transformIfPresent(self)
			}
		}
	
	func decodeIfPresent<K: CodingKey>(
		_ value: Any,
		as type: URL.Type,
		forKey key: K) throws -> URL? {
			if let url = try unbox(value, as: type) { return url }
			
			switch options.valueNotFoundDecodingStrategy {
			case .throw:
				throw DecodingError.Keyed.keyNotFound(key, codingPath: codingPath)
			case .useDefaultValue:
				return nil
			case .custom(let transformer):
				storage.push(container: value)
				defer { storage.popContainer() }
				return try transformer.transformIfPresent(self)
			}
		}
	
	func decodeIfPresent<K: CodingKey>(
		_ value: Any,
		as type: Decimal.Type,
		forKey key: K) throws -> Decimal? {
			if let decimal = try unbox(value, as: type) { return decimal }
			
			switch options.valueNotFoundDecodingStrategy {
			case .throw:
				throw DecodingError.Keyed.keyNotFound(key, codingPath: codingPath)
			case .useDefaultValue:
				return nil
			case .custom(let transformer):
				storage.push(container: value)
				defer { storage.popContainer() }
				return try transformer.transformIfPresent(self)
			}
		}
}

// MARK: SingleValueDecodingContainer Methods
extension _SuperJSONDecoder : SingleValueDecodingContainer {
	
	public func decodeNil() -> Bool {
		return storage.topContainer is NSNull
	}
	
	public func decode(_ type: Bool.Type) throws -> Bool {
		if let value = try unbox(storage.topContainer, as: Bool.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return Bool.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: Int.Type) throws -> Int {
		if let value = try unbox(storage.topContainer, as: Int.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return Int.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: Int8.Type) throws -> Int8 {
		if let value = try unbox(storage.topContainer, as: Int8.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return Int8.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: Int16.Type) throws -> Int16 {
		if let value = try unbox(storage.topContainer, as: Int16.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return Int16.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: Int32.Type) throws -> Int32 {
		if let value = try unbox(storage.topContainer, as: Int32.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return Int32.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: Int64.Type) throws -> Int64 {
		if let value = try unbox(storage.topContainer, as: Int64.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return Int64.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: UInt.Type) throws -> UInt {
		if let value = try unbox(storage.topContainer, as: UInt.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return UInt.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: UInt8.Type) throws -> UInt8 {
		if let value = try unbox(storage.topContainer, as: UInt8.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return UInt8.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: UInt16.Type) throws -> UInt16 {
		if let value = try unbox(storage.topContainer, as: UInt16.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return UInt16.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: UInt32.Type) throws -> UInt32 {
		if let value = try unbox(storage.topContainer, as: UInt32.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return UInt32.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: UInt64.Type) throws -> UInt64 {
		if let value = try unbox(storage.topContainer, as: UInt64.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return UInt64.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: Float.Type) throws -> Float {
		if let value = try unbox(storage.topContainer, as: Float.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return Float.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: Double.Type) throws -> Double {
		if let value = try unbox(storage.topContainer, as: Double.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return Double.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode(_ type: String.Type) throws -> String {
		if let value = try unbox(storage.topContainer, as: String.self) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue:
			return String.defaultValue
		case .custom(let transformer):
			return try transformer.transform(self)
		}
	}
	
	public func decode<T : Decodable>(_ type: T.Type) throws -> T {
		if type == Date.self || type == NSDate.self {
			return try decode(as: Date.self) as! T
		} else if type == Data.self || type == NSData.self {
			return try decode(as: Data.self) as! T
		} else if type == Decimal.self || type == NSDecimalNumber.self {
			return try decode(as: Decimal.self) as! T
		}
		
		if let value = try unbox(storage.topContainer, as: type) { return value }
		
		switch options.valueNotFoundDecodingStrategy {
		case .throw:
			throw DecodingError.Keyed.valueNotFound(type, codingPath: codingPath)
		case .useDefaultValue, .custom:
			return try decodeAsDefaultValue()
		}
	}
	
}

