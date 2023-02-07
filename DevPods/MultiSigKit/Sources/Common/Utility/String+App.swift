//
//  String+App.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/21/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public extension String {
	func add0xPrefix() -> String {
		if !self.hasPrefix("0x") {
			return "0x" + self
		}
		return self
	}
}
