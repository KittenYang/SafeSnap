//
//  AppTabbar2.swift
//  family-dao
//
//  Created by KittenYang on 9/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

struct CustomSwiftUITabBar<TabItem: Tabbable>: View {
//	@Binding var tagSelect: String
	
	private let selectedItem: TabBarSelection<TabItem>
	private var tabItemStyle : AnyTabItemStyle
	private var tabBarStyle  : AnyTabBarStyle
	@State private var items: [TabItem]
	@Binding private var visibility: TabBarVisibility
	var flag: Binding<Bool>
	public init(
			selection: Binding<TabItem>,
			visibility: Binding<TabBarVisibility> = .constant(.visible),
			flag: Binding<Bool>
	) {
		self.flag = flag
			self.tabItemStyle = .init(itemStyle: DefaultTabItemStyle(), flag: flag)
			self.tabBarStyle = .init(barStyle: DefaultTabBarStyle())
			
			self.selectedItem = .init(selection: selection)
			
			self._items = .init(initialValue: .init())
			self._visibility = visibility
	}
	
	private var tabItems: some View {
			HStack {
					ForEach(self.items, id: \.self) { item in
							self.tabItemStyle.tabItem(item: item, isSelected: self.selectedItem.selection == item, flag: flag)
									.onTapGesture { [item] in
										if let customHandler = item.customHandler {
											customHandler(item)
										} else {
											self.selectedItem.selection = item
											self.selectedItem.objectWillChange.send()
										}
									}
					}
					.frame(maxWidth: .infinity)
			}
	}
	
	var body: some View {
		GeometryReader { geometry in
				VStack {
						Spacer()
						
						self.tabBarStyle.tabBar(with: geometry) {
								.init(self.tabItems)
						}
				}
				.edgesIgnoringSafeArea(.bottom)
				.visibility(self.visibility)
		}
		
//		VStack (alignment: .leading) {
//			Spacer()
//			HStack(spacing: 0) {
//				TabBarButton(tagSelect: $tagSelect, systemName: "house.circle").background(Color.blue)
//				TabBarButton(tagSelect: $tagSelect, systemName: "pencil").background(Color.green)
//				Button(action: {}, label: {
//					Image(systemName: "magnifyingglass")
//						.resizable()
//						.renderingMode(.template)
//						.aspectRatio(contentMode: .fit)
//						.frame(width:24, height:24)
//						.foregroundColor(.white)
//						.padding(20)
//						.background(Color.green)
//						.clipShape(Circle())
//					//Shadows
//						.shadow(color: Color.black.opacity(0.05), radius: 5, x: 5, y: 5)
//						.shadow(color: Color.black.opacity(0.05), radius: 5, x: -5, y: -5)
//				})
//				.tag("magnifyingglass")
//
//				TabBarButton(tagSelect: $tagSelect, systemName: "bell").background(Color.red)
//				TabBarButton(tagSelect: $tagSelect, systemName: "cart").background(Color.yellow)
//			}
//		}
//		.padding(.bottom,getSafeArea().bottom == 0 ? 15 : getSafeArea().bottom)
//		// no background or use opacity, like this
//		.background(Color.white.opacity(0.01)) // <-- important
	}
}

extension View {
	func getSafeArea()-> UIEdgeInsets {
		return UIApplication.shared.windows.first?.safeAreaInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}
}

struct TabBarButton: View {
	@Binding var tagSelect: String
	var systemName: String
	
	var body: some View{
		Button(action: {tagSelect = systemName }, label: {
			VStack(spacing: 8){
				Image(systemName)
					.resizable()
					.renderingMode(.template)
					.aspectRatio(contentMode: .fit)
					.frame(width:28, height: 28)
			}
			.frame(maxWidth: .infinity)
		})
	}
}

struct Home: View {
	@State var tagSelect = "house.circle"
	
	init() {
		UITabBar.appearance().isHidden = false
	}
	
	var body: some View {
		ZStack {
			TabView (selection: $tagSelect) {
				Color.blue.tag("house.circle")
				Color.green.tag("pencil")
				Color.pink.tag("magnifyingglass")
				Color.red.tag("bell")
				Color.yellow.tag("cart")
			}
//			CustomSwiftUITabBar(tagSelect: $tagSelect)
		}
		.ignoresSafeArea()
	}
}

extension View {
	func getRect()->CGRect {
		return UIScreen.main.bounds
	}
}


struct Home2_Previews: PreviewProvider {
	static var previews: some View {
		TabView {
			Home()
		}
	}
}


