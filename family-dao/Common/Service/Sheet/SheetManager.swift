//
//  SheetManager.swift
//  family-dao
//
//  Created by KittenYang on 8/31/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SheetKit
import SwiftUI
import MultiSigKit

//@available(iOS 15.0, *)
extension UISheetPresentationController.Detent.Identifier {
	static let small = UISheetPresentationController.Detent.Identifier("small")
}

@MainActor
struct SheetManager {
	
	@Environment(\.sheetKit) var _sheetKit
	static var shared: SheetManager = SheetManager()
	
	private init() {}

	static func dismissAllSheets(completion: (() -> Void)? = nil) {
		RunOnMainThread {
			WalletManager.shared.currentContainerID = Constant.AppContainerID
			SheetManager.shared._sheetKit.dismissAllSheets(completion:completion)			
		}
	}
	
	// 这个方法都是双段的半层 Sheet
	static func showSheetWithContent<Content>(heightFactor: Double = 0.7, @ViewBuilder _ content: @escaping () -> Content) where Content : View {
		
		var detents = [UISheetPresentationController.Detent]()
		if #available(iOS 16.0, *) {
			detents = [.custom(identifier: .small) { context in
				return context.maximumDetentValue*heightFactor
			}/*,.large()*/]
		} else {
			detents = [.large()]
		}
		
		let configuration = SheetKit.BottomSheetConfiguration(
			detents: detents,
			largestUndimmedDetentIdentifier: .large,
			prefersGrabberVisible: true,
			prefersScrollingExpandsWhenScrolledToEdge: false,
			prefersEdgeAttachedInCompactHeight: false,
			widthFollowsPreferredContentSizeWhenEdgeAttached: true,
			preferredCornerRadius: 16)
		
		HapticManager.tic()
		
		SheetManager.shared._sheetKit.present(in: .topController, with: .customBottomSheet, configuration: configuration) {
			content()
				.cornerRadius(8.0)
				.onAppear {
					WalletManager.shared.currentContainerID = Constant.AppContainerSheetID
				}
				.onDisappear {
					WalletManager.shared.currentContainerID = Constant.AppContainerID
				}
				.overlayContainer(Constant.AppContainerSheetID, containerConfiguration: .hudConfiguration)
		}
	}
}


public extension View {
	// 这两个方法都是系统的 sheet
	func sheetWithContainer<Content>(name: String = Constant.AppContainerSheetID, isPresented: Binding<Bool>, @ViewBuilder _ content: @escaping () -> Content) -> some View where Content : View {
		return self.sheet(isPresented: isPresented, content: {
			content()
				.overlayContainer(Constant.AppContainerSheetID, containerConfiguration: .hudConfiguration)
				.onAppear {
					WalletManager.shared.currentContainerID = Constant.AppContainerSheetID
					HapticManager.tic()
				}
				.onDisappear {
					WalletManager.shared.currentContainerID = Constant.AppContainerID
				}
		})
	}
	
	func sheetWithModel<Content>(name: String = Constant.AppContainerSheetID, model: Binding<ShowSheetModel<Content>>) -> some View where Content : View {
		return self.sheet(isPresented: model.presented, content: {
			model.sheetContent.wrappedValue?.content()
				.overlayContainer(Constant.AppContainerSheetID, containerConfiguration: .hudConfiguration)
				.onAppear {
					WalletManager.shared.currentContainerID = Constant.AppContainerSheetID
					HapticManager.tic()
				}
				.onDisappear {
					model.wrappedValue.presented = false
					WalletManager.shared.currentContainerID = Constant.AppContainerID
				}
		})
	}
	
}
