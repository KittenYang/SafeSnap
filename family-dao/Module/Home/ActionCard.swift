//
//  ActionCard.swift
//  family-dao
//
//  Created by KittenYang on 1/10/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

struct ActionCard: View {
	@State var action: ActionModel
	
	var color: Color {
		if action.colorHexString.isEmpty {
			return .appTheme
		}
		return Color(hexString: action.colorHexString)
	}
	
	var coin: String {
		return action.amount// + "\(WalletManager.shared.currentFamily?.token?.symbol ?? "")"
	}
	
	var body: some View {
		ZStack {
			color
			HStack {
				VStack(alignment: .leading) {
					HStack(alignment: .top) {
						Image(systemName: action.iconSymbolName)
							.resizable()
							.frame(width: 22.0, height: 22.0)
							.scaledToFit()
							.fixedSize()
						Spacer(minLength: 3.0)
						Text("\(Image(systemName: "coloncurrencysign.circle.fill")) \(Text(coin))")
							.font(.rounded(size: 14.0, weight: .medium))
							.layoutPriority(2)
					}
					.foregroundColor(.white)
					Spacer(minLength: 3.0)
					Text(action.name)
						.font(.rounded(size: 16.0,weight: .bold))
						.foregroundColor(.white)
				}
				Spacer(minLength: 3.0)
			}
			.padding(.init(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
		}
		.cornerRadius(9.0)
//		.frame(width: 80.0, height: 90.0,alignment: .leading)
//		.background(
////					LinearGradient(gradient: .init(colors: action.model.gradient.colors), startPoint: .top, endPoint: .bottom)
//			action.model.gradient.colors.first ?? .appTheme
//		)
//				.shadow(color:.black.opacity(0.15),radius: 19.0, y:4)
//				.overlay(
//					RoundedRectangle(cornerRadius: 9.0)
//						.stroke(.white, lineWidth: 1.5)
//				)
//				HStack {
//					Image(systemName: action.model.iconSymbolName)
//						.resizable()
//						.foregroundColor(.white)
//						.frame(width: 22.0, height: 22.0)
//						.padding(.all,6.0)
//						.background(Color(hexString: action.model.colorHex))
//						.cornerRadius(5.0)
//					Text(action.model.name)
//						.font(.system(size: 15.0))
//				}
//				.groupListStyle()
	}
}

struct ActionCard_Previews: PreviewProvider {
    static var previews: some View {
		ActionCard(action: .demo)
    }
}
