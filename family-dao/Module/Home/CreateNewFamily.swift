//
//  CreateNewFamily.swift
//  family-dao
//
//  Created by KittenYang on 9/23/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import GnosisSafeKit
import MultiSigKit
import NetworkKit
import web3swift
import Defaults
import BigInt

struct CreateNewFamily: View, InputCheckable {
	
	@EnvironmentObject var pathManager: NavigationStackPathManager
	
	@State var isCreateFamily: Bool = false
	
	func inputs() -> [[String]] {
		[
			[self.familyName, "new_home_name".appLocalizable],
			[self.tokenName, "new_hofasme_namasdase".appLocalizable],
			[self.tokenSymbol, "newsss_homess_name".appLocalizable]
		] + store.options.compactMap({ [$0, "ffnew_homdfsfafe_namesasfsf".appLocalizable] })
	}
	
	@State private var familyName: String = ""
	@State private var tokenName: String = ""
	@State private var tokenSymbol: String = ""
	@State private var tokenSupply: String = ""

	@State var selectedChain:Chain.ChainID = .ethereumMainnet
	
	@ObservedObject var store: ValueStore = {
		var options: [String] = []
		if let user = WalletManager.shared.currentWallet?.address {
			options.append(user)
		}
		return .init(placeHolderTxt: "two_mem".appLocalizable, confirmActionTxt: "mem_add".appLocalizable, grayBackgound: false, icon: .init(systemName: "person.fill"), options: options)
	}()

    
	var body: some View {
		GeometryReader { proxy in
			List {
				Section(header: RoundedText("new_home_namesssssss".appLocalizable)) {
					TextField("new_home_name".appLocalizable, text: $familyName)
				}
				Section(header: RoundedText("nsssew_sshossme_nasssme".appLocalizable)) {
					TextField("new_home_name_suchas".appLocalizable, text: $tokenName)
				}
				Section(header: RoundedText("new_hfsamefas_nameasafsf".appLocalizable)) {
					TextField("sssnewss_hssome_nasssme".appLocalizable, text: $tokenSymbol)
				}
				Section(header: RoundedText("nessw_hssssome_namsssss".appLocalizable)) {
					TextField("nessw_hssomssess_name".appLocalizable, text: $tokenSupply)
						.keyboardType(.numberPad)
				}
				Section(header: RoundedText("two_mem".appLocalizable), footer: RoundedText("new_home_name_laterss".appLocalizable)) {
					AddingRowView(store: store)
				}
//				.onAppear {
//					if let currentUser = WalletManager.shared.currentWallet?.address,
//					   !store.options.contains(currentUser) {
//						store.handleAddNewOption(currentUser)
//					}
//				}
				PlusAndMinusStepView(options: $store.options, maxOptions: $store.maxOptions)
				Section(header: RoundedText("new_home_name_chooss".appLocalizable)) {
					ChainPicker(selectedItem: $selectedChain)
				}
				createNewFamilyButton()
				HStack {
					Spacer()
					Button {
						pathManager.path.append(.importFamily)
					} label: {
						Text("new_home_namasfsfsafe".appLocalizable)
							.font(.rounded(size: 14.0))
							.underline(true, color: Color.label)
					}
					.buttonStyle(.plain)
					Spacer()
				}
				.listRowBackground(Color.clear)
			}
			.listStyle(.insetGrouped)
			.navigationTitle("new_home_name_new_casodiaas".appLocalizable)
			.navigationBarTitleDisplayMode(.inline)
			.animation(.linear, value: store.options)
			.task {
				if let currentUser = WalletManager.shared.currentWallet?.address,
				   !store.options.contains(currentUser) {
					store.handleAddNewOption(currentUser)
				}
			}
		}
		.blur(radius: isCreateFamily ? 50.0 : 0.0)
		.animation(.easeInOut(duration: 0.3), value: isCreateFamily)
	}
	
