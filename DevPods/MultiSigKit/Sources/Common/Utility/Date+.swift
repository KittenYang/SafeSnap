//
//  Date+.swift
//  MultiSigKit
//
//  Created by KittenYang on 1/28/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public extension Date {
	
	func beforeDay(_ day: Int) -> Date {
		return Calendar.current.date(byAdding: .day, value: -day, to: self)!
	}
	
	func beforeMinutes(_ minutes: Int) -> Date {
		return Calendar.current.date(byAdding: .minute, value: -minutes, to: self)!
	}
	
	func beforeSeconds(_ seconds: Int) -> Date {
		return Calendar.current.date(byAdding: .second, value: -seconds, to: self)!
	}
}
