//
//  ImportFamilyView.swift
//  family-dao
//
//  Created by KittenYang on 8/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import web3swift
import Defaults

/*
 导入家庭
 */
struct ImportFamilyView: View {
	
	@State private var addressString: String = ""
	@State private var nameString: String = ""
	
	@EnvironmentObject var pathManager: NavigationStackPathManager
	
	var inputAddress: EthereumAddress? {
		return EthereumAddress(addressString.add0xPrefix())
	}
	
	init() {
		UITableView.appearance().sectionFooterHeight = 0
	}

	@State var selectedChain:Chain.ChainID = .ethereumMainnet
    
	var body: some View {
		List {
			Section(header: RoundedText("zhanshsyoufasfnew_hofasfafme_name_perospn".appLocalizable)) {
				HStack {
					Image(systemName: "person.fill")
					TextField("0x.....", text: $addressString)
				}
			}
			Section(header: RoundedText("nmae_sdaffasfnew_hofasfafme_name_perospn".appLocalizable),
					footer: RoundedText("hekosocd_kfasfasfnew_hofasfafme_name_perospn".appLocalizable)) {
				TextField("dfafas_hello_fasfnew_hofasfafme_name_perospn".appLocalizable, text: $nameString)
			}
			Section(header: RoundedText("new_home_name_chooss".appLocalizable)) {
				ChainPicker(selectedItem: $selectedChain)
			}
			Section(header: Spacer(minLength: 30.0)) {
				Button {
					handleImportFamily()
				} label: {
					HStack {
						Spacer()
                        RoundedText("clalos_fasfnew_hofasfafme_name_perospn".appLocalizable, font: 16.0)
							.foregroundColor(.white)
						Spacer()
					}
				}
			}.listRowBackground(Color.appTheme)
			Section(header: EmptyView()) {
				Button {
					pathManager.path.append(.importUserFromiCloud(.family, { store in
						for (key, value) in store {
							addressString = value
							let pair = KeychainManager.getFamilyNameAndChain(by: key)
							nameString = pair?.name ?? key
							if let chain = pair?.chain {
								selectedChain = chain
							}
						}
						handleImportFamily()
					}))
				} label: {
					HStack {
						Spacer()
                        RoundedText("ilcoudd_Sfdnew_home_name_perospn".appLocalizable, font: 16.0)
							.foregroundColor(.white)
						Spacer()
					}
				}
			}
			.listRowBackground(Color.appBlue)
		}
		.listStyle(.insetGrouped)
		.navigationTitle("fasfssneaw_hofdsdasfafme_name_perospn".appLocalizable)
		.navigationBarTitleDisplayMode(.inline)
		.onAppear {
			UITableView.appearance().sectionFooterHeight = 0
		}
	}
	
	private func handleImportFamily()  {
		Task {
			guard let familyAddress = inputAddress else {
				AppHUD.show("illededefasfnew_hofasfafme_name_perospn".appLocalizable)
				return
			}
			guard (nameString.count != 0) else {
				AppHUD.show("dfaslleoel_fasfnew_hofasfafme_name_perospn_fsa".appLocalizable)
				return
			}
			
			AppHUD.show("fasfnew_hofasfafme_name_perospn_cmeomdd".appLocalizable, loading: true)
			
			await WalletManager.shared.interactor.createFamilyIfNeeded(chain: self.selectedChain, familyName: nameString, familyAddress: familyAddress, forceCreate: false)
			
			NavigationStackPathManager.dismissSheetVC()
			
			AppHUD.dismissAll()
		}
		
	}
	
}


struct ImportFamilyView_Previews: PreviewProvider {
	static var previews: some View {
		ImportFamilyView()
	}
}

