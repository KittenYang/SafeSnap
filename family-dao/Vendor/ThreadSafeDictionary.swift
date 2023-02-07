//
//  ThreadSafeDictionary.swift
//  family-dao
//
//  Created by KittenYang on 1/16/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public class ThreadSafeDictionary<V: Hashable,T>: Collection {

	private var dictionary: [V: T]
	private let concurrentQueue = DispatchQueue(label: "Dictionary_Barrier_Queue",
												attributes: .concurrent)
	
	public var innerDictionary:[V:T] {
		return dictionary
	}
	
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
