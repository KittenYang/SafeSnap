//
//  AnimatedTextView.swift
//  family-dao
//
//  Created by KittenYang on 8/28/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

struct AnimatedTextView: View, Animatable {
	static var timestamp = Date()
	var number: Double
	var animatableData: Double {
		get { number }
		set {
			number = newValue
		}
	}
	
	var body: some View {
		let duration = Date().timeIntervalSince(Self.timestamp).formatted(.number.precision(.fractionLength(2)))
		let currentNumber = number.formatted(.number.precision(.fractionLength(2)))
		let _ = print(duration, currentNumber, separator: ",")
		
		Text(number, format: .number.precision(.fractionLength(3)))
		Text("\("fasfnew_hofasfafme_name_perospn_currec_valess".appLocalizable)\(number)")
	}
}

struct TransitionDemo: View {
	@State var show = true
	var body: some View {
		VStack {
			Spacer()
			Text("Hello")
			if show {
				Text("World")
					.transition(.opacity.combined(with: .slide).combined(with: .scale)) // 可动画部件（包装在其中）
			}
			Spacer()
			Button(show ? "Hide" : "Show") {
				show.toggle()
			}
		}
		.animation(.easeInOut(duration:0.5), value: show) // 创建关联依赖、设定时序曲线函数
		.frame(width: 300, height: 300)
	}
}

