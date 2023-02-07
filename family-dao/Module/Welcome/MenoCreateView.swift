//
//  MenoCreateView.swift
//  family-dao
//
//  Created by KittenYang on 6/26/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import SwiftUI
import MultiSigKit

/*
 新用户助记词
 */
struct MenoCreateView: View {
	
	@EnvironmentObject var pathManager: NavigationStackPathManager

	//	@Binding
	var wallet: Wallet?
	var walletName: String?
	var password: String?
	
//	init(wallet: Binding<Wallet?>, name: String?, password: String?) {
//		self.walletName = name
//		self.password = password
//		self._wallet = wallet
//	}
	init(wallet: Wallet?, name: String?, password: String?) {
		self.wallet = wallet
		self.walletName = name
		self.password = password
	}
	
	private var adaptiveLayout = [GridItem(.adaptive(minimum: 100))]
	
	private var mnemonicsComponents:[String]? {
		return self.wallet?.mnemonics?.components(separatedBy: " ")
	}

	var body: some View {
		GeometryReader { proxy in
			VStack {
				if let mnemonicsComponents, !mnemonicsComponents.isEmpty {
					LazyVGrid(columns: adaptiveLayout, spacing: 20) {
						ForEach(0..<mnemonicsComponents.count, id:\.self) { index in
							if let word = mnemonicsComponents[index] {
								Text(word)
									.font(.rounded(size: 20.0, weight: .medium))
									.foregroundColor(.label)
									.addBKG(color: .secondarySystemBackground)
							}
						}
					}
				}
				
				HStack(spacing: 20.0) {
					Button {
						if let mn = mnemonicsComponents, mn.count > 0 {
							let two = mn.suffix(mn.count/2)
							let pasteboard = UIPasteboard.general
							pasteboard.string = two.joined(separator: " ")
							AppHUD.show("copy_suss".appLocalizable)
						}
					} label: {
						HStack {
							Image(systemName:"doc.on.doc")
							Text("keoekfasfnew_hofasfafme_name_perospns".appLocalizable)
						}
						.foregroundColor(.label)
						.padding(.all,10.0)
						.background(.secondarySystemBackground)
						.cornerRadius(24.0)
					}
					.padding(.top, 20.0)
					
					Button {
						if let mn = mnemonicsComponents, mn.count > 0 {
							let two = mn.prefix(mn.count/2)
							let pasteboard = UIPasteboard.general
							pasteboard.string = two.joined(separator: " ")
							AppHUD.show("copy_suss".appLocalizable)
						}
					} label: {
						HStack {
							Image(systemName:"doc.on.doc")
							Text("fasfnew_hofasfafme_name_perospn_1111".appLocalizable)
						}
						.foregroundColor(.label)
						.padding(.all,10.0)
						.background(.secondarySystemBackground)
						.cornerRadius(24.0)
					}
					.padding(.top, 20.0)
				}
				.font(.rounded(size: 14.0))
				

				
				Spacer()
				
				VStack(alignment: .leading,spacing: 15.0) {
					Text("fasfsfasfnfasfasew_ho_fasfafasfafme_name_perospn_fsaf".appLocalizable).font(.rounded(size: 15.0))
					Text("fasfnew_hofasfafme_name_perospn_notenoytevhda".appLocalizable)
						.font(.rounded(size: 17.0, weight: .bold))
						.foregroundColor(.appRed)
				}
					
				VStack(spacing: 12.0) {
					Button {
						saveMeno()
					} label: {
						Text("fasfnew_hofasfafme_name_perospn_fafaikcoudc".appLocalizable)
							.solidBackgroundWithCorner(color: .appTheme, idealWidth: proxy.size.width)
					}
					Button {
						AppHUD.show("klofasfa_fasfnew_hofasfafme_name_perospn_faasf".appLocalizable)
					} label: {
						Text("fas_kslees_fasfnew_hofasfafme_name_perospn".appLocalizable)
							.clearBackgroundWhiteBorder(idealWidth: proxy.size.width)
							.font(.rounded(size: 20.0))
					}
				}
			}
			.navigationTitle("dfasf_loelsfasfnew_hofasfafme_name_perospn".appLocalizable)
			.padding()
		}
	}
}

extension MenoCreateView {
	private func saveMeno() {
		guard let mnemonics = self.wallet?.mnemonics, let name = self.walletName else {
			return
		}
	
		debugPrint("保存到 Keychain: mnemonics: \(mnemonics)")
		debugPrint("保存到 Keychain: name: \(name)")

		KeychainManager.saveMnemonics(name: name, mnemonics: mnemonics)

		DispatchQueue.main.async {
			NavigationStackPathManager.shared.showSheetModel.presented = false
		}
	}
}

struct MenoCreateView_Previews: PreviewProvider {
	static var previews: some View {
		MenoCreateView(wallet: Wallet.preview2, name: nil, password: nil)
	}
}
