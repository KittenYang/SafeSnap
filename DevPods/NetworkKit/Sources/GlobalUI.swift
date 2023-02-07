//
//  GlobalUI.swift
//  family-dao
//
//  Created by KittenYang on 1/22/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

public extension SwiftUI.Font {
	
	static func rounded(size: CGFloat, weight: Weight? = nil) -> Font {
        Font.custom("Ark-Pixel-12px-monospaced-zh_cn-Regular", size: size)
//		if #available(iOS 16.0, *) {
//			return .system(size: size, weight: weight, design: .rounded)
//		} else {
//			return .system(size: size, weight: weight ?? .regular, design: .rounded)
//		}
	}
	
}
