//
//  ProtectUI.swift
//  family-dao
//
//  Created by KittenYang on 9/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import BiometricAuthentication

struct ProtectUI: View {
	
	@EnvironmentObject var pathManager: NavigationStackPathManager
	
	var authoriteSuccessHandler: ((String)->Void)?
	
	var body: some View {
		GeometryReader { proxy in
			VStack(alignment: .leading) {
				Spacer()
				HStack {
					Spacer()
					Image("face_id_page")
						.resizable()
						.scaledToFit()
					Spacer()
				}
				Spacer()
				Text("fasfnew_hofasfafme_name_perospn_dsafsaasf".appLocalizable)
					.foregroundColor(.white)
                    .font(.rounded(size: 24.0))
				Text("fassaffasfnefasfw_hoffassafasfafme_name_perospn".appLocalizable)
					.foregroundColor(.white)
					.font(.rounded(size: 16.0))
					.padding([.bottom], 20.0)
				VStack(spacing: 12.0) {
					Button {
						Task {
							await handleFaceID()							
						}
					} label: {
						Text("Use FaceID")
							.solidBackgroundWithCorner(color: .appTheme, idealWidth: proxy.size.width)
					}
//					Button {
//						handlePassword()
//					} label: {
//						Text("使用密码")
//							.clearBackgroundWhiteBorder(idealWidth: proxy.size.width)
//					}
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.padding()
			.background(Gradient(colors: [.appGradientRed1, .appGradientRed2]))
		}
	}
	
}

extension ProtectUI {
	private func handleFaceID() async {
		if await FaceID() {
			debugPrint("Face ID 认证通过！")
			if pathManager.path.count > 0 {
				pathManager.path.removeLast()
			}
			authoriteSuccessHandler?(WalletManager.pwdForFaceID)
		}
	}
	
	private func handlePassword() {
		//TODO: 处理用户手动输入密码逻辑
		WalletManager.pwdForInput = "TestPasswordForFamilyDao"
		if let pwdForInput = WalletManager.pwdForInput, pathManager.path.count > 0 {
			pathManager.path.removeLast()
			authoriteSuccessHandler?(pwdForInput)
		}
	}
}

struct ProtectUI_Previews: PreviewProvider {
    static var previews: some View {
			ProtectUI()
    }
}

extension View {
	func clearBackgroundWhiteBorder(idealWidth: CGFloat, color: Color = .label) -> some View {
		self
			.font(.rounded(size: 20.0))
			.foregroundColor(color)
			.frame(idealWidth: idealWidth, maxWidth: 400.0, alignment: .center)
			.padding()
			.background(.clear)
			.border(.white, cornerRadius: 12.0)
	}
	
	func solidBackgroundWithCorner(color: Color, idealWidth: CGFloat) -> some View {
		self
			.font(.rounded(size: 20.0))
			.foregroundColor(.white)
			.frame(idealWidth: idealWidth, maxWidth: 400.0, alignment: .center)
			.padding()
			.background(color)
			.cornerRadius(12.0)
	}
	
}
