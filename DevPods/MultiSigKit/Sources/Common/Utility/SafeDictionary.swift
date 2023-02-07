//
//  SafeDictionary.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/21/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public class ThreadSafeDictionary<V: Hashable,T>: Collection {
	
	public private(set) var dictionary: [V: T]
	private let concurrentQueue = DispatchQueue(label: "Dictionary Barrier Queue", attributes: .concurrent)
	public var startIndex: Dictionary<V, T>.Index {
		self.concurrentQueue.sync {
			return self.dictionary.startIndex
		}
	}
	
	public var endIndex: Dictionary<V, T>.Index {
		self.concurrentQueue.sync {
			return self.dictionary.endIndex
		}
	}
	
	public var count: Int {
		self.concurrentQueue.sync {
			return self.dictionary.count
		}
	}
	
	public init(dict: [V: T] = [V:T]()) {
		self.dictionary = dict
	}
	// this is because it is an apple protocol method
	// swiftlint:disable identifier_name
	public func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index {
		self.concurrentQueue.sync {
			return self.dictionary.index(after: i)
		}
	}
	// swiftlint:enable identifier_name
	public subscript(key: V) -> T? {
		set(newValue) {
			self.concurrentQueue.async(flags: .barrier) {[weak self] in
				self?.dictionary[key] = newValue
			}
		}
		get {
			self.concurrentQueue.sync {
				return self.dictionary[key]
			}
		}
	}
	
	// has implicity get
	public subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
		self.concurrentQueue.sync {
			return self.dictionary[index]
		}
	}
	
	public func removeValue(forKey key: V) {
		self.concurrentQueue.async(flags: .barrier) {[weak self] in
			self?.dictionary.removeValue(forKey: key)
		}
	}
	
	public func removeAll() {
		self.concurrentQueue.async(flags: .barrier) {[weak self] in
			self?.dictionary.removeAll()
		}
	}
	
}
