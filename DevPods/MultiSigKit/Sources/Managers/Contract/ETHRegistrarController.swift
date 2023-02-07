//
//  ETHRegistrarController.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift
import BigInt
import CryptoSwift

public class ETHRegistrarController: Contract {
	
	// https://goerli.etherscan.io/address/0xE264d5bb84bA3b8061ADC38D3D76e6674aB91852#code
	public static let ENSPublicResolver = "0x58e4627848223BF59F8Ce34265c426E7B05E8625"
//	public static let ENSPublicResolver1 = "0xE264d5bb84bA3b8061ADC38D3D76e6674aB91852"
	
	// BaseRegistrarImplementation:https://github.com/ensdomains/ens-contracts/blob/master/deployments/goerli/BaseRegistrarImplementation.json
	// BaseRegistrarImplementation transferFrom:https://goerli.etherscan.io/tx/0x084e3db0ddf5da8ffd902e5d1c11e2a826a0ecf1dcbbd4a67f77546d02e95c43
	// ENSRegistryWithFallback setOwner:https://goerli.etherscan.io/tx/0x80b1fac8524505e1a70a811019eb41208ede7d3416ca67ff56feecd9e869f1b2
	
	// ENS 域名 ETHRegistrarController 合约 goerli 网络地址(legacy)
	public static func ContractAssress(_ chain: Chain.ChainID) -> EthereumAddress {
		return EthereumAddress("0x283Af0B28c62C092C9727F1Ee09c02CA627EB7F5")!
		//		// ETHRegistrarController 合约 goerli 网络新合约地址
		//		public static let NewEnsBuyerContractAssress = "0x4a16c6Bbee697b66706E7dc0101BfCA1d60cdE76"
	}
	
	// ETHRegistrarController
	public static var ContractABI: String {
		return """
		   [{"inputs":[{"internalType":"contractBaseRegistrar","name":"_base","type":"address"},{"internalType":"contractPriceOracle","name":"_prices","type":"address"},{"internalType":"uint256","name":"_minCommitmentAge","type":"uint256"},{"internalType":"uint256","name":"_maxCommitmentAge","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"name","type":"string"},{"indexed":true,"internalType":"bytes32","name":"label","type":"bytes32"},{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":false,"internalType":"uint256","name":"cost","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"expires","type":"uint256"}],"name":"NameRegistered","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"name","type":"string"},{"indexed":true,"internalType":"bytes32","name":"label","type":"bytes32"},{"indexed":false,"internalType":"uint256","name":"cost","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"expires","type":"uint256"}],"name":"NameRenewed","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"oracle","type":"address"}],"name":"NewPriceOracle","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"constant":true,"inputs":[],"name":"MIN_REGISTRATION_DURATION","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"available","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"bytes32","name":"commitment","type":"bytes32"}],"name":"commit","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"name":"commitments","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"isOwner","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"owner","type":"address"},{"internalType":"bytes32","name":"secret","type":"bytes32"}],"name":"makeCommitment","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"payable":false,"stateMutability":"pure","type":"function"},{"constant":true,"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"owner","type":"address"},{"internalType":"bytes32","name":"secret","type":"bytes32"},{"internalType":"address","name":"resolver","type":"address"},{"internalType":"address","name":"addr","type":"address"}],"name":"makeCommitmentWithConfig","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"payable":false,"stateMutability":"pure","type":"function"},{"constant":true,"inputs":[],"name":"maxCommitmentAge","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"minCommitmentAge","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"owner","type":"address"},{"internalType":"uint256","name":"duration","type":"uint256"},{"internalType":"bytes32","name":"secret","type":"bytes32"}],"name":"register","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"owner","type":"address"},{"internalType":"uint256","name":"duration","type":"uint256"},{"internalType":"bytes32","name":"secret","type":"bytes32"},{"internalType":"address","name":"resolver","type":"address"},{"internalType":"address","name":"addr","type":"address"}],"name":"registerWithConfig","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"uint256","name":"duration","type":"uint256"}],"name":"renew","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[],"name":"renounceOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"uint256","name":"duration","type":"uint256"}],"name":"rentPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"_minCommitmentAge","type":"uint256"},{"internalType":"uint256","name":"_maxCommitmentAge","type":"uint256"}],"name":"setCommitmentAges","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"contractPriceOracle","name":"_prices","type":"address"}],"name":"setPriceOracle","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"bytes4","name":"interfaceID","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"pure","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"valid","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"pure","type":"function"},{"constant":false,"inputs":[],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"}]
		"""
	}
	
