//
//  Color+App.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import SwiftUI

public extension Color {
	static let appTheme: Color = {
		return .appPurple
	}()
	static let appBkgColor: Color = {
		return Color("appBkgColor")
	}()
	static let appGradientTop: Color = {
		let temp = #colorLiteral(red: 0.3058823529, green: 0.337254902, blue: 0.4509803922, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appGradientBottom: Color = {
		let temp = #colorLiteral(red: 0.1921568627, green: 0.2235294118, blue: 0.3176470588, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appRed: Color = {
		let temp = #colorLiteral(red: 0.937254902, green: 0.2274509804, blue: 0.2274509804, alpha: 1)
		return Color(uiColor: temp)
	}()
//	static let appBackground: Color = {
//		let temp = #colorLiteral(red: 0.9333333333, green: 0.9529411765, blue: 0.9725490196, alpha: 1)
//		return Color(uiColor: temp)
//	}()
	static let appGreen: Color = {
		let temp = #colorLiteral(red: 0.137254902, green: 0.6705882353, blue: 0.003921568627, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appPurple: Color = {
		let temp = #colorLiteral(red: 0.4549019608, green: 0.2431372549, blue: 0.8901960784, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appGray: Color = {
		let temp = #colorLiteral(red: 0.7058823529, green: 0.7058823529, blue: 0.7058823529, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appGrayMiddle: Color = {
		let temp = #colorLiteral(red: 0.7164882421, green: 0.7164882421, blue: 0.7164881825, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appGrayF4: Color = {
		let temp = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appGray9E: Color = {
		let temp = #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appGrayEA: Color = {
		let temp = #colorLiteral(red: 0.9176470588, green: 0.9176470588, blue: 0.9176470588, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appBlack: Color = {
		let temp = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appBlue: Color = {
		let temp = #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9803921569, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appGradientRed1: Color = {
        return .init(hexString: "1D4100")
		let temp = #colorLiteral(red: 0.9921568627, green: 0.5137254902, blue: 0.5137254902, alpha: 1)
		return Color(uiColor: temp)
	}()
	static let appGradientRed2: Color = {
        return .init(hexString: "000000")
		let temp = #colorLiteral(red: 0.4, green: 0.09019607843, blue: 0.09019607843, alpha: 1)
		return Color(uiColor: temp)
	}()
	
}


public extension Color {
	init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int: UInt64 = 0
		Scanner(string: hex).scanHexInt64(&int)
		let a, r, g, b: UInt64
		switch hex.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (1, 1, 1, 0)
		}
		
		self.init(
			.sRGB,
			red: Double(r) / 255,
			green: Double(g) / 255,
			blue:  Double(b) / 255,
			opacity: Double(a) / 255
		)
	}
}
