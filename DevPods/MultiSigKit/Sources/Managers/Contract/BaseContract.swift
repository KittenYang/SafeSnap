//
//  BaseContract.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/10/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift
import BigInt


public enum MethodType {
	case write
	case read
}

public enum ContractNetworkError:Error {
	case noResponse
}

public protocol ContractMethod {
	var methodName:String { get }
	var priceValue:BigUInt { get }
	var type: MethodType { get }
	var params: [AnyObject] { get }
	var extraData:Data { get }
}

public protocol Contract: BlockChainInteractable {
//	associatedtype T
	
	static func ContractAssress(_ chain: Chain.ChainID) -> EthereumAddress
	static var ContractABI: String { get }
	
	func callContract<T>(sigWallet: inout Wallet, chain: Chain.ChainID, method:ContractMethod, returnType:T.Type) async -> T?
}

public extension Contract {

	@discardableResult
	func callContract<T>(sigWallet: inout Wallet, chain: Chain.ChainID, method:ContractMethod, returnType:T.Type) async -> T? {
		guard let _ = WalletManager.shared.currentWallet else {
			return nil
		}
		var web3 = ChainManager.global.currentWeb3provider(chain)
		if sigWallet == WalletManager.shared.godWallet {
			web3 = ChainManager.global.currentGodWalletWeb3provider(chain)
		}
		web3?.addKeystoreManager( sigWallet.keystoreManager )
		
		let walletAddress = sigWallet.ethereumAddress!
		let contractAddress = Self.ContractAssress(chain)
		let abiVersion = 2
		let contract = web3?.contract(Self.ContractABI, at: contractAddress, abiVersion: abiVersion)!
		
		// value
		let amount = method.priceValue//Web3.Utils.parseToBigUInt("\(method.priceValue)", units: .eth) // Any amount of Ether you need to send
		
		// options
		var options = TransactionOptions.defaultOptions
		options.from = walletAddress
		options.value = amount
		options.type = .eip1559
//		options.gasLimit = .automatic//.manual(330000)
		options.maxFeePerGas = .automatic
		options.maxPriorityFeePerGas = .automatic
		options.callOnBlock = .pending
	
		do {
			return try await withCheckedThrowingContinuation { continuation in
				do {
					if method.type == .read {
						let read = contract?.read(method.methodName, parameters: method.params,extraData: method.extraData,transactionOptions: options)
						let response = try read?.callPromise().wait()
						guard let response,
							  let value = response["0"] as? T else {
							continuation.resume(throwing: ContractNetworkError.noResponse)
							return
						}
						continuation.resume(returning: value)
						print("response:\(response)")
					} else {
						var params = method.params
						if let dic = params.last as? [String:Any] {
							if let gasLimit = dic["gasLimit"] as? BigUInt {
								options.gasLimit = .manual(gasLimit)
							}
							if let maxFeePerGas = dic["maxFeePerGas"] as? BigUInt {
								options.maxFeePerGas = .manual(maxFeePerGas)
							}
							if let maxPriorityFeePerGas = dic["maxPriorityFeePerGas"] as? BigUInt {
								options.maxPriorityFeePerGas = .manual(maxPriorityFeePerGas)
							}
							params.removeLast()
						}
						
						let tx = contract?.write(
							method.methodName,
							parameters: params,
							extraData: method.extraData,
							transactionOptions: options)
						let transactionResult = try tx?.send(password: WalletManager.currentPwd, transactionOptions: options)
						
						debugPrint("上链tx:\(String(describing: transactionResult))")
						
						self.repeatCheckCreateMultiSigStatus(chain: chain, transactionResult: transactionResult) { receipt in
							debugPrint("上链结果receipt:\(String(describing: receipt))")
							if receipt is T {
								continuation.resume(returning: receipt as? T)
							} else {
								continuation.resume(throwing: ContractNetworkError.noResponse)
							}
							return
						}
					}
				} catch let send_err {
					debugPrint("err_tx:\(send_err)")
					continuation.resume(throwing: send_err)
				}
			}
		} catch let nErr as ContractNetworkError {
			switch nErr {
			case .noResponse:
				print("返回值不正确")
			}
			return nil
		} catch {
			print("错误：\(error)")
			return nil
		}
	}
}
