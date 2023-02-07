//
//  Retry.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public struct Retry {
	
	public static let RunningMap = TokenMapBox<String,Bool>()
	
	//delaySecond:两次重试之间间隔多久
	public static func run<T>(id:String, retryCount:Int=3, delaySecond:TimeInterval=1.0, task: @escaping () async -> Optional<T>, retryCondition:(T?)->Bool) async -> T? {
		if let isRunning = await RunningMap.getValue(id), isRunning {
			return nil
		}
		await RunningMap.update(id, value: true)
		for retry in 0..<retryCount {
			let _info = await task()
			if retryCondition(_info) {
				let oneSecond = TimeInterval(3_000_000_000)
				let delay = UInt64(oneSecond * delaySecond)//间隔1s后重试
				try? await Task<Never, Never>.sleep(nanoseconds: delay)
				debugPrint("重试第\(retry+1)次")
				continue
			} else {
				debugPrint("重试结束，请求成功")
				await RunningMap.update(id, value: false)
				return _info
			}
		}
		await RunningMap.update(id, value: false)
		return nil
	}
}

public actor TokenMapBox<K:Hashable,V> {
	public private(set) var activityTokenMap = [K:V]()
	public func update(_ key:K, value:V) {
		self.activityTokenMap[key] = value
	}
	public func getValue(_ key:K) -> V? {
		return self.activityTokenMap[key]
	}
	public func delete(_ key:K) {
		self.activityTokenMap.removeValue(forKey: key)
	}
}

public actor TokenListBox<T:Equatable&Hashable> {
	public private(set) var activityTokenList = [T]()
	public func append(_ contentsOfElements:[T]) {
		self.activityTokenList.append(contentsOf: contentsOfElements)
		self.activityTokenList = self.activityTokenList.unique()
	}
	public func append(_ element:T) {
		if !self.activityTokenList.contains(element) {
			self.activityTokenList.append(element)
		}
	}
	public func delete(_ element:T) {
		return self.activityTokenList.removeAll { str in
			return str == element
		}
	}
}

public extension Array where Element: Hashable {
	func unique() -> Self {
		return Array(Set(self))
	}
}
