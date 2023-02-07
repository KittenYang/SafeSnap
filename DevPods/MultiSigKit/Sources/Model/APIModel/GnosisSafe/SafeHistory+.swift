//
//  SafeHistory+.swift
//  MultiSigKit
//
//  Created by KittenYang on 9/9/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import web3swift

public extension SafeTxHashInfo {
	
	var needsYourConfirmation: Bool {
		if txStatus?.isAwatingConfiramtions ?? false,
			 let multisigInfo = detailedExecutionInfo,
			 multisigInfo.needsYourConfirmation {
			return true
		}
		return false
	}
	
	// returns true if the app has means to execute the transaction and the transaction has all required confirmations
	func needsYourExecution() -> Bool {
		if txStatus == .waitingExecution || txStatus == .pendingFailed,
			 let multisigInfo = detailedExecutionInfo,
			 multisigInfo.needsYourExecution() {
			return true
		}
		return false
	}
	
}

public extension SafeTxHashInfo.DetailedExecutionInfo {
	
	fileprivate var needsYourConfirmation: Bool {
		if !signerKeys().isEmpty,
				needsMoreSignatures {
			return true
		}
		return false
	}
	
	private var ecdsaConfirmations: [SafeTxHashInfo.DetailedExecutionInfo.Confirmations] {
		return confirmations?.filter {
			$0.signature?.toHexData().bytes.last ?? 0 > 26
		} ?? []
	}
	
	fileprivate func needsYourExecution() -> Bool {
		if let confirmationsRequired = confirmationsRequired,
			 // unclear why the confirmations only count ecdsa
			 ecdsaConfirmations.count >= confirmationsRequired,
			 !executionKeys().isEmpty {
			return true
		}
		return false
	}
	
	var waitingSignerCounts: Int {
		return (self.confirmationsRequired ?? 0) - (self.confirmations?.count ?? self.confirmationsSubmitted ?? 0)
	}
	
	private var needsMoreSignatures: Bool {
		if let confirmations, let confirmationsRequired {
			return confirmationsRequired > confirmations.count
		}
		return false
	}
	
	func hasRejected(address: EthereumAddress) -> Bool {
		rejectors?.contains(address) ?? false
	}
	
	func isRejected() -> Bool {
		if let rejectors = rejectors, !rejectors.isEmpty {
			return true
		} else {
			return false
		}
	}
	
	func signerKeys() -> [EthereumAddress] {
		// 确认的地址
		let confirmationAdresses = confirmations?.compactMap({ $0.signer }) ?? []
		
		// 签名的地址中找出未确认的地址
		let remainingSigners = signers?.map(\.address)
			.filter({ !confirmationAdresses.contains($0) })/*.map( { $0.ethereumAddress() } )*/
			.filter({ WalletManager.shared.currentWallet?.address == $0 }) // 过滤掉不能签名的地址（只有本地的账号才能签名）
//			.compactMap({ $0.ethereumAddress })
		
		return remainingSigners?.compactMap({ $0.ethereumAddress() }) ?? []

	}
	
	func rejectorKeys() -> [EthereumAddress] {
		// 拒绝的地址
		let rejectorsAdresses = rejectors?.compactMap({ $0.address }) ?? []
		
		// 签名的地址中找出未拒绝的地址
		let remainingSigners = signers?.map(\.address)
			.filter({ !rejectorsAdresses.contains($0) })/*.map( { $0.address } )*/
			.filter({ WalletManager.shared.currentWallet?.address == $0 })
		
		return remainingSigners?.compactMap({ $0.ethereumAddress() }) ?? []
	}
	
	// returns the execution keys valid for executing this transaction
	func executionKeys() -> [EthereumAddress] {
		// we only know now how to exeucte a safe transaction
//		guard tx?.multisigInfo != nil else {
//			return []
//		}
		
		guard let _ = WalletManager.shared.currentFamily else {
			return []
		}
		
//		let chain = family.chain
		
		// all keys that can sign this tx on its chain.
		// currently, only wallet connect keys are chain-specific, so we filter those out.
//		guard let allKeys = try? KeyInfo.all(), !allKeys.isEmpty else {
//			return []
//		}
		guard let currentUser = WalletManager.shared.currentWallet?.ethereumAddress else {
			return []
		}
		
		let allKeys = [currentUser]
		
//		let validKeys = allKeys.filter { keyInfo in
//			// if it's a wallet connect key which chain doesn't match then do not use it
//			if keyInfo.keyType == .walletConnect,
//				 let chainId = keyInfo.walletConnections?.first?.chainId,
//				 // when chainId is 0 then it is 'any' chain
//				 chainId != 0 && String(chainId) != chain.id {
//				return false
//			}
//			// else use the key
//			return true
//		}
//			.filter {
//				// filter out ledger until it is supported
//				$0.keyType != .ledgerNanoX
//			}
		
		return allKeys
	}
	
	var canSign: Bool {
		// 当前登录用户，目前只支持登录一个
		guard let currentUser = WalletManager.shared.currentWallet?.ethereumAddress else {
			return false
		}
		
		if let signers {
			return signers.contains(where: { $0 == currentUser })
		}
		
		if let missingSigners {
			return missingSigners.contains(where: { $0 == currentUser })
		}
		
		return false
	}
	
}

public extension SafeTxHashInfo.TXStatus {
	var isAwatingConfiramtions: Bool {
		[.waitingYourConfirmation, .waitingConfirm].contains(self)
	}
}


public extension SafeHistory.SafeHistoryResult.SafeHistoryResultTxn {
	var isReject: Bool {
		return txInfo?.isRejectionAction ?? false
	}
	
	var uiPattern: (icon:UIImage?,color:Color?) {
		if isReject {
			return (UIImage(systemName: "hand.raised.slash.fill"),.appRed)
		} else {
			switch txInfo?.type {
			case .tranfer:
				return (txInfo?.direction?.icon,.orange)
			case .settingsChange:
				return (UIImage(systemName: "gearshape.fill"),.appPurple)
			case .custom:
				return (UIImage(systemName: "hand.wave.fill"),.appBlue)
			case .creation:
				return (UIImage(systemName: "wallet.pass.fill"),.appGradientRed1)
			default:
				return (nil,nil)
			}
		}
	}
}
