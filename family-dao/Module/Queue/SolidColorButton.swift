//
//  SolidColorButton.swift
//  family-dao
//
//  Created by KittenYang on 12/3/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import NetworkKit

struct SolidColorButton: View {
	
	@State var text: String
	@State var textColor: Color = .white
	@State var bkgColor: Color
	@State var shouldDisabled: Bool = false
	@State var font: Font?
	
//	var frame: CGSize?
	
	var tapAction: (()->Void)?
	
    var body: some View {
		Button {
			tapAction?()
		} label: {
			Text(text)
				.font(font ?? Font.rounded(size: 15.0))
				.foregroundColor(textColor)
		}
		.addBKG(color: bkgColor)
		.disabled(shouldDisabled)
		.buttonStyle(BorderlessButtonStyle())
//		.modifier(if: frame != nil) { button in
//			button.frame(width: frame?.width, height: frame?.height)
//		} else: { button in
//			button.fixedSize()
//		}

    }
}

struct SolidColorButton_Previews: PreviewProvider {
    static var previews: some View {
		SolidColorButton(text: "fasfnew_hofasfafme_name_perospnvovyeee".appLocalizable, bkgColor: .appTheme)			
    }
}

extension View {
	func addZStackBKG(color: Color = .appBlue,alignment: Alignment = .center, paddings:EdgeInsets = EdgeInsets(top: 7.0, leading: 12.0, bottom: 7.0, trailing: 12.0)) -> some View {
		return ZStack(alignment: alignment) {
			color
			self.padding(paddings)
		}
		.clipShape(RoundedRectangle(cornerRadius: 6.0, style: .continuous))
	}
}

extension View {
	func addBKG(color: Color = .appBlue) -> some View {
		return self
			.padding(EdgeInsets(top: 7.0, leading: 12.0, bottom: 7.0, trailing: 12.0))
			.background(color)
			.clipShape(RoundedRectangle(cornerRadius: 6.0, style: .continuous))
	}
}


