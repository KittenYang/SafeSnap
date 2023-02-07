//
//  ActivityIndicatorView.swift
//  family-dao
//
//  Created by KittenYang on 9/8/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
	
	let style: UIActivityIndicatorView.Style
	
	func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
		return UIActivityIndicatorView(style: style)
	}
	
	func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
		uiView.startAnimating()
	}
}
