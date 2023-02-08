//
//  Super.swift
//  SuperCodableJSON
//
//  Created by KittenYang on 6/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public protocol SuperCodable: Codable {}

typealias SuperWrapperInfo = (defaultValue: Any, codingKeys: [String])

@propertyWrapper
public struct Super<Value: Defaultable & Decodable>: Codable {
	
	public var wrappedValue: Value
	
	///
	/// ```
	/// @Super(default: "default_string") var uid: String
	/// @Super(default: "default_string","alt_key1") var uid: String
	/// @Super(default: "default_string","alt_key1","alt_key2") var uid: String
	/// 如果有多个alt key,从左往右去 json 里匹配，匹配到就停止，不管 value 是否匹配（因为有类型兼容的逻辑在）
	///
	public init(default: Value, _ key: String ...) {
		Thread.current.SupersCurrentDecoding = false
		// Super语法糖标记的属性需要拼接到最新的上下文（最新的上下文就是 SupersWrapperInfos 二维数组最后一个）
		// crash 保护，如果当前没有上下文，创建一个空的上下文
		if Thread.current.SupersWrapperInfos.last == nil {
			Thread.current.SupersWrapperInfos.append([])
		}
		
		Thread.current.SupersWrapperInfos[Thread.current.SupersWrapperInfos.endIndex-1].append((`default`, key))
		self.wrappedValue = `default`
	}
	
	public init(from decoder: Decoder) throws {
		Thread.current.SupersCurrentDecoding = true
		let container = try decoder.singleValueContainer()
		wrappedValue = (try? container.decode(Value.self)) ?? (Thread.current.SupersWrapperInfos.last?.first?.defaultValue as? Value ?? Value.defaultValue)
		
		//每次 decode 前需要判断最新上下文是否为空，因为有可能上次没有清除掉空context，这里确保把空 context remove
		while Thread.current.SupersWrapperInfos.last?.isEmpty ?? false {
			Thread.current.SupersWrapperInfos.removeLast()
		}
		
		// decode 完一个 Super 标记属性，需要清除当前 Super 标记信息
		if Thread.current.SupersWrapperInfos.count > 0 {
			Thread.current.SupersWrapperInfos[Thread.current.SupersWrapperInfos.count-1].safelyRemoveFirst()
		}
		
		// 最后，清除完一个 Super 标记，如果是最后一个，还会导致空 context 存在，需要再次确保清空当前上下文
		while Thread.current.SupersWrapperInfos.last?.isEmpty ?? false {
			Thread.current.SupersWrapperInfos.removeLast()
		}

		Thread.current.SupersCurrentDecoding = false
	}
	
	public func encode(to encoder: Encoder) throws {
		
	}
}


extension Super: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		"\(wrappedValue)"
	}
	
	public var debugDescription: String {
		"\(wrappedValue)"
	}
}

// MARK: Private
internal func appendNewContextIfNeeded() {
	if let last = Thread.current.SupersWrapperInfos.last {
		if !last.isEmpty {
			Thread.current.SupersWrapperInfos.append([])
		}
	} else {
		Thread.current.SupersWrapperInfos.append([])
	}
}

// MARK: Thread Extension
private var SupersWrapperKey: Void?
private var SupersCurrentDecodingKey: Void?
extension Thread {
	var SupersCurrentDecoding: Bool {
		set {
			objc_setAssociatedObject(self, &SupersCurrentDecodingKey, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN)
		}
		get {
			guard let number = objc_getAssociatedObject(self, &SupersCurrentDecodingKey) as? NSNumber else {
				return false
			}
			return number.boolValue
		}
	}
	
	var SupersWrapperInfos: [[SuperWrapperInfo]] {
		set {
			objc_setAssociatedObject(self, &SupersWrapperKey, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
		get {
			return objc_getAssociatedObject(self, &SupersWrapperKey) as? [[SuperWrapperInfo]] ?? [[SuperWrapperInfo]]()
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
