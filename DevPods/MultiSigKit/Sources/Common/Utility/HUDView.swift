//
//  HUDView.swift
//  MultiSigKit
//
//  Created by KittenYang on 12/23/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import SwiftUIOverlayContainer
import NetworkKit

public struct HUDView: View {
	
	var title: String
	var subTitle: String?
	var imageInfo: (UIImage?, UIColor?)

	init(title: String, subTitle: String?, imageInfo: (UIImage?, UIColor?)) {
		self.title = title
		self.subTitle = subTitle
		self.imageInfo = imageInfo
	}
	
	public var body: some View {
		Group{
			HStack(spacing: 16){
				if let image = imageInfo.0 {
					Image(uiImage: image)
						.hudModifier()
						.foregroundColor(.init(uiColor: imageInfo.1 ?? .green))
				}
				
				VStack(alignment: .center, spacing: 2){
					Text(title)
                        .font(.rounded(size: 15.0))
                        .bold()
						.multilineTextAlignment(.center)
						.textColor(nil)
					if let subTitle {
						Text(subTitle)
                            .font(.rounded(size: 13.0))
							.opacity(0.7)
							.multilineTextAlignment(.center)
							.textColor(nil)
					}
				}
			}
			.padding(.horizontal, 24)
			.padding(.vertical, 8)
			.frame(minHeight: 50)
			.alertBackground(nil)
			.overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
			.clipShape(Capsule())
			.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 6)
			.compositingGroup()
		}
		.padding(.top)
	}
	
}


fileprivate struct BackgroundModifier: ViewModifier{
	
	var color: Color?
	
	@ViewBuilder
	func body(content: Content) -> some View {
		if color != nil{
			content
				.background(color)
		}else{
			content
				.background(VisualEffect(style: .prominent))
		}
	}
}


public struct VisualEffect: UIViewRepresentable {
	@State var style : UIBlurEffect.Style // 1
	
	public init(style: UIBlurEffect.Style) {
		_style = State(wrappedValue: style)
	}
	
	public func makeUIView(context: Context) -> UIVisualEffectView {
		return UIVisualEffectView(effect: UIBlurEffect(style: style)) // 2
	}
	public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
	} // 3
}


//public struct BlurView: UIViewRepresentable {
//	public typealias UIViewType = UIVisualEffectView
//	
//	public func makeUIView(context: Context) -> UIVisualEffectView {
//		return UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
//	}
//	
//	public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
//		uiView.effect = UIBlurEffect(style: .prominent)
//	}
//}


fileprivate struct TextForegroundModifier: ViewModifier{
	
	var color: Color?
	
	@ViewBuilder
	func body(content: Content) -> some View {
		if color != nil{
			content
				.foregroundColor(color)
		}else{
			content
		}
	}
}


fileprivate extension View {
	func textColor(_ color: Color? = nil) -> some View{
		modifier(TextForegroundModifier(color: color))
	}
	
	func alertBackground(_ color: Color? = nil) -> some View{
		modifier(BackgroundModifier(color: color))
	}
}

fileprivate extension Image{
	
	func hudModifier() -> some View{
		self
			.renderingMode(.template)
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(maxWidth: 20, maxHeight: 20, alignment: .center)
	}
}

struct Message<S: ShapeStyle>: View {
	init(height: CGFloat, background: S, title: String, subTitle: String?, textColor: UIColor, imageInfo: (UIImage?, UIColor?), loading:Bool, delay: Double) {
		self.height = height
		self.background = background
		self.title = title
		self.subTitle = subTitle
		self.textColor = textColor
		self.imageInfo = imageInfo
		self.loading = loading
		self.delay = delay
	}

	let height: CGFloat
	let background: S
	let title: String
	let subTitle: String?
	let textColor: UIColor
	let imageInfo: (UIImage?, UIColor?)
	let loading:Bool
	let delay: Double

	var body: some View {
		HUDView(title: title, subTitle: subTitle, imageInfo: imageInfo)
	}
}

extension Message: ContainerViewConfigurationProtocol {
	var transition: AnyTransition? {
		.move(edge: .top).combined(with: .opacity)
	}

	var dismissGesture: ContainerViewDismissGesture? {
		.tap
	}
	
	var autoDismiss: ContainerViewAutoDismiss? {
		loading ? .disable : .seconds(delay)
	}
}
