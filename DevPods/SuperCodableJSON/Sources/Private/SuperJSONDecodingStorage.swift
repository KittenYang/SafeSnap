//
//  SuperJSONDecodingStorage.swift
//  SuperCodableJSON
//
//  Created by KittenYang on 6/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

struct SuperJSONDecodingStorage {
	
	/// The container stack.
	/// Elements may be any one of the JSON types (NSNull, NSNumber, String, Array, [String : Any]).
	private(set) var containers: [Any] = []
	
	// MARK: - Initialization
	
	/// Initializes `self` with no containers.
	init() {}
	
	// MARK: - Modifying the Stack
	
	var count: Int {
		return self.containers.count
	}
	
	var topContainer: Any {
		precondition(!self.containers.isEmpty, "Empty container stack.")
		return self.containers.last!
	}
	
	mutating func push(container: Any) {
		self.containers.append(container)
	}
	
	mutating func popContainer() {
		precondition(!self.containers.isEmpty, "Empty container stack.")
		self.containers.removeLast()
	}
}

