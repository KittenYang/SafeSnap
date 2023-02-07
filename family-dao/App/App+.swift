//
//  App+.swift
//  family-dao
//
//  Created by KittenYang on 12/26/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import UIKit
import NetworkKit
import LanguageManagerSwiftUI

public extension UIApplication {
	
	var keyWindow: UIWindow? {
		// Get connected scenes
		return self.connectedScenes
		// Keep only active scenes, onscreen and visible to the user
			.filter { $0.activationState == .foregroundActive }
		// Keep only the first `UIWindowScene`
			.first(where: { $0 is UIWindowScene })
		// Get its associated windows
			.flatMap({ $0 as? UIWindowScene })?.windows
		// Finally, keep only the key window
			.first(where: \.isKeyWindow)
	}
	
	static let versionWithBuildString: String = {
		return "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "") (\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""))"
	}()
	
	static let currentAppVersionString: String? = {
		let infoDic = Bundle.main.infoDictionary
		let currentAppVersion: String? = infoDic?["CFBundleShortVersionString"] as? String
		return currentAppVersion
	}()
	
	static let currentAppBuildString: String? = {
		let infoDic = Bundle.main.infoDictionary
		return infoDic?["CFBundleVersion"] as? String
	}()
	
	static func versionHeaderText() -> NSAttributedString {
		let name = NSAttributedString(string: "Design and Develop by KittenYang", attributes: [NSAttributedString.Key.font: UIFont(name: "Savoye Let", size: 12.0)!])

		let version = NSAttributedString(string: "\(UIApplication.versionWithBuildString)\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
		let final = NSMutableAttributedString(attributedString: version)
		final.append(name)

		let strLength = final.length
		let style = NSMutableParagraphStyle()
		style.lineSpacing = 5.0
		final.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSMakeRange(0, strLength))
		
		if NetworkEnviroment.shared.isDeveloperMode {
			final.append(.init(string: "dev_mode_str".appLocalizable))
		}
		
		if NetworkEnviroment.shared.environment == .debug {
			final.append(.init(string: "env_mode_str".appLocalizable))
		}
		
		return final
	}
}


public extension String {
	var appLocalizable: String {
		return self.languageLocalizable
	}
}

public extension Bundle {
	static let GisKitBundle: Bundle? = {
		return Bundle(identifier: "com.kittenyang.family-dao-kit")
	}()
}
