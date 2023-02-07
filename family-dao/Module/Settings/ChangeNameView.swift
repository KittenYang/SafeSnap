//
//  ChangeNameView.swift
//  family-dao
//
//  Created by KittenYang on 12/25/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

struct ChangeNameView: View,InputCheckable {

    func inputs() -> [[String]] {
        return [
            [self.walletName, "pls_input_name".appLocalizable]
        ]
    }
    
    @EnvironmentObject var pathManager: NavigationStackPathManager
	
	@State var from: ImportUserFromiCloud.ImportFor
	
		@State var walletName: String = ""
		
		var body: some View {
			GeometryReader { proxy in
				VStack(spacing: 40.0) {
					VStack(alignment: .leading) {
                        RoundedText("\("change_prefix".appLocalizable)\(from.name)")
							.font(.rounded(size: 16.0))
							.foregroundColor(Color.appGray9E)
						TextField("\("input_new_p".appLocalizable)\(from.name)", text: $walletName)
                            .font(.rounded(size: 16.0))
							.padding()
							.background(Color.secondarySystemBackground)
							.cornerRadius(12.0)
					}
					Button {
						handleCreateWalletAction()
					} label: {
                        RoundedText("change_prefix".appLocalizable)
							.solidBackgroundWithCorner(color: .appTheme, idealWidth: proxy.size.width)
					}
					
					if from == .wallet {
						Spacer()
						VStack(spacing: 13.0) {
							NavigationLink(value: AppPage.createNewUser) {
								Text("create_new_u".appLocalizable)
									.underline(true, color: .label)
							}
						}
						.font(.rounded(size: 16.0))
						.foregroundColor(.label)
					}
				}
				.padding()
				.navigationTitle("\("change_prefix".appLocalizable)\(from.name)")
				.navigationBarTitleDisplayMode(.inline)
			}

		}
		
		// MARK: 创建钱包
		private func handleCreateWalletAction() {
			guard inputFilled() else {
				return
			}
			switch self.from {
			case .family:
				Task {
					try? await Family.getSelected()?.update(name: self.walletName)
				}
			case .wallet:
				let _ = KeychainManager.changeWalletName(newName: self.walletName)
			}

			NavigationStackPathManager.dismissSheetVC()
		}
		
	}

struct ChangeNameView_Previews: PreviewProvider {
    static var previews: some View {
		ChangeNameView(from: .wallet)
    }
}
