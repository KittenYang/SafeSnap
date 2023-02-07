//
//  MultiTabbarHeader.swift
//  family-dao
//
//  Created by KittenYang on 9/1/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

extension HorizontalAlignment {
	// 自定义了一个 HorizontalAlignment, 该参考值始终和视图左对齐
	static let underlineLeading = HorizontalAlignment(UnderlineLeadingID.self)
	private enum UnderlineLeadingID: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat {
			return context[.leading]
		}
	}
	
	// 自定义了一个 HorizontalAlignment, 该参考值始终和视图中央对齐
	static let underlineCenter = HorizontalAlignment(UnderlineCenterID.self)
	private enum UnderlineCenterID: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat {
			let cc = context[HorizontalAlignment.center]

			return cc
		}
	}
	
	// 自定义了一个 HorizontalAlignment, 该参考值为视图宽度的三分之一
	static let oneThirdWidth = HorizontalAlignment(OneThirdWidthID.self)
	private enum OneThirdWidthID: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat {
			return context.width / 3
		}
	}
}

// 也可以为 ZStack 、frame 定义同时具备两个维度值的参考点
extension Alignment {
	static let customAlignment = Alignment(horizontal: .oneThirdWidth, vertical: .top)
}

struct CGRectPreferenceKey: PreferenceKey {
	static var defaultValue = CGRect.zero
	
	static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
		value = nextValue()
	}
	
	typealias Value = CGRect
}

struct GridViewHeader_Previews: PreviewProvider {
	static var previews: some View {
		TabView {
			GridViewHeader()
		}
	}
}

struct GridViewHeader : View {
	
	@State private var activeIdx: Int = 0
	@State private var bindedWidths: [CGRect] = Array(repeating: .zero, count: 4)
	
	private let geoName = "grid_header"
	
	var body: some View {
		return VStack(alignment: .underlineLeading) {
			HStack {
				Text("Tweets")
					.modifier(MagicStuff(activeIdx: $activeIdx, idx: 0))
					.background(CGRectGeometry(coordinateSpaceName: geoName))
					.onPreferenceChange(CGRectPreferenceKey.self, perform: { self.bindedWidths[0] = $0 })
				
				Spacer()
				
				Text("Tweets & Replies")
					.modifier(MagicStuff(activeIdx: $activeIdx, idx: 1))
					.background(CGRectGeometry(coordinateSpaceName: geoName))
					.onPreferenceChange(CGRectPreferenceKey.self, perform: { self.bindedWidths[1] = $0 })
				
				Spacer()
				
				Text("Media")
					.modifier(MagicStuff(activeIdx: $activeIdx, idx: 2))
					.background(CGRectGeometry(coordinateSpaceName: geoName))
					.onPreferenceChange(CGRectPreferenceKey.self, perform: { self.bindedWidths[2] = $0 })
				
				Spacer()
				
				Text("Likes")
					.modifier(MagicStuff(activeIdx: $activeIdx, idx: 3))
					.background(CGRectGeometry(coordinateSpaceName: geoName))
					.onPreferenceChange(CGRectPreferenceKey.self, perform: { self.bindedWidths[3] = $0 })
				
			}
			.coordinateSpace(name: geoName)
			.frame(height: 50)
			.padding(.horizontal, 10)
			Rectangle()
				.alignmentGuide(.underlineLeading) { d in d[.leading]  }
				.frame(width: self.bindedWidths[activeIdx].size.width,  height: 2)
				.animation(.linear)
		}
	}
}

struct CGRectGeometry: View {
	let coordinateSpaceName:String//(name: "OuterV")
	var body: some View {
		GeometryReader { geometry in
			let frame = geometry.frame(in: .named(coordinateSpaceName))
			Rectangle()
				.fill(Color.clear)
				.preference(key: CGRectPreferenceKey.self, value: frame)
		}
	}
}

struct MagicStuff<T:Equatable>: ViewModifier {
	@Binding var activeIdx: T
	let idx: T
	
	func body(content: Content) -> some View {
		Group {
			if activeIdx == idx {
				content
					.alignmentGuide(.underlineCenter) // 对齐动画关键2
					.onTapGesture { self.activeIdx = self.idx }
				
			} else {
				content.onTapGesture { self.activeIdx = self.idx }
			}
		}
	}
}
