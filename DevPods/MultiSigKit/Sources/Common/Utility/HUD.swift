//
//  HUD.swift
//  family-dao
//
//  Created by KittenYang on 9/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import SwiftUIOverlayContainer

public func RunOnMainThread(_ job: @escaping () -> Void) {
	if Thread.isMainThread {
		job()
	} else {
		DispatchQueue.main.async {
			job()
		}
	}
}

//public struct BlockView: View {
//	public init(_ text:String?,image:UIImage? = nil,loading:Bool?) {
//		self.text = text
//		self.isLoading = loading
//		self.image = image
//	}
//
//	public let text: String?
//	public let isLoading: Bool?
//	public let image: UIImage?
//		
//	public var body: some View {
//		VStack(spacing: 5.0) {
//			if isLoading == true {
//				ProgressView()
//					.scaleEffect(2)
//					.frame(width: 20, height: 50)
//			}
//			if let text, !text.isEmpty {
//				Text(text)
//					.font(.title3)
//					.fontWeight(.medium)
//			}
//			if let image {
//				Image(uiImage: image)
//					.scaledToFit()
//			}
//		}
//		.foregroundColor(.init(UIColor.label.cgColor))
//		.padding(.all, 25.0)
//		.frame(minWidth: 150.0)
//		.background(
//			RoundedRectangle(cornerRadius: 15.0)
//				.foregroundColor(Color(UIColor.systemBackground.cgColor))
//				.shadow(color: Color.appGray.opacity(0.4), radius: 15.0)
//		)
//		.frame(minWidth: 150.0, maxWidth: 300)
//	}
//}


public struct AppToastViewStyle {
	public let text: String?
	public let isLoading: Bool?
	public let image: UIImage?

//	public func makeBody(configuration: Configuration) -> some View {
//		BlockView(text, image: image, loading: isLoading)
//	}
}

extension AppToastViewStyle: Identifiable, Equatable {
	public var id: String {
		return "\(text ?? "")" + "\(isLoading ?? false)"
	}
}

public extension AppToastViewStyle {
	static func shadowBkg(text:String?, image:UIImage? = nil, loading:Bool? = nil) -> Self {
		.init(text: text, isLoading: loading, image: image)
	}
}


public class AppToastModel: ObservableObject {
	
	@Published public var presented: Bool = false
	@Published public var style: AppToastViewStyle
	
	@Published public var dismissAfter: Double?
	@Published public var isUserInteractionEnabled: Bool
	
	@Published public var onDismiss: (() -> Void)? = nil
	
	/// isUserInteractionEnabled: window 是否可交互。 If true: 背后的视图不可交互；false: 背后的 touch 依然触发（穿透）
	public init(presented: Bool = false, style: AppToastViewStyle = .shadowBkg(text: nil), dismissAfter: Double? = nil, isUserInteractionEnabled: Bool = false, onDismiss: (() -> Void)? = nil) {
		self.presented = presented
		self.style = style
		self.dismissAfter = dismissAfter ?? (style.isLoading == true ? nil : 2.0)// 默认2.0s
		self.isUserInteractionEnabled = isUserInteractionEnabled
		self.onDismiss = onDismiss
	}
	
	/// 快捷方法：loading 样式，后面的视图不可点击
	fileprivate static func showLoadingHUD(text: String) -> AppToastModel {
		return .init(presented:true, style:.shadowBkg(text: text, loading: true), isUserInteractionEnabled: true)
	}
	
	/// 快捷方法：normal 样式，后面的视图可点击
	fileprivate static func showHUD(text: String) -> AppToastModel {
		return .init(presented:true, style:.shadowBkg(text: text, loading: false))
	}
	
}

extension AppToastModel: Identifiable, Equatable {
	public var id: String {
		return "\(presented)" + "\(style)" + "\(dismissAfter ?? 0.0)" + "\(isUserInteractionEnabled)"
	}
	
	public static func == (lhs: AppToastModel, rhs: AppToastModel) -> Bool {
		return lhs.presented == rhs.presented
		&& lhs.style == rhs.style
		&& lhs.dismissAfter == rhs.dismissAfter
		&& lhs.isUserInteractionEnabled == rhs.isUserInteractionEnabled
	}
}


//@MainActor
//public class AppToastManager: ObservableObject {
//	public static let shared = AppToastManager()
//	@Published public var toastModel: AppToastModel? = .init()
//
//	public static func dismissAll() {
//		AppToastManager.shared.toastModel = .init()
//	}
//
//	public static func show(_ text: String) {
////		AppHUD.dismissAll()
//		AppToastManager.shared.toastModel = .showHUD(text: text)
//	}
//
//	public static func showLoadingHUD(_ text: String) {
////		AppHUD.dismissAll()
//		AppToastManager.shared.toastModel = .showLoadingHUD(text: text)
//	}
//}
//

//public typealias ContainerManager = AppToastManager
public typealias AppHUD = ContainerManager

public extension ContainerManager {

	@MainActor
	static func show(_ text:String,
					 _ subTitle:String? = nil,
					 image:UIImage? = nil,
					 loading:Bool = false,
					 delay: Double = 2.5) {
		let msg = Message(height: 50.0, background: .regularMaterial, title: text, subTitle: subTitle, textColor: .label, imageInfo: (image,nil), loading: loading, delay:delay)
		AppHUD.share.show(name: WalletManager.shared.currentContainerID, msg)
		print("HUD:\(msg)")
	}

	@MainActor
	static func dismissAll() {
		AppHUD.share.dismissAllView(in: [Constant.AppContainerSheetID,Constant.AppContainerSheetID], animated: true)
	}

	@MainActor
	private func show<Content>(name: String, _ content: Content) where Content: View & ContainerViewConfigurationProtocol {
		if !Thread.isMainThread {
			DispatchQueue.main.async {
				self.show(name: name, content)
			}
			return
		}
		show(view: content, in: name, using: content)
		HapticManager.tic()
	}
}

public extension ContainerConfigurationProtocol where Self == HUDContainerConfiguration {
	static var hudConfiguration: HUDContainerConfiguration {
		HUDContainerConfiguration()
	}
}

public struct HUDContainerConfiguration: ContainerConfigurationProtocol {
	public var displayType: ContainerViewDisplayType { .vertical }
	public var queueType: ContainerViewQueueType { /*.oneByOne*/.multiple }
	public var alignment: Alignment? { .top }
	public var spacing: CGFloat { 3.0 }
	public var maximumNumberOfViewsInMultipleMode: UInt { 4 }
	public var delayForShowingNext: TimeInterval { 0.5 }
	public var transition: AnyTransition? { .scale.combined(with: .opacity) }
	public var dismissGesture: ContainerViewDismissGesture? { .swipeUp }

//	public var autoDismiss: ContainerViewAutoDismiss? {
//		return _dismiss
//	}

	public var shadowStyle: ContainerViewShadowStyle? {
		.disable
	}

//	private var _dismiss: ContainerViewAutoDismiss?

//	public init(_ dismiss: ContainerViewAutoDismiss? = .seconds(2), enableBackTouch:Bool = false) {
//		self._dismiss = dismiss
//		self._enableBackTouch = enableBackTouch
//	}
}


public struct HapticManager {
	public static func tic() {
		let impact = UIImpactFeedbackGenerator(style: .soft)
		impact.prepare()
		impact.impactOccurred()
	}
		
	public static func select() {
		let sele = UISelectionFeedbackGenerator()
		sele.prepare()
		sele.selectionChanged()
	}
}
