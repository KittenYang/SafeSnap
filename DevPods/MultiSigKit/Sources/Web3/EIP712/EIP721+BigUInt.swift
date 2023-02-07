//
//  EIP721+BigUInt.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/18/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import BigInt

extension BigInt {
	init?(value: String) {
		if value.starts(with: "0x") {
			self.init(String(value.dropFirst(2)), radix: 16)
		} else {
			self.init(value)
		}
	}
}

//func abs(_ value: BigInt) -> BigInt {
//	guard value.sign == .minus else { return value }
//
//	return BigInt(sign: .plus, magnitude: value.magnitude)
//}

extension BigUInt {
	init?(value: String) {
		if value.starts(with: "0x") {
			self.init(String(value.dropFirst(2)), radix: 16)
		} else {
			self.init(value)
		}
	}
}
