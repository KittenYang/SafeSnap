//
//  ERC20TokenManager.swift
//  family-dao
//
//  Created by KittenYang on 7/31/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift
import BigInt
import Defaults
import SwiftUI
import NetworkKit

//public struct ChainLoadingStatusKey: EnvironmentKey {
//	public static var defaultValue: Binding<ChainLoadingStatus> {
//		return .constant(.end)
//	}
//}
//
//public extension EnvironmentValues {
//	var chainLoadingStatus: Binding<ChainLoadingStatus> {
//		get { self[ChainLoadingStatusKey.self] }
//		set { self[ChainLoadingStatusKey.self] = newValue }
//	}
//}

public enum ChainLoadingStatus: Hashable {
	
	case creating(String)
	case pending
	case error(String)
	case end
	
	public static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.creating(let str1),.creating(let str2)):
			return str1 == str2
		case (.pending, .pending):
			return true
		case (.error(let str1),.error(let str2)):
			return str1 == str2
		case (.end, .end):
			return true
		default:
			return false
		}
	}
	
	public var statusDesc: String {
		switch self {
		case .creating(let string):
			return string
		case .pending:
			return "new_home_name_perospn_lininkindds".appLocalizable
		case .error(let string):
			return string
		case .end:
			return "process_end_txt".appLocalizable
		}
	}
}

public class ERC20TokenManager: BlockChainInteractable {
	
	public static let shared = ERC20TokenManager()
	private init() {}
	
	// MARK: 创建新 token
	public func createToken(chain:Chain.ChainID,
							name:String,
							symbol:String,
							decimals:Int=Constant.defaultTokenDecimals,
							initialTotalSupply:BigUInt,
							statusHandler:((ChainLoadingStatus)->Void)?,
							finalCompletion:RepeatCheckTXCompletion? = nil) {
		debugPrint("开始创建Token")
		
		DispatchQueue.global().async {
			guard let godWallet = WalletManager.shared.godWallet else {
				finalCompletion?(nil)
				return
			}
			statusHandler?(.creating("newitooencrratenew_home_name_perospn".appLocalizable))
			let web3 = ChainManager.global.currentGodWalletWeb3provider(chain)
		
			// value
			let amount = Web3.Utils.parseToBigUInt("0.0", units: .eth) // Any amount of Ether you need to send
			
			// contract
			let contractABI = """
			[{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"tokenAddress","type":"address"}],"name":"ERC20TokenCreated","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"tokenAddress","type":"address"}],"name":"ERC721TokenCreated","type":"event"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"string","name":"symbol","type":"string"},{"internalType":"uint8","name":"decimals","type":"uint8"},{"internalType":"uint256","name":"initialSupply","type":"uint256"}],"name":"deployNewERC20Token","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"nonpayable","type":"function"}]
			"""
			let walletAddress = godWallet.ethereumAddress!
			let contractMethod = "deployNewERC20Token" // Contract method you want to write
			let contractAddress = EthereumAddress(Constant.TokenFactoryAddress)!
			let abiVersion = 2 // Contract ABI version
			//			BigInt(decimals);
			let params: [AnyObject] = [name,symbol,decimals,initialTotalSupply] as [AnyObject] // Parameters for contract method
			let extraData: Data = Data() // Extra data for contract method
			let contract = web3?.contract(contractABI, at: contractAddress, abiVersion: abiVersion)!
			
			// options
			var options = TransactionOptions.defaultOptions
			options.from = walletAddress
			options.value = amount
			options.type = .eip1559
			options.maxFeePerGas = .automatic
			options.maxPriorityFeePerGas = .automatic
			options.callOnBlock = .pending

			// send
			let tx = contract?.write(
				contractMethod,
				parameters: params,
				extraData: extraData,
				transactionOptions: options)

			// result
			do {
				let transactionResult = try tx?.send(password: WalletManager.currentPwd, transactionOptions: options)
				debugPrint("初始基金 tx: \(String(describing: transactionResult))")
				
				statusHandler?(.pending)
				
				debugPrint("✅开始轮询 token 创建结果")
				self.repeatCheckCreateMultiSigStatus(chain: chain, transactionResult: transactionResult, completion: finalCompletion)
			} catch let send_err {
				statusHandler?(.error(send_err.localizedDescription))
				finalCompletion?(nil)
				debugPrint("err_tx:\(send_err)")
			}
		}
		
	}
	