	enum Method: ContractMethod {
		case MIN_REGISTRATION_DURATION
		case available(domainName:String)
		case makeCommitment(domainName:String, owner:EthereumAddress, salt:Data)
		// makeCommitmentWithConfig 需要和 registerWithConfig 搭配使用
		case makeCommitmentWithConfig(domainName:String, owner:EthereumAddress, salt:Data, resolver:EthereumAddress, addr: EthereumAddress)
		case commit(commitment:Data)
		case rentPrice(domainName:String, duration: BigUInt)
		case register(domainName:String, owner:String, duration: BigUInt, salt:String, value:BigUInt)
		//控制人还是以 owner 为准，resolver 是解析器（一般为公共解析器），addr 只是一条 record 记录，当输入name.eth时候可以自动解析到这个 addr
		case registerWithConfig(domainName:String, owner:String, duration: BigUInt, salt:String, resolver:EthereumAddress, addr: EthereumAddress, value:BigUInt)
		case transferOwnership(newOwner:EthereumAddress)
		
		var methodName:String {
			switch self {
			case .MIN_REGISTRATION_DURATION:
				return "MIN_REGISTRATION_DURATION"
			case .available:
				return "available"
			case .register(_,_,_,_,_):
				return "register"
			case .registerWithConfig(_,_,_,_,_,_,_):
				return "registerWithConfig"
			case .makeCommitment(_,_,_):
				return "makeCommitment"
			case .makeCommitmentWithConfig(_,_,_,_,_):
				return "makeCommitmentWithConfig"
			case .commit(_):
				return "commit"
			case .rentPrice(_, _):
				return "rentPrice"
			case .transferOwnership(_):
				return "transferOwnership"
			}
		}
		var priceValue:BigUInt {
			switch self {
			case .register(_, _, _, _, let value):
				return value
			case .registerWithConfig(_, _, _, _,_,_,let value):
				return value
			default:
				return 0
			}
		}
		var type: MethodType {
			switch self {
			case .MIN_REGISTRATION_DURATION,.available,.makeCommitment(_,_,_),.makeCommitmentWithConfig(_,_,_,_,_),.rentPrice(_,_):
				return .read
			case .register(_,_,_,_,_),.commit(_),.registerWithConfig(_, _, _, _,_,_,_),.transferOwnership(_):
				return .write
			}
		}
		var params: [AnyObject] {
			switch self {
			case .MIN_REGISTRATION_DURATION:
				return []
			case .available(let domain):
				return [domain as AnyObject]
			case .register(let domainName,let owner,let duration,let salt,_):
				return [domainName, owner, duration, salt] as [AnyObject]
			case .makeCommitment(let domainName,let owner, let salt):
				return [domainName,owner,salt] as [AnyObject]
			case .makeCommitmentWithConfig(let domainName,let owner, let salt, let resolver, let addr):
				return [domainName,owner,salt,resolver,addr] as [AnyObject]
			case .commit(let commitment):
				return [commitment] as [AnyObject]
			case .rentPrice(domainName: let domainName, duration: let duration):
				return [domainName,duration] as [AnyObject]
			case .registerWithConfig(domainName: let domainName, owner: let owner, duration: let duration, salt: let salt, resolver: let resolver, addr: let addr, value: _):
				return [domainName, owner, duration, salt, resolver, addr] as [AnyObject]
			case .transferOwnership(let new):
				return [new] as [AnyObject]
			}
		}
		var extraData:Data {
			return .init()
		}
	}

	public static let shared = ETHRegistrarController()
	private init() {}
		
