//
//  TouchScaleButtonStyle.swift
//  family-dao
//
//  Created by KittenYang on 1/31/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

struct TouchScaleButtonStyle: PrimitiveButtonStyle {

  func makeBody(configuration: PrimitiveButtonStyleConfiguration) -> some View {
	AppButton(configuration: configuration)
  }

  struct AppButton: View {

	// MARK: State properties

	@State var focused: Bool = false

	// MARK: - Properties

	let configuration: PrimitiveButtonStyle.Configuration
	  
	// MARK: - Body

	var body: some View {
	  return GeometryReader { geometry in
		Rectangle()
		  .fill(Color.black)
		  .overlay(
			configuration.label
			  .foregroundColor(.white)
		  )
		  .cornerRadius(geometry.size.height / 2)
	  }
	  .scaleEffect(focused ? 1.1 : 1.0)
	  .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
	  .padding()
	  .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
		.onChanged { v in
			print("onChanged:\(v)")
		  withAnimation {
			self.focused = true
		  }
		}
		.onEnded { v in
			print("onEnded")
		  withAnimation {
			self.focused = false
			configuration.trigger()
		  }
		})
	}
  }
}

