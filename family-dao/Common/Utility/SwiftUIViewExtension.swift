//
//  SwiftUIViewExtension.swift
//  family-dao
//
//  Created by KittenYang on 8/30/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI


extension View {
	/// condition clip
	@ViewBuilder
	func clipped(enable: Bool) -> some View {
		if enable {
			clipped()
		} else {
			self
		}
	}
	
	/// set zIndex by timeStamp of indentifiableView
	func zIndex(timeStamp: Date = Date()) -> some View {
		let index = timeStamp.timeIntervalSince1970
		return zIndex(index)
	}
}

struct ScaleButtonStyle: ButtonStyle {
	func makeBody(configuration: Self.Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.8 : 1.0)
			.animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
	}
}


//MARK: Dynamic Hidden
struct Show: ViewModifier {
	
	@Binding var isVisible: Bool
	
	@ViewBuilder
	func body(content: Content) -> some View {
		if isVisible {
			content
		} else {
			content.hidden()
		}
	}

}

extension View {
	func show(isVisible: Binding<Bool>) -> some View {
		ModifiedContent(content: self, modifier: Show(isVisible: isVisible))
	}
}

//MARK: Embed in Navigation
struct EmbedNavigation: ViewModifier {

	// 这里一定要是 @StateObject，换成 @ObservedObject pop 的时候会莫名 crash
	@StateObject var pathManager : NavigationStackPathManager = NavigationStackPathManager()
	
	@ViewBuilder
	func body(content: Content) -> some View {
		NavigationStack(path: $pathManager.path) {
			content
				.navigationDestination(for: AppPage.self) { des in
					des.destinationPage
				}
		}
		.accentColor(.appTheme)
		.environmentObject(pathManager)
	}

}

extension View {
	func embedInNavigation() -> some View {
		ModifiedContent(content: self, modifier: EmbedNavigation())
	}
}


struct SizePreferenceKey: PreferenceKey {
	static var defaultValue: CGSize = .zero
	
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}

struct MeasureSizeModifier: ViewModifier {
	func body(content: Content) -> some View {
		content.background(GeometryReader { geometry in
			Color.clear.preference(key: SizePreferenceKey.self,
														 value: geometry.size)
		})
	}
}

extension View {
	func measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
		self.modifier(MeasureSizeModifier())
			.onPreferenceChange(SizePreferenceKey.self, perform: action)
	}
}

#if canImport(UIKit)
extension View {
		static func hideKeyboard() {
				UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
		}
}
#endif
