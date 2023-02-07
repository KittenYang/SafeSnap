//
//  UserSettings.swift
//  family-dao
//
//  Created by KittenYang on 1/30/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Combine
import Foundation
import SwiftUI


class UserSettings: ObservableObject {

	static let shared = UserSettings()
	
//	@Published var lang: String = "en"
	
	@Published var selectedAppearance: ColorSchemeAppearance

//	var bundle: Bundle? {
//		let b = Bundle.main.path(forResource: lang, ofType: "lproj")!
//		return Bundle(path: b)
//	}
	
	init() {
		self.selectedAppearance = .system
	}
}


enum ColorSchemeAppearance: Int,CaseIterable {
	case system
	case dark
	case light
	
	var colorScheme: ColorScheme? {
		switch self {
		case .system:
			return nil
		case .dark:
			return .dark
		case .light:
			return .light
		}
	}
	
	var name: String {
		switch self {
		case .system:
			return "color_scheme_system".appLocalizable
		case .dark:
			return "color_scheme_dark".appLocalizable
		case .light:
			return "color_scheme_light".appLocalizable
		}
	}
	
}
