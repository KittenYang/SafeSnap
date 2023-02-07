//
//  ChangeNickNameView.swift
//  family-dao
//
//  Created by KittenYang on 1/7/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

struct ChangeNickNameView: View {
	
	@State var membersNick = [String:String]()
	
	@FocusState private var focusedField: Int?
	
    var body: some View {
		List {
			ForEach(Array(zip((WalletManager.shared.currentFamily?.owners ?? []).indices, (WalletManager.shared.currentFamily?.owners ?? []))), id: \.0) { index, member in
				Section {
                    RoundedText(member)
					TextField("piajnsne".appLocalizable,text: .init(get: {
						return membersNick[member]
					}, set: { newValue in
						membersNick[member] = newValue
					})/*.animation()*/)
					.lineLimit(2)
					.focused($focusedField, equals: index)
				}
			}
			submitButton()
		}
		.onAppear {
			membersNick = WalletManager.shared.currentWalletOwnersNickname
		}
		.listStyle(.insetGrouped)
		.navigationTitle("azadasdsadsa".appLocalizable)
		.navigationBarTitleDisplayMode(.inline)
		.transition(.opacity)
    }
	
	@ViewBuilder
	private func submitButton() -> some View {
		Section {
			GeometryReader { proxy in
				Button {
					WalletManager.shared.updateNickName(membersNick)
					NavigationStackPathManager.dismissSheetVC()
					Task {
						await AppHUD.show("nextasdasd_s".appLocalizable)
					}
				} label: {
                    RoundedText("asdnexfast_s".appLocalizable)
						.foregroundColor(.white)
						.frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
				}
			}
		}.listRowBackground(Color.appTheme)
	}
}

struct ChangeNickNameView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeNickNameView()
    }
}
