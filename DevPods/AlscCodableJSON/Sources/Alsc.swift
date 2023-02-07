//
//  Alsc.swift
//  AlscCodableJSON
//
//  Created by KittenYang on 6/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public protocol AlscCodable: Codable {}

typealias AlscWrapperInfo = (defaultValue: Any, codingKeys: [String])

@propertyWrapper
public struct Alsc<Value: Defaultable & Decodable>: Codable {
	
	public var wrappedValue: Value
	
	///
	/// ```
	/// @Alsc(default: "default_string") var uid: String
	/// @Alsc(default: "default_string","alt_key1") var uid: String
	/// @Alsc(default: "default_string","alt_key1","alt_key2") var uid: String
	/// 如果有多个alt key,从左往右去 json 里匹配，匹配到就停止，不管 value 是否匹配（因为有类型兼容的逻辑在）
	///
	public init(default: Value, _ key: String ...) {
		Thread.current.alscsCurrentDecoding = false
		// Alsc语法糖标记的属性需要拼接到最新的上下文（最新的上下文就是 alscsWrapperInfos 二维数组最后一个）
		// crash 保护，如果当前没有上下文，创建一个空的上下文
		if Thread.current.alscsWrapperInfos.last == nil {
			Thread.current.alscsWrapperInfos.append([])
		}
		
		Thread.current.alscsWrapperInfos[Thread.current.alscsWrapperInfos.endIndex-1].append((`default`, key))
		self.wrappedValue = `default`
	}
	
	public init(from decoder: Decoder) throws {
		Thread.current.alscsCurrentDecoding = true
		let container = try decoder.singleValueContainer()
		wrappedValue = (try? container.decode(Value.self)) ?? (Thread.current.alscsWrapperInfos.last?.first?.defaultValue as? Value ?? Value.defaultValue)
		
		//每次 decode 前需要判断最新上下文是否为空，因为有可能上次没有清除掉空context，这里确保把空 context remove
		while Thread.current.alscsWrapperInfos.last?.isEmpty ?? false {
			Thread.current.alscsWrapperInfos.removeLast()
		}
		
		// decode 完一个 Alsc 标记属性，需要清除当前 Alsc 标记信息
		if Thread.current.alscsWrapperInfos.count > 0 {
			Thread.current.alscsWrapperInfos[Thread.current.alscsWrapperInfos.count-1].safelyRemoveFirst()
		}
		
		// 最后，清除完一个 Alsc 标记，如果是最后一个，还会导致空 context 存在，需要再次确保清空当前上下文
		while Thread.current.alscsWrapperInfos.last?.isEmpty ?? false {
			Thread.current.alscsWrapperInfos.removeLast()
		}

		Thread.current.alscsCurrentDecoding = false
	}
	
	public func encode(to encoder: Encoder) throws {
		
	}
}


extension Alsc: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		"\(wrappedValue)"
	}
	
	public var debugDescription: String {
		"\(wrappedValue)"
	}
}

// MARK: Private
internal func appendNewContextIfNeeded() {
	if let last = Thread.current.alscsWrapperInfos.last {
		if !last.isEmpty {
			Thread.current.alscsWrapperInfos.append([])
		}
	} else {
		Thread.current.alscsWrapperInfos.append([])
	}
}

// MARK: Thread Extension
private var alscsWrapperKey: Void?
private var alscsCurrentDecodingKey: Void?
extension Thread {
	var alscsCurrentDecoding: Bool {
		set {
			objc_setAssociatedObject(self, &alscsCurrentDecodingKey, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN)
		}
		get {
			guard let number = objc_getAssociatedObject(self, &alscsCurrentDecodingKey) as? NSNumber else {
				return false
			}
			return number.boolValue
		}
	}
	
	var alscsWrapperInfos: [[AlscWrapperInfo]] {
		set {
			objc_setAssociatedObject(self, &alscsWrapperKey, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
		get {
			return objc_getAssociatedObject(self, &alscsWrapperKey) as? [[AlscWrapperInfo]] ?? [[AlscWrapperInfo]]()
		}
	}
}


extension Collection {
	/// Returns the element at the specified index if it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

extension Array {
	mutating func safelyRemoveFirst() {
		if count > 0 {
			removeFirst()
		}
	}
}