	public func register(chain:Chain.ChainID,
						 domainName:String,
						 statusHandler:((ChainLoadingStatus)->Void)?) async -> Bool {
		guard var currentUser = WalletManager.shared.currentWallet,
			  let currentUserAddress = currentUser.ethereumAddress,
			  let resolver = ETHRegistrarController.ENSPublicResolver.ethereumAddress() else {
			return false
		}
		
		var duration = BigUInt(2419200) // 默认最少注册 28 天
		//		var duration = BigUInt(31556952) // 1年=365天=31556952秒

		let minTime = await self.callContract(sigWallet: &currentUser, chain: chain, method: Method.MIN_REGISTRATION_DURATION, returnType: BigUInt.self)

		if let minTime {
			duration = minTime
			await SnapshotManager.shared.global.creatingSpaceMsg.append("MIN_REGISTRATION_DURATION：\(minTime)")
		}
		
		duration += BigUInt(100)
		
		var available = false
		var i = 0
		
		while (!available) {
			let isAvailable = await self.callContract(sigWallet: &currentUser, chain: chain, method: Method.available(domainName: domainName), returnType: Bool.self)
			if let isAvailable {
				available = isAvailable
			}
			print("available:\(available)")
			if available || i >= 5 {
				break
			}
//			if (i < 5) {
//				available = false;
//			} else {
//				available = true;
//			}
//			print("available:\(available)")
			i+=1
		}
		
		await SnapshotManager.shared.global.creatingSpaceMsg.append("\("inuut_glocory_liulang_eracth_dafasfs".appLocalizable) \(available)")
		
		guard available else {
			await SnapshotManager.shared.global.creatingSpaceMsg.append("inuut_glssocorsssy_liulang_eracfasfth".appLocalizable)
			return false
		}
		
		// Generate a random value to mask our commitment
		let random = Web3.Utils.randomBytes(length: 32)
		if let randomArray = try? random?.toArray(type: UInt8.self) ?? [UInt8]() {
			await SnapshotManager.shared.global.creatingSpaceMsg.append("random number:\(randomArray)")
		}
		
		let saltString = random?.toHexStringWithPrefix() ?? "0x912bb286d4f5c3e26be5eaaa39542be7d85d9630939bacb9d23cd0f45610957e"
		print("salt:\(saltString)")

		// Submit our commitment to the smart contract
//		let commitment = await self.callContract(method: .makeCommitment(domainName:domainName, owner:wallet.ethereumAddress!, salt: saltString.toHexData()), returnType: Data.self) ?? .init()
		let commitment = await self.callContract(sigWallet: &currentUser, chain: chain, method: Method.makeCommitmentWithConfig(domainName:domainName, owner:currentUserAddress, salt: saltString.toHexData(), resolver: resolver, addr: currentUserAddress), returnType: Data.self) ?? .init()
		print("commitment:\(commitment.toHexStringWithPrefix())")
		
		if let txReceipt = await self.callContract(sigWallet: &currentUser, chain: chain, method: Method.commit(commitment: commitment), returnType: TransactionReceipt.self) {
			await SnapshotManager.shared.global.creatingSpaceMsg.append("txReceipt:\(txReceipt)")
		}
		
		// Add 10% to account for price fluctuation; the difference is refunded.
		let price = Double(await self.callContract(sigWallet: &currentUser, chain: chain, method: Method.rentPrice(domainName: domainName, duration: duration), returnType: BigUInt.self) ?? 0) * Double(1.1)
		let priceInt = BigUInt(Int(floor(price)))
		print("priceInt:\(priceInt.description)")
		
		await SnapshotManager.shared.global.creatingSpaceMsg.append("Waiting 60s...")
		
		// 必须得等60s，以确保其他人没有尝试注册相同的名字，同时也是在保护你的注册请求。不然会报错 Failed to fetch gas estimate
	 	try? await Task.sleep(nanoseconds: 65_000_000_000)
		
		// Submit our registration request
		await SnapshotManager.shared.global.creatingSpaceMsg.append("\("inuut_glossscory_liulang_eractfasfh".appLocalizable) \(domainName)...")
		//			if let registerReceipt = await self.callContract(method: .register(domainName: domainName, owner: wallet.address, duration: duration, salt: saltString, value: priceInt), returnType: TransactionReceipt.self) {
		//				print("registerReceipt:\(registerReceipt)")
		//			}
		if let registerReceipt = await self.callContract(sigWallet: &currentUser, chain: chain, method: Method.registerWithConfig(domainName: domainName, owner: currentUserAddress.address, duration: duration, salt: saltString, resolver: resolver, addr: currentUserAddress, value: priceInt), returnType: TransactionReceipt.self) {
			await SnapshotManager.shared.global.creatingSpaceMsg.append("registerReceipt:\(registerReceipt)")
			return true
		}
		
		return false
		
	}
	
	public func transfer(chain: Chain.ChainID) async {
		if var currentUser = WalletManager.shared.currentWallet {
			if let transferOwnership = await self.callContract(sigWallet: &currentUser, chain: chain, method: Method.transferOwnership(newOwner: currentUser.ethereumAddress!), returnType: Void.self) {
				print("transferOwnership:\(transferOwnership)")
			}
		}
	}
	
}

