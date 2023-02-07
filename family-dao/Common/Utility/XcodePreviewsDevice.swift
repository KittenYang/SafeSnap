//
//  XcodePreviewsDevice.swift
//  family-dao
//
//  Created by KittenYang on 1/10/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

enum XcodePreviewsDevice: String, CaseIterable {
	case iPhoneSE = "iPhone SE (2nd generation)"
	case iPhone8 = "iPhone 8"
	case iPhone12 = "iPhone 12 (2nd generation)"
	case iPhone14ProMax = "iPhone 14 Pro Max"
	case iPadAir = "iPad Air (4th generation)"
	// Add more case you want to display

	static func previews<C: View>(_ devices: [XcodePreviewsDevice] = XcodePreviewsDevice.allCases, content: @escaping () -> C) -> some View {
		ForEach(devices, id: \.self) {
			content()
				.previewDevice(.init(rawValue: $0.rawValue))
				.previewDisplayName($0.rawValue)
		}
	}
}
