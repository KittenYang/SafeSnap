//
//  CreateNewProposalView.swift
//  family-dao
//
//  Created by KittenYang on 11/26/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import SheetKit

struct CreateNewProposalView: View,InputCheckable {
	
	func inputs() -> [[String]] {
		return [
			[self.titleName, "heloasdaoproosnewPorinext_s_recnet".appLocalizable]
		]
	}
	
	@State var titleName: String = ""
	@State var descName: String = ""
	@State var voteSystem: String? = SnapshotManager.VotingSystem.single_choice.name
	
	@Environment(\.sheetKit) var _sheetKit
	
	@ObservedObject var store: ValueStore = .init(placeHolderTxt: "nadewfsafadPogdhdfrinext_s_recnet".appLocalizable, confirmActionTxt: "newPorinext_s_recne_add_oinitem".appLocalizable, grayBackgound: true, icon: nil, options: nil)
	
	var body: some View {
		GeometryReader { proxy in
			ScrollView(showsIndicators: false) {
				VStack(alignment: .center, spacing: 20.0) {
                    RoundedText("nesfswPorfasinefxt_fs_recnasdet".appLocalizable)
						.foregroundColor(.label)
					AppTextField(title: "newPorinext_s_recnet_ttitoot".appLocalizable, placeholder: "newPssssorinfgexaat_s_recnedast".appLocalizable, inputName: $titleName)
					AppTextField(title: "newPorinext_s_recnet_dassf_dasfsasaf".appLocalizable, placeholder: "helresoansnewPorinext_s_recsssnet".appLocalizable, inputName: $descName)
					HStack(alignment: .bottom) {
						TaskSwitchView(initial: $voteSystem, initialAllSelections: SnapshotManager.VotingSystem.allCases.compactMap({ $0.name }), showCreateNewCategory: false)
						Spacer()
					}
					AddingRowView(store: store)
					Button {
						handleNewProposalAction()
					} label: {
						Text("done".appLocalizable)
							.solidBackgroundWithCorner(color: .appTheme, idealWidth: proxy.size.width)
					}
				}
			}
		}
	}
	
	private func handleNewProposalAction() {
		guard inputFilled() else {
			return
		}
		
		guard let ethDomain = WalletManager.shared.currentFamily?.spaceDomain?.wthETHSuffix.lowercased() else {
			AppHUD.show("ndddewPorddfdinext_s_recnetfss".appLocalizable)
			return
		}
		guard let selectedSystem = SnapshotManager.VotingSystem.allCases.first(where: { $0.name == voteSystem }) else {
			return
		}
		let minCount = selectedSystem.minOptions
		guard store.options.count >= minCount else {
			AppHUD.show("\("sadsnefafwPorfasfinext_s_recnet".appLocalizable)\(minCount)")
			return
		}
		AppHUD.show("newPsfasorfasinext_s_recnedssst".appLocalizable,loading:true)
		Task {
			// 坑：这里domain 也必须小写！！！！！ 不然虽然提案成功，但是网页就是不会显示（直接重定向到首页）
			let result = await SnapshotManager.postAnewProposal(domain: ethDomain, system: selectedSystem, title: titleName, body: descName, choices: store.options)
			if result?.isValid ?? false {
				AppHUD.show("nesws_donPorinext_s_recnssset".appLocalizable)
				_sheetKit.dismiss()
			}
		}
	}
	
}

struct AppTextField: View {
	var title: String
	var placeholder: String
	@Binding var inputName: String
	
	var body: some View {
		VStack(alignment: .leading) {
			Text(title)
				.font(.rounded(size: 16.0))
				.foregroundColor(Color.appGray9E)
			TextField(placeholder, text: $inputName)
                .font(.rounded(size: 16.0))
				.padding()
				.background(Color.appGrayF4)
				.cornerRadius(12.0)
		}
	}
}

struct CreateNewProposalView_Previews: PreviewProvider {
    static var previews: some View {
		CreateNewProposalView()
    }
}
