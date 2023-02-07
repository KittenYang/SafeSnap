//
//  SpaceCreateHackerView.swift
//  family-dao
//
//  Created by KittenYang on 2/4/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import KYFoundationKit

struct SpaceCreateHackerView: View {
	
	@StateObject var global = SnapshotManager.shared.global
	
	@State var blinkOpacity: Double = 1.0
	
    var body: some View {
		GeometryReader { proxy in
			ZStack(alignment: .center) {
				LinearGradient(colors: [.init(hexString: "10100C"),.init(hexString: "0D1C02")],startPoint: .top, endPoint: .bottom)
					.frame(
						maxWidth: .infinity,
						maxHeight: .infinity,
						alignment: .topLeading
					)
					.ignoresSafeArea()
				
				ScrollView(showsIndicators: true) {
					ScrollViewReader { value in
						Text("inuut_glocory_liulang_eracth".appLocalizable)
							.font(.pixel(size: 38.0))
							.padding()
						
						VStack(alignment: .leading) {
							ForEach(global.creatingSpaceMsg, id:\.self) { msg in
								Text(msg)
									.id(msg)
									.font(.pixel(size: 20.0))
								//							.addGlowEffect(color: .appGreen, color1: .appGreen, color2: .appGreen.opacity(0.6), color3: .black.opacity(0.6))
									.transition(.slide)
									.padding([.leading,.trailing],10.0)
									.padding([.top,.bottom],2.0)
								
							}
							.animation(.easeInOut(duration: 0.3),value: global.creatingSpaceMsg)
							.onChange(of: global.creatingSpaceMsg) { _ in
								value.scrollTo(global.creatingSpaceMsg.last)
							}
						}
						.frame(
							minWidth: 0,
							maxWidth: .infinity,
							minHeight: 0,
							maxHeight: .infinity,
							alignment: .topLeading
						)
						
						Text("_")
							.opacity(blinkOpacity)
							.padding([.leading,.trailing],10.0)
							.animation(.linear(duration: 0.5).repeatForever(autoreverses: true), value: blinkOpacity)
							.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
					}
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
				.foregroundColor(.appGreen)
			}
			.onAppear {
				Delay(0.5, {
					withAnimation {
						blinkOpacity = 0.0
					}
				})
			}
		}
//		.overlay(alignment: .top) {
//			Color.clear
//				.frame(height: getSafeArea().top)
//				.background(.ultraThinMaterial)
//				.ignoresSafeArea()
//				.colorScheme(.dark)
//		}
    }
}

extension Font {
	static func pixel(size: CGFloat) -> Font {
        Font.custom("Ark-Pixel-12px-monospaced-zh_cn-Regular", size: size)
	}
}

struct SpaceCreateHackerView_Previews: PreviewProvider {
	static var demo: SnapshotGlobal = {
		let snap = SnapshotGlobal()
		snap.creatingSpaceMsg = [
			"wqe",
			"dzxsfasfasf",
			"dzxfasfsfas",
			"dzfasfxsfas",
			"dzxsfasfafas",
			"dzxsffasfaas",
			"aaaaadazxsfas"
		]
		return snap
	}()
    static var previews: some View {
		SpaceCreateHackerView(global: demo)
    }
}