	@ViewBuilder
	private func createNewFamilyButton() -> some View {
		Section(footer: HStack {
			Spacer()
			Text("nfasfsaew_hfasfsaome_namesadsa".appLocalizable)
				.font(.rounded(size: 14.0))
				.foregroundColor(.appGray9E)
			Spacer()
		}) {
			GeometryReader { proxy in
				Button {
					handleCreateFamilyAction()
				} label: {
					Text("sjfanlnewfasfas_hofffme_nassfame".appLocalizable)
                        .font(.rounded(size: 16.0))
						.foregroundColor(.white)
						.frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
				}//.buttonStyle(PlainButtonStyle())
					//.border(.yellow)
			}
		}.listRowBackground(Color.appTheme)
	}
	
}

extension CreateNewFamily {
	
	private func handleCreateFamilyAction() {
		CreateNewFamily.hideKeyboard()
		guard inputFilled() else {
			return
		}
		let owners = store.options.compactMap({ $0.ethereumAddress() }).compactMap({$0}).filter({ $0 != EthereumAddress.ethZero }).unique()
		guard owners.count > 0, owners.count >= store.maxOptions else {
			AppHUD.show("nfasfsaew_homfsaf_namesfs".appLocalizable)
			return
		}
		guard let supply = BigUInt(tokenSupply) else {
			AppHUD.show("newss_hosfme_namsfsfe".appLocalizable)
			return
		}
		Task {
			AppHUD.show("sssnew_homssse_name".appLocalizable, loading: true)
			withAnimation {
				isCreateFamily = true
			}
			let success = await GnosisSafeManagerL2.entryNew(familyName: familyName, chainID: self.selectedChain, token: (name: tokenName, symbol: tokenSymbol, supply:supply), owners: owners, threshold: store.maxOptions)
			withAnimation {
				isCreateFamily = false
			}
			if success {
				NavigationStackPathManager.dismissSheetVC()
			}
		}
	}
	
}

struct PlusAndMinusStepView: View {
	
//	@Binding var store: ValueStore<String>
	
	@Binding var options:[String]
	@Binding var maxOptions: Int
	
	var atLeastMember: Int {
		return ValueStore<String>.atLeastMember(options)
	}
	
	var body: some View {
		Section(header: RoundedText("new_fsasfhome_namsdsafae".appLocalizable),footer: RoundedText("ssssnew_hosssme_namssse".appLocalizable)) {
			HStack {
				Text(getMaxMemberAttriText())
					.tag("\(options.count)\(maxOptions)")
					.transition(.scale)
					.animation(.easeInOut, value: options)
				Spacer()
				HStack {
					Button {
						handlePlusAction()
					} label: {
						Image(systemName: "plus.circle")
							.foregroundColor(.appTheme)
					}
					.disabled(!plusActionEnable())
					.buttonStyle(PlainButtonStyle())
					Button {
						handleMinusAction()
					} label: {
						Image(systemName: "minus.circle")
							.foregroundColor(.appTheme)
					}
					.disabled(!minusActionEnable())
					.buttonStyle(PlainButtonStyle())
				}
			}
		}
	}
	
	private func getMaxMemberAttriText() -> AttributedString {
//		let hello = AttributedString("\(options.count)\("nessssw_home_namssssse".appLocalizable)")
		var world = AttributedString(" \(maxOptions) ")
		world.font = .rounded(size: 18.0).bold()
		world.foregroundColor = .appTheme
		return world + "/ " + AttributedString("\(options.count)")
//        hello + world + AttributedString("new_home_name_perospn".appLocalizable)
	}
	
	private func plusActionEnable() -> Bool {
		return maxOptions < options.count
	}
	private func minusActionEnable() -> Bool {
		return maxOptions > atLeastMember
	}
	
	
	private func handlePlusAction() {
		maxOptions = max(min(options.count, maxOptions+1), atLeastMember)
	}
	private func handleMinusAction() {
		maxOptions = max(min(options.count, maxOptions-1), atLeastMember)
	}
}

struct CreateNewFamily_Previews: PreviewProvider {
	static var previews: some View {
		CreateNewFamily()
	}
}

