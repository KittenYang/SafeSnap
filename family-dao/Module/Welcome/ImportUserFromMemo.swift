//
//  ImportUserFromMemo.swift
//  family-dao
//
//  Created by KittenYang on 9/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import SwiftUIX
import web3swift

protocol InputCheckable {
	func inputs() -> [[String]]
	func inputFilled() -> Bool
}

extension InputCheckable {
	func inputFilled() -> Bool {
		for input in inputs() {
			guard let str = input.first, !str.isEmpty else {
				if let sec = input.last {
					Task {
						await AppHUD.show(sec)
					}
				}
				return false
			}
		}
		return true
	}
}

struct ImportUserFromMemo: View, InputCheckable {
	
	func inputs() -> [[String]] {
		return [
			[self.monoString,"fasfasfas_fdsafsafnew_hofasfafme_name_perospn".appLocalizable],
			[self.walletName,"ffa_fasfnew_hofasfafme_name_perosp_fassfsn".appLocalizable]
		]
	}
	
	@State var monoString: String = ""
	@State var walletName: String = ""
	
	@State var saveToICloud: Bool = true
	
	// 实时监听 Binding 属性变化
	var monoStringBinding: Binding<String> {
		Binding(
			get: {
				$monoString.wrappedValue
//				$monoString.transaction(.init(animation: .easeOut)).wrappedValue
			},
			set: { (newValue, tnx) in
				// 调用 `.transaction` 修饰器以利用 `tnx : Transaction` 对象.
				$monoString.transaction(tnx).wrappedValue = newValue
//				observeSelectionChange()
			}
		).animation()
	}
	
	@EnvironmentObject var pathManager: NavigationStackPathManager
	
	var body: some View {
		GeometryReader { proxy in
			VStack(spacing: 40.0) {
				VStack(alignment: .leading) {
					Text("ffaaf_fafasssfasfnew_hofasfafme_name_perospn".appLocalizable)
						.font(.rounded(size: 16.0))
						.foregroundColor(Color.appGray9E)
					TextField("fasfnew_hofasfafme_name_perosp_fasfafan".appLocalizable, text: $walletName)
						.padding()
						.background(Color.secondarySystemBackground)
						.cornerRadius(12.0)
				}
				VStack(alignment: .leading) {
					Text("ffasfaasffsaf_fasfsnew_hofasfafme_name_perospn".appLocalizable)
						.font(.rounded(size: 16.0))
						.foregroundColor(Color.appGray9E)
					TextField("loalolod_loasdfsafasfnew_hofasfafme_name_perospn".appLocalizable, text: monoStringBinding, axis: .vertical)
						.frame(height: 100.0, alignment: .topLeading)
						.padding()
						.background(Color.secondarySystemBackground)
						.cornerRadius(12.0)
				}
				Button {
					saveToICloud.toggle()
				} label: {
					HStack(alignment: .center) {
						Circle()
							.frame(width:13, height: 13)
						Text("fasfnew_hofasfafme_name_perospn_fafaikcoudc".appLocalizable)
							.font(.rounded(size: 14.0))
							.frame(maxWidth: .infinity, alignment: .leading)
					}
					.foregroundColor(saveToICloud ? .appTheme : .appGray9E)
				}
				Button {
					handleCreateWalletAction()
				} label: {
					Text("fasfa_lloofsnossffasfnew_hofasfafme_name_perospn".appLocalizable)
						.solidBackgroundWithCorner(color: .appTheme, idealWidth: proxy.size.width)
				}
				Spacer()
				VStack(spacing: 13.0) {
					Button {
						pathManager.path.append(.createNewUser)
					} label: {
						Text("create_new_u".appLocalizable)
							.underline(true, color: Color.label)
					}
					Button {
						pathManager.path.append(.importUserFromiCloud(.wallet))
					} label: {
						Text("ilcoudd_Sfdnew_home_name_perospn".appLocalizable)
							.underline(true, color: Color.label)
					}
				}
				.font(.rounded(size: 16.0))
				.foregroundColor(Color.label)
			}
			.padding()
			.navigationTitle("fasfnew_hofasfafme_name_perospfaf_fassfn".appLocalizable)
			.navigationBarTitleDisplayMode(.inline)
		}
	}
	
	// MARK: 创建钱包
	private func handleCreateWalletAction() {
		guard inputFilled() else {
			return
		}
		pathManager.path.append(.protect(successHandler: { pass in
			AppHUD.show("hello_da_fasfnew_hofasfafme_name_perospn".appLocalizable, loading:true)
			DispatchQueue.global().async {
				
//				do {
					var _wallet = try? WalletManager.shared.importWalletWithMnemonicsPhrase(self.monoString, name: self.walletName, password: pass)
				if _wallet == nil {
					_wallet = try? WalletManager.shared.importWalletWithPrivateKey(self.monoString, name: self.walletName, password: pass)
				}

					if let wallet = _wallet {
						if self.saveToICloud {
							saveMeno(wallet: wallet)
						}
						DispatchQueue.main.async {
							WalletManager.shared.currentWallet = wallet
							NavigationStackPathManager.dismissSheetVC()
							AppHUD.dismissAll()
						}
					} else {
						AppHUD.show("comiirnit_fasfnew_hofasfafme_name_perospn".appLocalizable)
					}
//				} catch let err {
//					if let keyError = err as? AbstractKeystoreError {
//						ContainerManager.share.show(BlockView(keyError.localizedDescription))
//					}
//				}
			}
		}))
	}
	
	private func saveMeno(wallet: Wallet?) {
		guard !self.walletName.isEmpty else {
			return
		}
	
		let mnemonics = wallet?.mnemonics ?? self.monoString
				
		debugPrint("保存到 Keychain: mnemonics: \(mnemonics)")
		debugPrint("保存到 Keychain: name: \(self.walletName)")

		KeychainManager.saveMnemonics(name: self.walletName, mnemonics: mnemonics)
	}
}

struct ImportUserFromMemo_Previews: PreviewProvider {
    static var previews: some View {
        ImportUserFromMemo()
    }
}
