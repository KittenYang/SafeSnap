//
//  EditAllFamilyView.swift
//  family-dao
//
//  Created by KittenYang on 1/8/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import LonginusSwiftUI

struct EditAllFamilyView: View {
	
	@Environment(\.currentFamily) var currentFamily: Family?
//		.environment(\.currentFamily, currentFamily.first)
	
//	@State var reload: Bool = false
	
    var body: some View {
		List {
			Section {
				ForEach(Family.all, id:\.self) { family in
					Button {
						switchFamily(toFamily: family)
					} label: {
						HStack(alignment: .center) {
							if let familyVM = family.toViewModel {
								WalletInfoView(walletName: .constant(familyVM.name), wallet: .constant(familyVM.multiSigAddress), configuration: .constant(.largeWithAddress(familyVM.address)), tapGestureEnable: false)
								if familyVM.address == currentFamily?.address {
									Spacer()
									Image(systemName: "checkmark.circle.fill")
										.transition(.opacity)
										.animation(.linear, value: familyVM.address == currentFamily?.address)
								}
							}
						}
					}
//					.buttonStyle(.plain)
				}
//				.id(reload)
			}
		}
//		.onReceive(pub, perform: { output in
//			reload.toggle()
//		})
		.listStyle(.insetGrouped)
		.navigationTitle("nsdssefaxt_sas".appLocalizable)
		.navigationBarTitleDisplayMode(.inline)
    }
	
	private func switchFamily(toFamily: Family) {
		if toFamily.address != currentFamily?.address {
			Task {
				await Family.select(address: toFamily.address, chainId: toFamily.chainID)
				NavigationStackPathManager.dismissSheetVC()
			}			
		}
	}
	
}

struct EditAllFamilyView_Previews: PreviewProvider {
    static var previews: some View {
        EditAllFamilyView()
    }
}
