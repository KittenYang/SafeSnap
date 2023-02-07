//
//  VisualEffectView.swift
//  family-dao
//
//  Created by KittenYang on 8/30/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    
import SwiftUI

/// A view used to blur the grid, using a UIViewRepresentable of UIKit's UIVisualEffect
struct VisualEffectView: UIViewRepresentable {
	var uiVisualEffect: UIVisualEffect?
	
	func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
		UIVisualEffectView()
	}
	
	func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
		uiView.effect = uiVisualEffect
	}
}

