//
//  String+.swift
//  
//
//  Created by KittenYang on 8/6/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public extension String {
	func dictionary(using: String.Encoding = String.Encoding.utf8) -> Any? {
			if let data = self.data(using: using) {
					return try? JSONSerialization.jsonObject(
							with: data, options: JSONSerialization.ReadingOptions.allowFragments
					)
			}
			return nil
	}
}

//MARK: SubString By Range
public extension String {
		subscript(_ range: CountableRange<Int>) -> String {
				let start = index(startIndex, offsetBy: max(0, range.lowerBound))
				let end = index(start, offsetBy: min(self.count - range.lowerBound,
																						 range.upperBound - range.lowerBound))
				return String(self[start..<end])
		}
		
		subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
				let start = index(startIndex, offsetBy: max(0, range.lowerBound))
				return String(self[start...])
		}
		
		subscript(_ range: NSRange) -> String {
				let start = self.index(self.startIndex, offsetBy: range.lowerBound)
				let end = self.index(self.startIndex, offsetBy: range.upperBound)
				let subString = self[start..<end]
				return String(subString)
		}
}

// MARK: Cookies: "x=x;" 正则匹配
public extension String {
		func cookieRegex() -> [NSTextCheckingResult] {
				var atRegularExpression: NSRegularExpression?
				do {
						atRegularExpression = try NSRegularExpression(pattern: "(\\S+)=([^;]+)", options: [])
				} catch {
						atRegularExpression = nil
				}
				
				if let atRegularExpression = atRegularExpression {
						let nsRange = NSRange(location: 0, length: NSString(string: self).length)
						if nsRange.location == NSNotFound && nsRange.length <= 1 {
						} else {
								return atRegularExpression.matches(in: self, options: [], range: nsRange)
						}
				}
				
				return [NSTextCheckingResult]()
		}
}
