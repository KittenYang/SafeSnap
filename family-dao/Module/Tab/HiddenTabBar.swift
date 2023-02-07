//
//  HiddenTabBar.swift
//  family-dao
//
//  Created by KittenYang on 8/31/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import UIKit

extension UIView {
	
	func allSubviews() -> [UIView] {
		var res = self.subviews
		for subview in self.subviews {
			let riz = subview.allSubviews()
			res.append(contentsOf: riz)
		}
		return res
	}
}

struct Tool {
	
	static func keyWindow() -> UIWindow? {
		return UIApplication.shared.connectedScenes
			.filter { $0.activationState == .foregroundActive }
			.map { $0 as? UIWindowScene }
			.compactMap { $0 }
			.first?.windows
			.filter { $0.isKeyWindow }.first
	}
	
	static func showTabBar() {
		keyWindow()?.allSubviews().forEach({ (v) in
			if let view = v as? UITabBar {
				UIView.animate(withDuration: 0.3, delay: 0.0) {
					view.alpha = 1.0
//					view.transform = CGAffineTransform.identity
				} completion: { finished in
					view.isHidden = false
//					view.transform = CGAffineTransform.identity
				}
			}
		})
	}
	
	static func hiddenTabBar() {
		keyWindow()?.allSubviews().forEach({ (v) in
			if let view = v as? UITabBar {
				UIView.animate(withDuration: 0.3, delay: 0.0) {
					view.alpha = 0.0
//					view.transform = CGAffineTransformTranslate(view.transform, 0.0, view.frame.size.height)
				} completion: { finished in
					view.isHidden = true
//					view.transform = CGAffineTransformTranslate(view.transform, 0.0, view.frame.size.height)
				}
			}
		})
	}
}

struct ShowTabBar: ViewModifier {
	func body(content: Content) -> some View {
		return content.padding(.zero).onAppear {
			Tool.showTabBar()
		}
	}
}
struct HiddenTabBar: ViewModifier {
	func body(content: Content) -> some View {
		return content.padding(.zero).onAppear {
			Tool.hiddenTabBar()
		}
	}
}

extension View {
	func showTabBar() -> some View {
		return self.modifier(ShowTabBar())
	}
	func hiddenTabBar() -> some View {
		return self.modifier(HiddenTabBar())
	}
}
