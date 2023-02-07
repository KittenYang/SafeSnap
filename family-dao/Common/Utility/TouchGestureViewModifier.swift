//
//  TouchGestureViewModifier.swift
//  family-dao
//
//  Created by KittenYang on 9/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

struct TouchGestureViewModifier: ViewModifier {
	
	let minimumDistance: CGFloat
	let touchBegan: () -> Void
	let touchEnd: (Bool) -> Void
	
	@State private var hasBegun = false
	@State private var hasEnded = false
	
	init(minimumDistance: CGFloat, touchBegan: @escaping () -> Void, touchEnd: @escaping (Bool) -> Void) {
		self.minimumDistance = minimumDistance
		self.touchBegan = touchBegan
		self.touchEnd = touchEnd
	}
	
	private func isTooFar(_ translation: CGSize) -> Bool {
		let distance = sqrt(pow(translation.width, 2) + pow(translation.height, 2))
		return distance >= minimumDistance
	}
	
	func body(content: Content) -> some View {
		content.gesture(DragGesture(minimumDistance: 0)
			.onChanged { event in
				guard !self.hasEnded else { return }
				
				if self.hasBegun == false {
					self.hasBegun = true
					self.touchBegan()
				} else if self.isTooFar(event.translation) {
					self.hasEnded = true
					self.touchEnd(false)
				}
			}
			.onEnded { event in
				if !self.hasEnded {
					let success = !self.isTooFar(event.translation)
					self.touchEnd(success)
				}
				self.hasBegun = false
				self.hasEnded = false
			}
		)
	}
}

extension View {
	func onTouchGesture(minimumDistance: CGFloat = 20.0,
											touchBegan: @escaping () -> Void,
											touchEnd: @escaping (Bool) -> Void) -> some View {
		modifier(TouchGestureViewModifier(minimumDistance: minimumDistance, touchBegan: touchBegan, touchEnd: touchEnd))
	}
}

