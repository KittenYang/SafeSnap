//
//  AllKeychainPairsView.swift
//  family-dao
//
//  Created by KittenYang on 6/27/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import Defaults

/*
 从 iCloud 恢复
 */
struct ImportUserFromiCloud: View {
	
	@EnvironmentObject var pathManager: NavigationStackPathManager
	
	enum ImportFor: Int {
		case family
		case wallet
		
		var name: String {
			switch self {
			case .family:
				return "fasfnew_hofasfafme_name_perospn_groupgourp".appLocalizable
			case .wallet:
				return "fasfnew_hofasfafme_name_perospn_groupgourp_lflasoe".appLocalizable
			}
		}
		
		var items:[[String: Any]] {
			switch self {
			case .family:
//				return [[
//					"111aaaaaaaaaaaasdasdasdsadasd":"223e2312",
//					"222":"223e2312",
//					"444":"223e2312",
//					"11133":"223e2312",
//					"111wq":"223e2312",
//					"111czx":"223e2312",
//					"11czxc1":"223e2312",
//					"1zxz11":"223e2312",
//					"11cz1":"223e2312"
//				]]
				return KeychainManager.appKeychain_family.allItems()
			case .wallet:
				return KeychainManager.appKeychain_wallet.allItems()
			}
		}
	}
	
	let importFor: ImportFor
	
	/*
	 [
	 "family_1":"park chapter heart soda sunset hungry mention pioneer blind live fortune zebra",
	 "family_2":"genre blur pass visit raise regret reveal priority address humor luggage north"
	 ]
	 */
	func allPairs() -> [String:String] {
		var dic = [String:String]()
		for item in importFor.items {
//			return item as! [String:String]
			if let key = item["key"] as? String, let value = item["value"] as? String {
				dic[key] = value
			}
		}
		return dic
	}
	
	var callback:(([String:String])->Void)?
	
	init(for:ImportFor, callback:(([String:String])->Void)? = nil) {
		self.callback = callback
		self.importFor = `for`
	}
	
	private var adaptiveLayout = [GridItem(.adaptive(minimum: 80))]
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: adaptiveLayout, spacing: 10.0) {
				ForEach(allPairs().sorted(by: >), id: \.key) { key, value in
					if let callback {
						Button {
							pathManager.path.removeLast()
							callback([key:value])
						} label: {
							keyView(key: key)
						}
					} else {
						NavigationLink(value: AppPage.protect(successHandler: { pass in
							handleKeychainAction(name: key, value: value, pass: pass)
						})) {
							keyView(key: key)
						}
					}
				}
			}
		}
		.navigationTitle(importFor == .family ? "iCloud - Group" : "iCloud - User")
	}
	
	@ViewBuilder
	private func keyView(key: String) -> some View {
		Text(getReadableKey(key))
            .font(.rounded(size: 16.0))
            .bold()
			.foregroundColor(.white)
			.frame(width: 60.0,height:80.0)
			.addBKG(color:.appTheme)
	}
	
	private func getReadableKey(_ input: String) -> String {
		if let pair = KeychainManager.getFamilyNameAndChain(by: input), importFor == .family {
			return "\(pair.name)(\(pair.chain.web3Networks.name))"
		} else {
			return input
		}
	}
	
	//MARK: 生成钱包
	private func handleKeychainAction(name:String, value: String, pass: String) {
		switch self.importFor {
		case .wallet:
			AppHUD.show("fasfnew_hofasfafme_name_perospn_fsafsaf".appLocalizable,loading: true)
			DispatchQueue.global().async {
				var _wallet = try? WalletManager.shared.importWalletWithMnemonicsPhrase(value, name: name, password: pass)
				if _wallet == nil {
					_wallet = try? WalletManager.shared.importWalletWithPrivateKey(value, name: name, password: pass)
				}
				if let wallet = _wallet {
					debugPrint("从 iCloud 助记词恢复的钱包:\(wallet)")
					//				let _ = wallet.privateKey // lazy set private key
					DispatchQueue.main.async {
						AppHUD.dismissAll()
						WalletManager.shared.currentWallet = wallet
                        NavigationStackPathManager.dismissSheetVC()
					}
				}
			}
		case .family:
			// TODO: 新建导入家庭
//			(name,chain)
			let pair = KeychainManager.getFamilyNameAndChain(by: value)
		}
	}
	
}

struct ImportUserFromiCloud_Previews: PreviewProvider {
    static var previews: some View {
		XcodePreviewsDevice.previews([.iPhoneSE, .iPhone14ProMax, .iPadAir]) {
			ImportUserFromiCloud(for: .family)
		}
    }
}
