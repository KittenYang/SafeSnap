//
//  ContentView.swift
//  family-dao
//
//  Created by KittenYang on 6/25/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import CoreData
import MultiSigKit

struct TestNewWalletView: View {
	
	@EnvironmentObject var pathManager: NavigationStackPathManager
	@StateObject var currentPathManager = NavigationStackPathManager()
	
	@State var creatingWallet : Bool = false
	@State var monoString: String = ""
	@State var walletName: String = ""
	@State var wallet: Wallet?
	@State var alertInfo: String?
	@State var importFromICloud : Bool? = false
	
	// MARK: 从 iCloud 恢复
	private func handleiCloudRestoreAction() {
		self.importFromICloud = true
	}
	
	// MARK: 创建钱包
	private func handleCreateWalletAction() {
		guard !self.walletName.isEmpty else {
			self.alertInfo = "fasfs_fasfas_sfffffasfnew_hofasfafme_name_perospn".appLocalizable
			return
		}
		self.creatingWallet = true
		
		WalletManager.shared.createWalletByMnemonicsPhrase(walletName: self.walletName) { wallet, error in
			self.creatingWallet = false
			guard let wallet = wallet else {
				self.alertInfo = error?.description
				debugPrint(self.alertInfo ?? "")
				return
			}
			debugPrint("创建钱包成功:\nname:\(wallet.name)\naddress:\(wallet.address)")
			self.wallet = wallet
			self.currentPathManager.path.append(AppPage.newUserMemo(wallet: wallet,name: walletName, password: nil))
//			self.alertInfo = "创建钱包成功"
//			self.finished = true
		}

	}
	
	var body: some View {
		NavigationStack(path: $currentPathManager.path) {
//		NavigationView {
			ScrollView(.vertical, showsIndicators: false) {
				VStack(alignment: .center, spacing: 20.0) {
					Group {
						Text("-------- 👇🏻已有钱包 ----------")
							.padding(.init(top: 30, leading: 0, bottom: 10, trailing: 0))
						HStack(alignment: .center){
							Spacer(minLength: 25)
							TextField("输入助记词", text: $monoString)
								.lineLimit(.max)
								.frame(width: nil, height: 100, alignment: .leading)
								.addBKG(color: .secondarySystemBackground)
							Spacer(minLength: 25)
						}
						//TODO: 增加从助记词恢复的页面
						NavigationLink(value: AppPage.importUserFromMemo) {
							Text("助记词恢复")
						}
						.addBKG(color: .appGrayMiddle)
						NavigationLink(value: AppPage.importUserFromiCloud(.wallet)) {
							Text(" iCloud 恢复")
						}
						.addBKG(color: .appGrayMiddle)
					}
					Text("-------- 👇🏻没有钱包 ----------").padding(20)
					Group {
						HStack(alignment: .center){
							Spacer(minLength: 16)
							Text("用户名")
								.padding()
							TextField("输入用户名", text: $walletName)
								.addBKG(color: .secondarySystemBackground)
							Spacer(minLength: 30)
						}

						Button {
							handleCreateWalletAction()
						} label: {
							Group {
								if creatingWallet {
									ProgressView()
								} else {
									Text("创建新钱包")
								}
							}
							.addBKG(color: .appGrayMiddle)
						}
						
//						NavigationLink(value: AppPage.newUserMemo(wallet: wallet,name: walletName, password: nil)) {
//							Text("创建新钱包")
//						}.addBKG()
						
//						NavigationLink(tag: true, selection: .constant(self.wallet != nil)) {
//							MenoCreateView(wallet: wallet, name: walletName, password: nil)
//								.onDisappear {
//									self.wallet = nil
//							}
//						} label: {
//
//						}
					}
				}.navigationTitle("创建钱包")
			}.onTapGesture {
				UIApplication.shared.endEditing()
			}.navigationDestination(for: AppPage.self) { des in
				des.destinationPage
			}
		}.alert(isPresented: .constant(self.alertInfo != nil), content: {
			Alert( // 1
				title: Text(self.alertInfo ?? "发生错误"),
				message: nil,
				dismissButton: .cancel({
					self.alertInfo = nil
				})
			)
		})
		.environmentObject(pathManager)
		.environmentObject(currentPathManager)
	}
	
	/*
	 知识点：
	 1.每一个 stack 传入的 environmentObject 只会在上这个 stack 上延续，如果 present 了一个新的 stack，还需要继续把上的 stack 的 pathManager 传递到这个 stack 上
	 2. environmentObject 和 environment 的区别
	 */
	
	
}


extension UIApplication {
		func endEditing() {
				sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
		}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		TestNewWalletView()
	}
}