	// MARK: 所有初始货币转移到多签钱包
	public func sendAllFamilyTokenToMultiSig(newWallet:EthereumAddress?,
											 chain: Chain.ChainID?,
											 tokenAddr:EthereumAddress?,
											 amount: BigUInt,
											 statusHandler:((ChainLoadingStatus)->Void)?) async -> TransactionReceipt.TXStatus? {
		guard let godWallet = WalletManager.shared.godWallet else {
			statusHandler?(.error("No wallet login"))
			return .failed
		}
		
		guard let toAddress = newWallet ?? WalletManager.shared.currentFamily?.multiSigAddress else {
			statusHandler?(.error("No DAO address"))
			return .failed
		}
		
		guard let chain = chain ?? WalletManager.shared.currentFamily?.chain else {
			statusHandler?(.error("No chain id"))
			return .failed
		}
		
		guard let erc20ContractAddress = tokenAddr ?? WalletManager.shared.currentFamily?.token?.tokenAddress else {
			statusHandler?(.error("No token addres"))
			return .failed
		}
		
		debugPrint("开始转移 token 到多签钱包")
		
		statusHandler?(.creating("initaoltnetransonew_home_name_perospn".appLocalizable))
		
		return await withCheckedContinuation { conti in
			let web3 = ChainManager.global.currentGodWalletWeb3provider(chain)
			
			var options = TransactionOptions.defaultOptions
			//			options.value = amount
			////			options.from = walletAddress
			//			options.to = toAddress
			//			options.gasLimit = .manual(BigUInt(21000))
			//			options.gasPrice = .manual(BigUInt(1500000000))
			
			options.type = .eip1559
			options.maxFeePerGas = .automatic//.manual(Web3.Utils.parseToBigUInt("1.5", units: Web3.Utils.Units.Gwei)!)
			options.maxPriorityFeePerGas = .automatic//.manual(Web3.Utils.parseToBigUInt("1.5", units: Web3.Utils.Units.Gwei)!)
			
			let tx = web3?.eth.sendERC20tokensWithKnownDecimals(tokenAddress: erc20ContractAddress,
																from: godWallet.ethereumAddress!,
																to: toAddress,
																amount: amount,
																transactionOptions: options)
			do {
				let transactionResult = try tx?.send(password: WalletManager.currentPwd)
				debugPrint("初始基金to家庭 tx:\(String(describing: transactionResult))")
				statusHandler?(.pending)
				self.repeatCheckCreateMultiSigStatus(chain:chain,transactionResult: transactionResult) { hashReceipt in
					let ok = hashReceipt?.status == .ok
					statusHandler?(ok ? .end : .error("new_home_name_ssperofasfspnfas".appLocalizable))
					debugPrint(ok ? "转移成功" : "转移失败")
					conti.resume(returning: hashReceipt?.status)
				}
			} catch let send_err {
				debugPrint("❌转移 token 到多签钱包:err_tx:\(send_err)")
				statusHandler?(.error(send_err.localizedDescription))
				conti.resume(returning: .failed)
			}
		}
		
	}

