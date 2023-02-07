//
//  FlipCardView.swift
//  family-dao
//
//  Created by KittenYang on 8/29/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import KYFoundationKit


struct ThreeDimensionalRotationEffect: View, Animatable {
	
	var number: Double
	var animatableData: Double { // SwiftUI 在渲染时发现该视图为 Animatable，则会在状态已改变后，依据时序曲线函数提供的值持续调用 animableData
		get { number }
		set { number = newValue }
	}
	
	@Binding var flipped: Bool
	
	let frontView: any View
	let backView: any View
	
	let fromFrame: CGSize
	let toFrame: CGSize
	let frontCornerRadius: CGFloat
	let endBlock: (()->Void)?
	
	init(flipped:Binding<Bool>,
		 endBlock: (()->Void)?,
		 fromFrame: CGSize,
		 toFrame: CGSize,
		 frontCornerRadius: CGFloat,
		 front: any View,
		 back: any View) {
		self.frontView = front
		self.backView = back
		self._flipped = flipped
		self.endBlock = endBlock
		self.number = flipped.wrappedValue ? 1.0 : 0.0
		self.fromFrame = fromFrame
		self.toFrame = toFrame
		self.frontCornerRadius = frontCornerRadius
	}

	var body: some View {
		ZStack {
			VStack {
				ZStack {
					AnyView(backView)
						.rotation3DEffect(Angle(degrees: 180), axis: (x: 0.0, y: 1.0, z: 0.0))
					AnyView(frontView)
						.zIndex(number > 0.5 ? -1.0 : 0.0)
				}
				.frame(width: fromFrame.width+(toFrame.width-fromFrame.width)*number, height: fromFrame.height+(toFrame.height-fromFrame.height)*number)
				.foregroundColor(.white)
				.background(Color.white)
				.cornerRadius(flipped ? 14.0 : frontCornerRadius)
//				.clipShape(RoundedRectangle(cornerRadius: flipped ? frontCornerRadius : 14.0, style: .continuous))
				.rotation3DEffect(
					flipped ? Angle(degrees: 180) : .zero,
					axis: (x: 0.0, y: 1.0, z: 0.0)
				)
//				.onTapGesture {
//					flipped = true//.toggle()
//				}
			}
		}
	}
}

