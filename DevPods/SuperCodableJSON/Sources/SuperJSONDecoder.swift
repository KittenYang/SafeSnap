//
//  SuperJSONDecoder.swift
//  SuperCodableJSON
//
//  Created by KittenYang on 6/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

open class SuperJSONDecoder: JSONDecoder {
	
	/// Options set on the top-level encoder to pass down the decoding hierarchy.
	struct Options {
		let dateDecodingStrategy: DateDecodingStrategy
		let dataDecodingStrategy: DataDecodingStrategy
		let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
		let keyDecodingStrategy: KeyDecodingStrategy
		let keyNotFoundDecodingStrategy: KeyNotFoundDecodingStrategy
		let valueNotFoundDecodingStrategy: ValueNotFoundDecodingStrategy
		let nestedContainerDecodingStrategy: NestedContainerDecodingStrategy
		let jsonStringDecodingStrategy: JSONStringDecodingStrategy
		let userInfo: [CodingUserInfoKey : Any]
	}
	
	/// The options set on the top-level decoder.
	var options: Options {
		return Options(dateDecodingStrategy: dateDecodingStrategy,
									 dataDecodingStrategy: dataDecodingStrategy,
									 nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
									 keyDecodingStrategy: keyDecodingStrategy,
									 keyNotFoundDecodingStrategy: keyNotFoundDecodingStrategy,
									 valueNotFoundDecodingStrategy: valueNotFoundDecodingStrategy,
									 nestedContainerDecodingStrategy: nestedContainerDecodingStrategy,
									 jsonStringDecodingStrategy: jsonStringDecodingStrategy,
									 userInfo: userInfo)
	}
	
	/// The strategy to use for decoding when key not found. Defaults to `.useDefaultValue`.
	open var keyNotFoundDecodingStrategy: KeyNotFoundDecodingStrategy = .useDefaultValue
	
	/// The strategy to use for decoding when value not found. Defaults to `.custom`.
	open var valueNotFoundDecodingStrategy: ValueNotFoundDecodingStrategy = .custom(Transformer())
	
	/// The strategy to use for decoding nested container.
	open var nestedContainerDecodingStrategy: NestedContainerDecodingStrategy = .init()
	
	/// The strategy to use for decoding JSON string.
	open var jsonStringDecodingStrategy: JSONStringDecodingStrategy = .all
	
	
	// MARK: - Decoding Values
	
	/// Decodes a top-level value of the given type from the given JSON representation.
	///
	/// - parameter type: The type of the value to decode.
	/// - parameter data: The data to decode from.
	/// - returns: A value of the requested type.
	/// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
	/// - throws: An error if any value throws an error during decoding.
	open override func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {
		let topLevel: Any
		do {
			topLevel = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
		} catch {
			throw DecodingError.dataCorrupted(DecodingError.Context(
				codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: error))
		}
		
		return try decode(type, from: topLevel)
	}

	/// Decodes a top-level value of the given type.
	///
	/// - parameter type: The type of the value to decode.
	/// - parameter convertible: The container to decode from.
	/// - returns: A value of the requested type.
	
	/// - throws: An error if any value throws an error during decoding.
	open func decode<T : Decodable>(_ type: T.Type, from convertible: JSONContainerConvertible) throws -> T {
		try decode(type, from: convertible.asJSONContainer())
	}
}

private extension SuperJSONDecoder {
	func decode<T : Decodable>(
		_ type: T.Type,
		from container: Any
	) throws -> T {
		let decoder = _SuperJSONDecoder(referencing: container, options: self.options)
		
		guard let value = try decoder.unbox(container, as: type) else {
			throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
		}
		
		return value
	}
}

//MARK: JSONContainerConvertible
public protocol JSONContainerConvertible {
		func asJSONContainer() -> Any
}

extension Dictionary: JSONContainerConvertible where Key == String, Value == Any {
		public func asJSONContainer() -> Any { self }
}

extension Array: JSONContainerConvertible where Element == Any {
		public func asJSONContainer() -> Any { self }
}

extension Array: JSONStringConvertible {}
extension Dictionary: JSONStringConvertible {}

public protocol JSONStringConvertible {
	func toJSONString() -> String?
}

extension JSONStringConvertible {
	public func toJSONString() -> String? {
		return json(from: self)
	}
}

private func json(from object:Any) -> String? {
	guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
		return nil
	}
	return String(data: data, encoding: String.Encoding.utf8)
}

