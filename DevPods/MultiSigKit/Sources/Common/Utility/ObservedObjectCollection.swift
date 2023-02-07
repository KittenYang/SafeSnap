//
//  ObservedObjectCollection.swift
//  MultiSigKit
//
//  Created by KittenYang on 9/18/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//

import Combine
import SwiftUI

public class ObservableArray<T:Hashable>: ObservableObject, Hashable {

	public static func == (lhs: ObservableArray<T>, rhs: ObservableArray<T>) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(array)
	}
	
	@Published var array:[T] = []
	public var cancellables = [AnyCancellable]()
	
	public init(array: [T]) {
		self.array = array
	}
	
	public func observeChildrenChanges<T: ObservableObject>() -> ObservableArray<T> {
		let array2 = array as! [T]
		array2.forEach({
			let c = $0.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
			
			// Important: You have to keep the returned value allocated,
			// otherwise the sink subscription gets cancelled
			self.cancellables.append(c)
		})
		return self as! ObservableArray<T>
	}
	
}


public class ObservedObjectCollectionBox<Element>: ObservableObject&Hashable where Element: ObservableObject&Hashable {
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(subscription)
	}
	
	public static func == (lhs: ObservedObjectCollectionBox<Element>, rhs: ObservedObjectCollectionBox<Element>) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	private var subscription: AnyCancellable?
	private var storage: AnyCollection<Element>
	
	init(_ wrappedValue: AnyCollection<Element>) {
		self.storage = wrappedValue
		self.reset(wrappedValue)
	}
	
	func reset(_ newValue: AnyCollection<Element>) {
		self.subscription = Publishers.MergeMany(newValue.map{ $0.objectWillChange })
			.eraseToAnyPublisher()
			.sink { _ in
				self.objectWillChange.send()
			}
	}
}


@propertyWrapper
public struct ObservedObjectCollection<Element>: DynamicProperty where Element: ObservableObject&Hashable {
	public var wrappedValue: AnyCollection<Element> {
		didSet {
			if isKnownUniquelyReferenced(&observed) {
				self.observed.reset(wrappedValue)
			} else {
				self.observed = ObservedObjectCollectionBox(wrappedValue)
			}
		}
	}
	
	@ObservedObject private var observed: ObservedObjectCollectionBox<Element>
	
	public init(wrappedValue: AnyCollection<Element>) {
		self.wrappedValue = wrappedValue
		self.observed = ObservedObjectCollectionBox(wrappedValue)
	}
	
	public init(wrappedValue: AnyCollection<Element>?) {
		self.init(wrappedValue: wrappedValue ?? AnyCollection([]))
	}
	
	public init<C: Collection>(wrappedValue: C) where C.Element == Element {
		self.init(wrappedValue: AnyCollection(wrappedValue))
	}
	
	public init<C: Collection>(wrappedValue: C?) where C.Element == Element {
		if let wrappedValue = wrappedValue {
			self.init(wrappedValue: wrappedValue)
		} else {
			self.init(wrappedValue: AnyCollection([]))
		}
	}
}
