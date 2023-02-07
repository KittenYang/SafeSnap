//
//  TabView.swift
//  family-dao
//
//  Created by KittenYang on 9/4/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

//struct AppTabView: View {
//
//	@StateObject var nvspm = NavigationStackPathManager.shared
//	@StateObject var wm = WalletManager.shared
//
//	var body: some View {
//		TabView {
//			NewHomeView()
//				.tabItem {
//					Label("首页", systemImage: "house")
//				}
//			QueueView()
//				.tabItem {
//					Label("队列", systemImage: "lines.measurement.horizontal")
//				}
//		}
//		.overlayContainer(Constant.AppContainerID, containerConfiguration: .hudConfiguration)
//		.sheetWithContainer(isPresented: .constant(wm.currentFamily == nil)) {
//			WelcomeView().embedInNavigation()
//		}
//		.sheetWithContainer(isPresented: $nvspm.showCreateNewUserPage, {
//			CreateNewUser()
//				.onDisappear {
//					NavigationStackPathManager.shared.showCreateNewUserPage = false
//				}
//		})
//		.onAppear {
//			// correct the transparency bug for Tab bars
//			let tabBarAppearance = UITabBarAppearance()
//			tabBarAppearance.configureWithDefaultBackground()
//			UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
//			// correct the transparency bug for Navigation bars
//			let navigationBarAppearance = UINavigationBarAppearance()
//			navigationBarAppearance.configureWithOpaqueBackground()
//			UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
//		}
//		.environmentObject(WalletManager.shared)
////		.environmentObject(NavigationStackPathManager.shared)
//	}
//}

struct BlurModifier2: ViewModifier {
	var active: Bool
	func body(content: Content) -> some View {
		return content
			.blur(radius: active ? 50.0 : 0.0)
			.opacity(active ? 0.0 : 1.0)
	}
}

struct FadeModifier: ViewModifier {
	var active: Bool
	func body(content: Content) -> some View {
		return content
			.opacity(active ? 0.0 : 1.0)
	}
}

extension AnyTransition {
	static var blur: AnyTransition {
		.modifier(active: BlurModifier2(active: true), identity: BlurModifier2(active: false))
	}
	
	static var fade: AnyTransition {
		.modifier(active: FadeModifier(active: true), identity: FadeModifier(active: false))
	}
}

private struct BlurModifier: ViewModifier {
	public let isIdentity: Bool
	public var intensity: CGFloat

	public func body(content: Content) -> some View {
		content
			.ignoresSafeArea(edges: .top)
			.blur(radius: isIdentity ? intensity : 0)
			.opacity(isIdentity ? 0 : 1)
		//		HUD 位置会有问题
//			.modifier(if: isIdentity, then: { v in
//				v.ignoresSafeArea(edges: .top)
//			})
	}
}

public extension AnyTransition {
	static var blurScale: AnyTransition {
		.blur()
	}


	static func blur(
		intensity: CGFloat = 50,
		scale: CGFloat = 1.4,
		scaleAnimation animation: Animation = .easeInOut(duration: 0.8)//.spring()
	) -> AnyTransition {
		.opacity
		.combined(
			with: .modifier(
				active: BlurModifier(isIdentity: true, intensity: intensity),
				identity: BlurModifier(isIdentity: false, intensity: intensity)
			)
		)
		.animation(.easeInOut(duration: 0.9))
		.combined(with: .scale(scale: scale))
		.animation(animation)
	}
}

