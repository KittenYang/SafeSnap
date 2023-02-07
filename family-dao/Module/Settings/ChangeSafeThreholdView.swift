//
//  ChangeSafeThreholdView.swift
//  family-dao
//
//  Created by KittenYang on 1/2/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

struct ChangeSafeThreholdView: View {
	
	@ObservedObject var store: ValueStore<String> = .init(placeHolderTxt: "two_mem".appLocalizable, confirmActionTxt: "mem_add".appLocalizable, grayBackgound: false, icon: .init(systemName: "person.fill"), options: WalletManager.shared.currentFamily?.owners)
	
    var body: some View {
		List {
			Section(header: RoundedText("two_mem".appLocalizable), footer: RoundedText("two_mem_footer".appLocalizable)) {
				AddingRowView(store: store)
			}
			.onAppear {
				initialMembers()
			}
			PlusAndMinusStepView(options: $store.options, maxOptions: $store.maxOptions)
			submitButton()
		}
		.listStyle(.insetGrouped)
		.navigationTitle("change_mem_threshold".appLocalizable)
		.navigationBarTitleDisplayMode(.inline)
		.transition(.opacity)
		.animation(.linear, value: store.options)
    }
	
	fileprivate func initialMembers() {
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: DispatchWorkItem(block: {
			if let owners = WalletManager.shared.currentFamily?.owners {
				for owner in owners {
					if !store.options.contains(owner) {
						store.handleAddNewOption(owner)
					}
				}
			}
			if let thres = WalletManager.shared.currentFamily?.threshold {
				store.maxOptions = Int(thres)
			}
		}))
	}
	
	@ViewBuilder
	private func submitButton() -> some View {
		Section {
			GeometryReader { proxy in
				Button {
					AppHUD.dismissAll()
					AppHUD.show("changing_txt".appLocalizable,loading: true)
					Task {
						var result: (SafeTxHashInfo?, BlockChainStatus?)?
						guard let familyOwners = WalletManager.shared.currentFamily?.owners else {
							return
						}
						
						if familyOwners.count > store.options.count {
							// 移除用户
							let removeOwners = store.options.difference(from: familyOwners)
							guard let removeOwner = removeOwners.first,
								  let removeOwnerAddr = removeOwner.ethereumAddress(),
								  !removeOwner.isEmpty,
								  removeOwners.count == 1 else {
								AppHUD.dismissAll()
								AppHUD.show("only_one_txt".appLocalizable)
								return
							}
							if let removeIndex = familyOwners.firstIndex(where: { $0 == removeOwner }) {
								let prevOwner = familyOwners.before(removeIndex)
								result = await NetworkAPIInteractor().proposeRemoveOwnerWithThreshold(threshold: store.maxOptions, prevOwner: prevOwner?.ethereumAddress(), oldOwner: removeOwnerAddr)
							} else {
								AppHUD.dismissAll()
								AppHUD.show("mem_remove_err".appLocalizable)
								return
							}
						} else if familyOwners.count < store.options.count {
							// 增加用户
							let addingOwners = store.options.difference(from: familyOwners)
							var dismissed: Bool = false
							if addingOwners.count > 1 {
								AppHUD.dismissAll()
								AppHUD.show("only_add_one".appLocalizable)
								dismissed = true
							}
							if let addingOwner = addingOwners.first,
							   !addingOwner.isEmpty,
							   let ethAddr = addingOwner.ethereumAddress() {
								result = await NetworkAPIInteractor().proposeAddOwnerWithThreshold(threshold: store.maxOptions, owner: ethAddr)
							} else {
								if !dismissed {
									AppHUD.dismissAll()
								}
								AppHUD.show("add_mem_can_not_empty".appLocalizable)
								return
							}
						} else {
							// 改变用户数目
							if let oldThres = WalletManager.shared.currentFamily?.threshold, store.maxOptions != Int(oldThres) {
								result = await NetworkAPIInteractor().proposeChangeThreshold(threshold:store.maxOptions)
							} else {
								AppHUD.dismissAll()
								AppHUD.show("mem_not_change".appLocalizable)
								return
							}
						}
						DispatchQueue.main.async {
							WalletManager.shared.shouldReloadQueue.toggle()
							NavigationStackPathManager.dismissSheetVC()
							AppHUD.dismissAll()
							if let _ = result?.0?.txId {
								AppHUD.show("post_suss".appLocalizable)
							} else if let status = result?.1 {
								AppHUD.show(status.desc)
							}
						}
					}
                } label: {
                    RoundedText("next_s".appLocalizable)
                        .foregroundColor(.white)
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
				}//.buttonStyle(PlainButtonStyle())
				//.border(.yellow)
			}
		}.listRowBackground(Color.appTheme)
	}
	
}

struct ChangeSafeThreholdView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeSafeThreholdView()
    }
}
