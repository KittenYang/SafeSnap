//
//  LoadMoreView.swift
//  family-dao
//
//  Created by KittenYang on 1/15/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

@MainActor enum Loading:Int {
	case waitingMore
	case loading
	case noMore
}

extension View {
	
	@ViewBuilder
	func enableRefreshLoadMore() -> some View {
//		GeometryReader { proxy in
			self
				.coordinateSpace(name: "queue_list")
//				.environmentObject(AnyObservableObject(proxy))
//		}
	}
	
}

struct LoadMoreView: View {
	
	@Binding var loadingState: Loading
	
	var proxy: GeometryProxy
	
	let runLoadingAction: ()->Void
	
    var body: some View {
		HStack {
			Spacer()
			Group {
				switch loadingState {
				case .waitingMore:
					Text("release_pull_more".appLocalizable)
						.background(CGRectGeometry(coordinateSpaceName: "queue_list"))
						.onPreferenceChange(CGRectPreferenceKey.self, perform: { newRect in
//							print("位移：\(newRect),proxy:\(proxy.size)")
							if newRect.minY <= proxy.size.height - 30.0 {
								self.loadingState = .loading
								SwiftTimer.throttle(interval: .milliseconds(200), identifier: "queue_list_more") {
									self.runLoadingAction()
								}
							}
						})
				case .noMore:
					Text("release_pull_more_done".appLocalizable)
				case .loading:
					ActivityIndicatorView(style: .medium)
				}
			}
			.font(.rounded(size: 13.0))
			.foregroundColor(.appGrayMiddle)
			Spacer()
		}
		.listRowInsets(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
		.listRowBackground(Color.clear)
		.id(loadingState)
    }
}

//struct LoadMoreView_Previews: PreviewProvider {
//    static var previews: some View {
//		LoadMoreView(loadingState: .constant(.loading), proxy: <#Binding<GeometryProxy>#>, runAction: {
//
//		})
//    }
//}
