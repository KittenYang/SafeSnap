//
//  Home.swift
//  family-dao
//
//  Created by 传骑 on 7/8/22
//  Copyright (c) 2022 Rajax Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import Dispatch
import web3swift
import MultiSigKit
import GnosisSafeKit

struct HomeView: View {
	
	@State var reload: Bool = false // 只是为了重新渲染整个body
	@State var isCreatingMultiSig: Bool = false // 正在创建新的多签钱包
	@EnvironmentObject var walletManager: WalletManager
	
	private func createNewMultiSig() {
		self.isCreatingMultiSig = true
		//TODO: 手动设置 name 和 symbol 和钱包名字
		let tokenName = "Family-DAO-1"
		let tokenSymbol = "FAMD1"
//		GnosisSafeManagerL2.shared.createNewMultiSig(token: (name: tokenName, symbol: tokenSymbol), owners: []) { result, error in
//			debugPrint("成功提交，等待链上确认transaction:\(String(describing: result))")
//		} checkMultiSigStatusCompletion: { multiSig, token in
//			DispatchQueue.main.async {
//				self.isCreatingMultiSig = false
////				WalletManager.shared.multiSigAddress = multiSig
//				WalletManager.shared.currentFamily = Family(name: "姣姣和滔滔", token: FamilyToken(name: tokenName, symbol: tokenSymbol, decimals: 18, tokenAddress: token?.address), multiSigAddress: multiSig)
////				WalletManager.shared.tokenAddress = token
//				debugPrint("成功部署钱包地址: \(String(describing: multiSig))")
//				debugPrint("成功创建新货币: \(String(describing: token))")
//				ERC20TokenManager.shared.sendAllFamilyTokenToMultiSig()
//			}
//		}
	}
	
	let interactor: NetworkAPIInteractor = NetworkAPIInteractor()
	
	private func getSafeInfo() {
		self.interactor.getSafeInfo { safeInfo, error in
			debugPrint("⚠️收到 getSafeInfo 回调")
			debugPrint("safeInfo:\(String(describing: safeInfo))")
		}
	}
	
	private func getSafeBalance() {
		self.interactor.getSafeBalance(completionHandler: { balance, error in
			debugPrint("⚠️收到 getSafeBalance 回调")
			debugPrint("balance:\(String(describing: balance))")
		})
	}
	
	private func getSafeTxHashInfo(safeTxHash: String) {
		self.interactor.getSafeTxHashInfo(safeTxHash: safeTxHash) { txHashInfo, error in
			debugPrint("⚠️收到 getSafeTxHashInfo 回调")
			debugPrint("txHashInfo:\(String(describing: txHashInfo))")
		}
	}
	
	private func getSafeHistory() {
		self.interactor.getSafeHistory { history, error in
			debugPrint("⚠️收到 getSafeHistory 回调")
			debugPrint("history:\(String(describing: history))")
		}
	}
	
	private func getSafeQueued() {
		self.interactor.getSafeQueues { queued, error in
			debugPrint("⚠️收到 getSafeQueued 回调")
			debugPrint("queued:\(String(describing: queued))")
		}
	}
	
	// 发起一笔多签交易
	// TODO: 修改发送金额
	private func createTransction() {
		let value = Web3.Utils.parseToBigUInt("11", decimals: Constant.defaultTokenDecimals)!
		self.interactor.proposeAction(value: value) { proposeResult, error, status in
			debugPrint("⚠️收到 proposeAction 回调")
			// callback 返回主线程
			if let error = error {
				debugPrint("propose error:\n\(String(describing: error.localizedDescription))")
			}
			debugPrint("proposeResult:\n\(String(describing: proposeResult))")
		}
	}
	
	// 发起一笔拒绝交易
	// TODO: 拒绝某个nonce
	private func createRejectTransction(nonce: Int) {
		self.interactor.proposeRejectAction(nonce: UInt256(nonce)) { info, error, status in
			debugPrint("⚠️收到 proposeRejectAction 回调")
			// callback 返回主线程
			if let error = error {
				debugPrint("propose error:\n\(String(describing: error.localizedDescription))")
			}
			debugPrint("proposeResult:\n\(String(describing: info))")
		}
	}

//	@Default(.currentWallet) var currentWallet
	
	var body: some View {
		ScrollView {
			VStack() {
				Text("\(self.reload ? "" : "")")
				Text("当前钱包地址：")
					.font(.title2)
					.padding()
				Text(self.walletManager.currentWallet?.address ?? "未找到当前钱包地址")
					.padding()
				Button {
					createNewMultiSig()
				} label: {
					if self.isCreatingMultiSig {
						ProgressView()
							.padding()
					} else {
						Text("与本地合约交互")
							.foregroundColor(.white)
							.padding()
					}
				}
				.background(Color.gray)
				.cornerRadius(6.0)
				if let multiSigAddress = self.walletManager.currentFamily?.multiSigAddress, !self.isCreatingMultiSig {
					Text("目标多签钱包地址：")
						.font(.title2)
						.padding()
					Text(multiSigAddress.address)
						.padding()
					Text("DAO-Token：")
						.font(.title2)
						.padding()
					Text(self.walletManager.currentFamily?.token?.tokenAddress?.address ?? "")
						.padding()
					Button {
						getSafeInfo()
					} label: {
						Text("获取钱包信息")
							.foregroundColor(.white)
							.padding()
					}
					.background(Color.blue)
					.cornerRadius(6.0)
					Button {
						getSafeBalance()
					} label: {
						Text("获取钱包余额")
							.foregroundColor(.white)
							.padding()
					}
					.background(Color.blue)
					.cornerRadius(6.0)
					Button {
						getSafeTxHashInfo(safeTxHash: "0xb5e9fe43295172e242a8d9b1ef313be8bbefda6a2aa62dc43bc2c9a5178c7d11")
					} label: {
						Text("获取一个交易信息")
							.foregroundColor(.white)
							.padding()
					}
					.background(Color.blue)
					.cornerRadius(6.0)
					Button {
						getSafeHistory()
					} label: {
						Text("交易历史")
							.foregroundColor(.white)
							.padding()
					}
					.background(Color.blue)
					.cornerRadius(6.0)
//					Button {
//						getSafeQueued()
//					} label: {
//						Text("等待交易的队列")
//							.foregroundColor(.white)
//							.padding()
//					}
//					.background(Color.blue)
//					.cornerRadius(6.0)
					Button {
						createTransction()
					} label: {
						Text("发起一笔交易")
							.foregroundColor(.white)
							.padding()
					}
					.background(Color.blue)
					.cornerRadius(6.0)
					Button {
						createRejectTransction(nonce: 5)
					} label: {
						Text("发起一笔拒绝交易")
							.foregroundColor(.white)
							.padding()
					}
					.background(Color.blue)
					.cornerRadius(6.0)
				}
			}
		}
		.sheet(isPresented: .constant(self.walletManager.currentWallet == nil)) {
			TestNewWalletView()
				.onDisappear {
					self.reload.toggle()
				}
		}
		.onAppear {
			debugPrint("当前钱包地址：\(self.walletManager.currentWallet?.address ?? "未找到当前钱包地址")")
			debugPrint("目标多签钱包地址：\(String(describing: self.walletManager.currentFamily?.multiSigAddress))")
			debugPrint("DAO-Token：\(self.walletManager.currentFamily?.token.tokenAddress.address ?? "")")
			self.reload.toggle()
		}
	}
	
}

struct Home_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
			.environmentObject(WalletManager.shared)
	}
}

