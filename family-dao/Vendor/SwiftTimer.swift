//
//  SwiftTimer.swift
//  family-dao
//
//  Created by KittenYang on 1/16/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation


public class SwiftTimer {
	
	private var internalTimer: DispatchSourceTimer?
	
	public private(set) var isRunning = false
	
	public let repeats: Bool
	
	public typealias SwiftTimerHandler = (SwiftTimer) -> Void
	
	private var handler: SwiftTimerHandler
	
	public let uniqueID: String
	
	public init(interval: DispatchTimeInterval, repeats: Bool = false, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main, uniqueID: String? = nil, handler: @escaping SwiftTimerHandler) {
		self.uniqueID = uniqueID ?? UUID().uuidString
		self.handler = handler
		self.repeats = repeats
		internalTimer = DispatchSource.makeTimerSource(queue: queue)
		internalTimer?.setEventHandler { [weak self] in
			if let strongSelf = self {
				handler(strongSelf)
			}
		}
		
		if repeats {
			internalTimer?.schedule(deadline: .now() + interval, repeating: interval, leeway: leeway)
		} else {
			internalTimer?.schedule(deadline: .now() + interval, leeway: leeway)
		}
	}
	
	public static func repeaticTimer(interval: DispatchTimeInterval, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main , handler: @escaping SwiftTimerHandler ) -> SwiftTimer {
		return SwiftTimer(interval: interval, repeats: true, leeway: leeway, queue: queue, handler: handler)
	}
	
	deinit {
		print("💀 SwiftTimer 移除！！")
//		if let internalTimer, !self.isRunning, !internalTimer.isCancelled {
//			//https://developer.apple.com/forums/thread/15902
//			internalTimer.cancel()
//			internalTimer.resume()
//		}
//		internalTimer = nil
		if !self.isRunning {
			self.internalTimer?.resume()
		}
		self.internalTimer?.cancel()
		self.internalTimer = nil
	}
	
	//You can use this method to fire a repeating timer without interrupting its regular firing schedule. If the timer is non-repeating, it is automatically invalidated after firing, even if its scheduled fire date has not arrived.
	public func fire() {
		if repeats {
			handler(self)
		} else {
			handler(self)
			internalTimer?.cancel()
		}
	}
	
	public func start() {
		if !isRunning {
			internalTimer?.resume()
			isRunning = true
		}
	}
	
	public func suspend() {
		if isRunning {
			internalTimer?.suspend()
			isRunning = false
		}
	}
	
	public func rescheduleRepeating(interval: DispatchTimeInterval) {
		if repeats {
			internalTimer?.schedule(deadline: .now() + interval, repeating: interval)
		}
	}
	
	public func rescheduleHandler(handler: @escaping SwiftTimerHandler) {
		self.handler = handler
		internalTimer?.setEventHandler { [weak self] in
			if let strongSelf = self {
				handler(strongSelf)
			}
		}

	}
}

//MARK: Throttle
public extension SwiftTimer {
	
	private static var workItems = ThreadSafeDictionary(dict: [String:DispatchWorkItem]())
	
	///The Handler will be called after interval you specified
	///Calling again in the interval cancels the previous call
	static func debounce(interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main , handler: @escaping () -> Void ) {
		
		//if already exist
		if let item = workItems[identifier] {
			item.cancel()
		}

		let item = DispatchWorkItem {
			handler();
			workItems.removeValue(forKey: identifier)
		};
		workItems[identifier] = item
		queue.asyncAfter(deadline: .now() + interval, execute: item);
	}
	
	///The Handler will be called after interval you specified
	///It is invalid to call again in the interval
	static func throttle(interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main , handler: @escaping () -> Void ) {
		
		//if already exist
		if workItems[identifier] != nil {
			return;
		}
		
		let item = DispatchWorkItem {
			handler();
			workItems.removeValue(forKey: identifier)
		};
		workItems[identifier] = item
		queue.asyncAfter(deadline: .now() + interval, execute: item);
		
	}
	
	static func cancelThrottlingTimer(identifier: String) {
		if let item = workItems[identifier] {
			item.cancel()
			workItems.removeValue(forKey: identifier)
		}
	}
}

//MARK: Identifiable & Hashable
extension SwiftTimer: Identifiable, Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.uniqueID)
	}
	public static func == (lhs: SwiftTimer, rhs: SwiftTimer) -> Bool {
		return lhs.id == rhs.id
	}
	public var id: String {
		return self.uniqueID
	}
}

//MARK: DispatchTimeInterval
public extension DispatchTimeInterval {
	
	static func fromSeconds(_ seconds: Double) -> DispatchTimeInterval {
		return .milliseconds(Int(seconds * 1000))
	}
	
	func toTimeInterval() -> Double {
		   var result: Double = 0
		   switch self {
		   case .seconds(let value):
			   result = Double(value)
		   case .milliseconds(let value):
			   result = Double(value)*0.001
		   case .microseconds(let value):
			   result = Double(value)*0.000001
		   case .nanoseconds(let value):
			   result = Double(value)*0.000000001
		   case .never:
			   result = 0
		   default:
			result = 0
		   }

		   return result
	   }
}
