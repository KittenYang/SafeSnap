//
//  File.swift
//  
//
//  Created by KittenYang on 8/6/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public extension Dictionary {
		var data: Data? {
				let checker = JSONSerialization.isValidJSONObject(self)
				if checker {
						return try? JSONSerialization.data(withJSONObject: self, options: [])
				}
				return nil
		}
		
		func string(using encoding: String.Encoding = String.Encoding.utf8) -> String? {
				guard let data = data else { return nil }
				return String(data: data, encoding: encoding)
		}
		
		mutating func merge(dict: [Key: Value]) {
				for (key, value) in dict {
						updateValue(value, forKey: key)
				}
		}
}

public extension Dictionary where Key == Int {
		func sortedValuesByKey() -> [Value] {
				return self.sorted(by: { $0.key < $1.key }).compactMap { $0.value }
		}
}
