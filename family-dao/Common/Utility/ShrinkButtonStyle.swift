//
//  ShrinkButtonStyle.swift
//  family-dao
//
//  Created by KittenYang on 1/17/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

struct ShrinkButtonStyle: ButtonStyle {

	var normalColor: Color
	var highlightColor: Color
	
	init(normalColor: Color, highlightColor: Color) {
		self.normalColor = normalColor
		self.highlightColor = highlightColor
	}
	
  func makeBody(configuration: Self.Configuration) -> some View {
	configuration.label
//	  .padding()
//	  .foregroundColor(.white)
	  .background(configuration.isPressed ? highlightColor : normalColor)
	  .cornerRadius(8.0)
	  .scaleEffect(configuration.isPressed ? 0.7 : 1.0)
	  .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }

}
