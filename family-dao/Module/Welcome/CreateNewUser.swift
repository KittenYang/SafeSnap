//
//  CreateNewUser.swift
//  family-dao
//
//  Created by KittenYang on 9/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import SwiftUIX


struct CreateNewUser: View, InputCheckable {
	func inputs() -> [[String]] {
		return [
			[self.walletName, "fasfnew_hofasfafme_name_perospn".appLocalizable]
		]
	}
	
	@EnvironmentObject var pathManager: NavigationStackPathManager
	
//	@StateObject var pathManager = NavigationStackPathManager()
	
	@State var walletName: String = ""
	@State var wallet: Wallet?
	
	@State var alert: Bool = false
	
	var body: some View {
		GeometryReader { proxy in
			VStack(spacing: 40.0) {
				VStack(alignment: .leading) {
					Text("fasfnew_hofasfafme_name_perospn".appLocalizable)
						.font(.rounded(size: 16.0))
						.foregroundColor(Color.appGray9E)
					TextField("fasfnew_hofasfafme_name_perospn".appLocalizable, text: $walletName)
						.padding()
						.background(Color.secondarySystemBackground)
						.cornerRadius(12.0)
				}
				Button {
					handleCreateWalletAction()
				} label: {
					Text("fasfsa_mnNefwnew_home_name_perospn".appLocalizable)
						.solidBackgroundWithCorner(color: .appTheme, idealWidth: proxy.size.width)
				}
				Spacer()
				VStack(spacing: 13.0) {
					NavigationLink(value: AppPage.importUserFromMemo) {
						Text("nfasfafew_hofasfasfme_nafame_perospn".appLocalizable)
							.underline(true, color: .label)
					}
					NavigationLink(value: AppPage.importUserFromiCloud(.wallet)) {
						Text("ilcoudd_Sfdnew_home_name_perospn".appLocalizable)
							.underline(true, color: .label)
					}
					if WalletManager.shared.currentWallet != nil {
						Button {
							alert = true
						} label: {
							Text("asf_kklfafasfanew_home_name_perospn".appLocalizable)
								.underline(true, color: .label)
						}
					}
				}
				.font(.rounded(size: 16.0))
				.foregroundColor(.label)
			}
			.padding()
			.navigationTitle("fasfsa_mnNefwnew_home_name_perospn".appLocalizable)
			.navigationBarTitleDisplayMode(.inline)
//			.embedInNavigation(/*pathManager*/)
			.alert("fsffsafsafi_areireosure".appLocalizable, isPresented: $alert, actions: {
				Button("sdfas_ssfsnew_home_name_perospn".appLocalizable, role: .destructive, action: {
					alert = false
					WalletManager.logOutWallet()
                    NavigationStackPathManager.dismissSheetVC()
				})
			}, message: {
				Text("fasfasfsn_sdsfsa_sew_home_name_perospn".appLocalizable)
			})
		}

	}
	
	// MARK: 创建钱包
	private func handleCreateWalletAction() {
		guard inputFilled() else {
			return
		}
		pathManager.path.append(.protect(successHandler: { passWord in
			AppHUD.show("crratnewusernew_home_name_perospn".appLocalizable,loading: true)
			DispatchQueue.global().async {
				WalletManager.shared.createWalletByMnemonicsPhrase(walletName: self.walletName, password: passWord, autoReceiveInitialToken: true) { wallet, error in
					DispatchQueue.main.async {
						AppHUD.dismissAll()
						guard let wallet = wallet else {
							if let desc = error?.description {
								AppHUD.show(desc)
							}
							return
						}
						debugPrint("创建钱包成功:\nname:\(wallet.name)\naddress:\(wallet.address)")
						self.wallet = wallet
						WalletManager.shared.currentWallet = wallet
						pathManager.path.append(.newUserMemo(wallet: wallet, name: walletName, password: passWord))
					}
				}
			}
		}))
	}
	
}

struct CreateNewUser_Previews: PreviewProvider {
	static var previews: some View {
		CreateNewUser()
			.previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
	}
}