	// MARK: 查看货币持有者分配
	public func checkFamilyTokenHolderInfo(chain:Chain.ChainID, tokenAddress: EthereumAddress?, owners: [EthereumAddress]) async -> OwnersTokenBalance {
		guard let erc20 = ChainManager.global.erc20(chain: chain, tokenAddress: tokenAddress) else {
			return [:]
		}
		debugPrint("开始查看货币持有者分配")
		
		return await withCheckedContinuation { conti in
			let amounts = ThreadSafeDictionary(dict: OwnersTokenBalance())
			var lock: Bool = false
//			let serial = DispatchQueue(label: "com.family-dao.serial")
			for owner in owners {
				var amount = BigUInt()
				do {
					amount = try erc20.getBalance(account: owner)
				} catch let err {
					print((err as? Web3Error)?.errorDescription ?? "")
				}
				//TODO: BigUInt to String
				amounts[owner.address] = amount.SimplifiedString()
//				serial.async {
//				}
				if amounts.count == owners.count, !lock {
					lock = true
					DispatchQueue.main.async {
						conti.resume(returning: amounts.dictionary)
					}
				}
			}
		}
		
	}

	// MARK: RPC covalenthq.com 获取钱包信息
	public static func checkTokenInfo() async -> TokenContractInfo? {
		guard let tokenContract = WalletManager.shared.currentFamily?.token?.address,
			  let tokenAddress = tokenContract.ethereumAddress(),
			  let chain = WalletManager.shared.currentFamily?.chain,
			  let erc20 = ChainManager.global.erc20(chain:chain,tokenAddress: tokenAddress) else {
			return nil
		}
		var total: BigUInt?
		do {
			total = try erc20.totalSupply()
		} catch let err {
			print((err as? Web3Error)?.errorDescription ?? "")
		}
		let interactor = NetworkAPIInteractor()
		
		let result = await interactor.request(api: .tokenInfo(tokenContract: tokenContract), mapTo: TokenContractInfo.self, queue: interactor.concurrentQueue)
		result?.data?.first?.totalSupply = total
		return result
	}
	
	/// 发送 ETH: 从 godWallet 到指定钱包
	public func sendETHFromGodWallet(to:EthereumAddress?,
									 amountInEther: String,
									 statusHandler:((ChainLoadingStatus)->Void)?) async -> TransactionReceipt.TXStatus? {
		if !NetworkEnviroment.shared.isDeveloperMode {
			statusHandler?(.end)
			return .ok
		}
		guard let godWallet = WalletManager.shared.godWallet,
			  let toAddress = to ?? WalletManager.shared.currentWallet?.ethereumAddress,
			  godWallet.address != toAddress.address else {
			statusHandler?(.error("bkockklksdsanew_home_name_perospn".appLocalizable))
			return .failed
		}
		
		debugPrint("上帝钱包开始send \(amountInEther) eth")
		
		statusHandler?(.creating("trnaootokenbnew_home_name_perospn".appLocalizable))
		
		return await withCheckedContinuation { conti in
			let chain = WalletManager.shared.currentFamilyChain
			let web3 = ChainManager.global.currentGodWalletWeb3provider(chain)
			
			var options = TransactionOptions.defaultOptions
			options.type = .eip1559
			options.maxFeePerGas = .automatic//.manual(Web3.Utils.parseToBigUInt("1.5", units: Web3.Utils.Units.Gwei)!)
			options.maxPriorityFeePerGas = .automatic//.manual(Web3.Utils.parseToBigUInt("1.5", units: Web3.Utils.Units.Gwei)!)
			let tx = web3?.eth.sendETH(from: godWallet.ethereumAddress!, to: toAddress, amount: amountInEther)
			
			do {
				let transactionResult = try tx?.send(password: WalletManager.currentPwd)
				debugPrint("上帝钱包send tx:\(String(describing: transactionResult))")
				statusHandler?(.pending)
				self.repeatCheckCreateMultiSigStatus(chain: chain, transactionResult: transactionResult) { hashReceipt in
					let ok = hashReceipt?.status == .ok
					statusHandler?(ok ? .end : .error("new_home_name_ssperofasfspnfas".appLocalizable))
					debugPrint(ok ? "✅上帝钱包开始send" : "❌转移失败")
					conti.resume(returning: hashReceipt?.status)
				}
			} catch let send_err {
				debugPrint("err_tx:\(send_err)")
				statusHandler?(.error(send_err.localizedDescription))
				conti.resume(returning: .failed)
			}
		}
	}
	
}
