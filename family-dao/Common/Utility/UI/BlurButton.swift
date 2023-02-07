//
//  BlurButton.swift
//  family-dao
//
//  Created by KittenYang on 12/23/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import NetworkKit

struct BlurButton: View {
	var uiImage: UIImage?
	var text: String
	var subText: String?
	var baseFontSize: CGFloat
	var action:(() async ->Void)?
	
	init(uiImage: UIImage?, text: String, subText: String?, baseFontSize: CGFloat, action:( /*@Sendable*/ () async -> Void)?) {
		self.uiImage = uiImage
		self.text = text
		self.subText = subText
		self.action = action
		self.baseFontSize = baseFontSize
	}
	
	var body: some View {
		Button {
			Task {
				await action?()
			}
		} label: {
			HStack(spacing:4.0) {
				if let uiImage {
					Image(uiImage: uiImage)
						.font(.system(.body,design: .rounded).weight(.medium))
				}
				VStack {
					Text(text)
						.font(.rounded(size: baseFontSize, weight: .medium))
					if let subText {
						Text(subText)
							.font(.rounded(size: baseFontSize * 0.8, weight: .regular))
					}
				}
			}
//			.frame(width: 100,height: 50)
			.padding(.all,7.0)
			.foregroundColor(.label.opacity(0.5))
			.background(
				VisualEffect(style: .systemUltraThinMaterial)
					.opacity(0.9)
			)
			.cornerRadius(8)
			.overlay( /// apply a rounded border
				RoundedRectangle(cornerRadius: 8)
					.inset(by: -1)
					.stroke(Color.label.opacity(0.4), lineWidth: 2)
			)
			.shadow(color: Color.black.opacity(0.07), radius: 9, x: 0, y: 4)
			.compositingGroup()
		}
		.buttonStyle(ScaleButtonStyle())
//		.buttonStyle(.plain)
	}
}
