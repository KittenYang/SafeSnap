//
//  SnapshotManager.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/11/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import CryptoSwift
import web3swift
import HandyJSON
import Combine
import SwiftUI

public class SnapshotGlobal:ObservableObject {
	@Published public var isCreatingSpace: Bool
	@Published public var creatingSpaceMsg: [String]
	
	public init(isCreatingSpace: Bool = false, creatingSpaceMsg: [String] = [String]()) {
		self.isCreatingSpace = isCreatingSpace
		self.creatingSpaceMsg = creatingSpaceMsg
	}
}

public struct SnapshotManager {
	
	public static let interactor: NetworkAPIInteractor = NetworkAPIInteractor()
	public static var shared = SnapshotManager()
	
	@ObservedObject public var global: SnapshotGlobal = .init()

	public static func HackerTest() async {
		SnapshotManager.shared.global.isCreatingSpace = true
		
		try? await Task.sleep(nanoseconds: 2_000_000_000)
		SnapshotManager.shared.global.creatingSpaceMsg.append("lalllalal")
		try? await Task.sleep(nanoseconds: 1_000_000_000)
		SnapshotManager.shared.global.creatingSpaceMsg.append("iiiiiiiissssss")
		try? await Task.sleep(nanoseconds: 1_000_000_000)
		SnapshotManager.shared.global.creatingSpaceMsg.append("moisnznkanskdas")
		try? await Task.sleep(nanoseconds: 3_000_000_000)
		SnapshotManager.shared.global.creatingSpaceMsg.append("njnzjabksbdkasa")
		try? await Task.sleep(nanoseconds: 1_000_000_000)
		SnapshotManager.shared.global.creatingSpaceMsg.append("ooiamskwaws")
		try? await Task.sleep(nanoseconds: 4_000_000_000)
		SnapshotManager.shared.global.creatingSpaceMsg.append("kfnlkfasfs")
		try? await Task.sleep(nanoseconds: 2_000_000_000)
		SnapshotManager.shared.global.creatingSpaceMsg.append("saldassasf")
		try? await Task.sleep(nanoseconds: 1_000_000_000)
		SnapshotManager.shared.global.creatingSpaceMsg.append("hehehee")
		
		SnapshotManager.shared.global.isCreatingSpace = false
	}
	
	/// 创建一个空间
	public static func createSpace(newDomain: String) async -> Bool {
		// https和合约交互模范范例API：
		guard var currentUser = WalletManager.shared.currentWallet else {
			print("当前不存在登录用户")
			return false
		}
		guard let tokenContract = WalletManager.shared.currentFamily?.token?.address,
			  let tokenSymbol = WalletManager.shared.currentFamily?.token?.symbol,
			  let owners = WalletManager.shared.currentFamily?.owners,
			  let chain = WalletManager.shared.currentFamily?.chain,
			  let familyName = WalletManager.shared.currentFamily?.name else {
			print("当前不存在Family.")
			return false
		}
		guard !SnapshotManager.shared.global.isCreatingSpace else {
			return false
		}
		
		defer {
			SnapshotManager.shared.global.isCreatingSpace = false
			Task {
				AppHUD.dismissAll()
			}
			debugPrint("************ isCreatingSpace 重新打开，可以继续创建 Space ****************")
		}
		SnapshotManager.shared.global.isCreatingSpace = true
		
		let txt1 = "************ \("infasfasuut_glocory_liulfafang_eracth".appLocalizable) \(newDomain) ****************"
		SnapshotManager.shared.global.creatingSpaceMsg.append(txt1)
		
		let userAddress = currentUser.address
		// 坑：ENS 注册的域名必须小写！！！！不然会提示 "statusCode Error:{\"error\":\"unauthorized\",\"error_description\":\"not allowed\"}"!!! 坑了我整整一天我草！！！
		let waitingDomain = newDomain.lowercased()
		
		//0. 注册 ENS domain Name
		let txt2 = "0. Register ENS domain Name: \(waitingDomain)"
		SnapshotManager.shared.global.creatingSpaceMsg.append(txt2)
		
		var registeSuccess = false
		registeSuccess = await ETHRegistrarController.shared.register(chain: chain, domainName: waitingDomain, statusHandler: nil)
		
		// 注意：第0步注册完，不是那么快能找到域名信息的，这里延迟个15s再查找域名
		if registeSuccess {
			SnapshotManager.shared.global.creatingSpaceMsg.append("Waiting 15s...")
			try? await Task.sleep(nanoseconds: 15_000_000_000)
		}
		
		//1.查询地址所绑定域名
		SnapshotManager.shared.global.creatingSpaceMsg.append("1.Check Domain: \(newDomain)")
		guard let domains = await ENSDomainManager.getEnsdomainsBy(userAddress)?.domains?.compactMap({ $0.name }) else {
			return false
		}
		print("当前用户绑定的domains:\(domains)")
		
		
		//2. 遍历域名，找到未开通 space 的域名
		SnapshotManager.shared.global.creatingSpaceMsg.append("2.Domain Finded:\(newDomain)")
		var availableDomainNames = [String]()
		for domain in domains {
			guard let spaces = await SnapshotManager.getSpaceInfoByENSNames([domain])?.spaces else {
				continue
			}
			print("domains-space:\(domain)-\(spaces)")
			if spaces.first?.name?.isEmpty ?? true {
				availableDomainNames.append(domain)
				SnapshotManager.shared.global.creatingSpaceMsg.append("✅ Domain:\(domain) Avaliable")
			}
		}
		
		// TODO: 选择一个域名作为空间，进行创建，这里先选择第一个
		guard let domain = availableDomainNames.first(where: { $0.contains(waitingDomain) }) ?? availableDomainNames.first else {
			SnapshotManager.shared.global.creatingSpaceMsg.append("No domain avaliable")
			return false
		}
				
		// 3.空间控制人 —— SetText
		SnapshotManager.shared.global.creatingSpaceMsg.append("3.Space —— SetText")
		await PublicResolverContract().callContract(sigWallet: &currentUser, chain: chain, method: PublicResolverContract.Method.setText(address: userAddress, domain: domain), returnType: TransactionReceipt.self)
		
		// 4.1 获取 token info
		debugPrint("4.1 获取 token info")
		let tokenInfo = await ERC20TokenManager.checkTokenInfo()
		debugPrint("tokenInfo:\(tokenInfo?.data?.description ?? "nil")")
		
		// 4.2 对 space setting 签名
		SnapshotManager.shared.global.creatingSpaceMsg.append("4. Sign for space setting")
		let symbol = tokenInfo?.data?.first?.contract_ticker_symbol ?? tokenSymbol
		let chainIDString = chain.rawValue
		let ownersString = (owners + [userAddress]).unique().compactMap({ "\"\($0)\"" }).joined(separator: ",")
		
		let typedOBJ = EIP712TypedData(types: [
			"EIP712Domain":[
				.init(name: "name", type: "string"),
				.init(name: "version", type: "string")
			],
			"Space":[
				.init(name: "from", type: "address"),
				.init(name: "space", type: "string"),
				.init(name: "timestamp", type: "uint64"),
				.init(name: "settings", type: "string")
		]], primaryType: "Space", domain: .object(["name":.string("snapshot"),"version":.string("0.1.4")]), message: .object([
			"from":.string(userAddress),
			"space":.string(domain),
			"timestamp":.number(.int(Int(Date().timeIntervalSince1970))),
			"settings":.string("{\"strategies\":[{\"name\":\"erc20-balance-of\",\"network\":\"\(chainIDString)\",\"params\":{\"network\":\"\(chainIDString)\",\"address\":\"\(tokenContract)\",\"decimals\":18,\"symbol\":\"\(symbol)\"}}],\"categories\":[\"creator\"],\"treasuries\":[],\"admins\":[\"\(userAddress)\"],\"members\":[\(ownersString)],\"plugins\":{},\"filters\":{\"minScore\":0,\"onlyMembers\":true},\"voting\":{\"delay\":0,\"hideAbstain\":false,\"period\":0,\"quorum\":0,\"type\":\"\"},\"validation\":{\"name\":\"basic\",\"params\":{}},\"network\":\"\(chainIDString)\",\"children\":[],\"private\":false,\"name\":\"\(familyName)\",\"about\":\"\",\"symbol\":\"\(symbol)\"}")
		]))
		
		print("【create space typedOBJ】:\n\(typedOBJ)")
		
		guard let signatureString = Web3Signer.signTypedMessage(typedData: typedOBJ, wallet: currentUser) else {
			return false
		}
		
		//5. 创建
		SnapshotManager.shared.global.creatingSpaceMsg.append("5. Creating by contract")
		let result = await SnapshotManager.interactor.request(api: .sigTypedData(address: userAddress, sig: signatureString, typedData: typedOBJ), mapTo: CreateSnapshotAPIMsgResult.self, queue: SnapshotManager.interactor.concurrentQueue)
		print("查看空间创建结果：\(result?.toJSONString() ?? "nil")")
		if result?.isValid ?? false {
			SnapshotManager.shared.global.creatingSpaceMsg.append("✅ Congratulation! Snapshot URL：\(URL(string: "https://snapshot.org/#/\(domain)/")!.snapshotURLifIsTestnet(chain: chain, prefix: "demo"))")
			try? await Task.sleep(nanoseconds: 5_000_000_000) //space 刚创建完，等待5s
			print("加入空间前，先等待5s")
			
			SnapshotManager.shared.global.creatingSpaceMsg.append("Final step: Fllowing this space...")
			//加入一个 space
			await SnapshotManager.followSpace(domain: domain, method: .Follow)
			
//			SnapshotManager.shared.global.isCreatingSpace = false
			
			return true
		}
		
		return false
		
	}
	
	/// 加入一个空间 Follow a space
	public enum FollowSpaceMethod: String, HandyJSONEnum {
		case Follow
		case Unfollow
	}
	public static func followSpace(domain: String, method: FollowSpaceMethod) async {
		
		guard let wallet = WalletManager.shared.currentWallet else {
			return
		}
		
		let address = wallet.address
		
		// 上报 alias
		await postAliasIfNeeded()
		
		let alias = await self.returnAliasWallat() // 本地的 alias
		guard let alias else { return }
		
		// follow
		let typedOBJ = EIP712TypedData(types: [
			"EIP712Domain":[
				.init(name: "name", type: "string"),
				.init(name: "version", type: "string")
			],
			"\(method.rawValue)":[
				.init(name: "from", type: "address"),
				.init(name: "space", type: "string")
		]], primaryType: "\(method.rawValue)", domain: .object(["name":.string("snapshot"),"version":.string("0.1.4")]), message: .object([
			"from":.string(address),
			"space":.string(domain),
			"timestamp":.number(.int(Int(Date().timeIntervalSince1970)))
		]))
		
		print("【\(method.rawValue) space typedOBJ】:\n\(typedOBJ)")
		
		//坑：follow/unfollow 这一步的签名，需要用 alias 签名！！！！
		if let signatureString = Web3Signer.signTypedMessage(typedData: typedOBJ, wallet: alias) {
			print("17.2 \(method.rawValue) a space")
			let result = await SnapshotManager.interactor.request(api: .sigTypedData(address: alias.address, sig: signatureString, typedData: typedOBJ), mapTo: CreateSnapshotAPIMsgResult.self, queue: SnapshotManager.interactor.concurrentQueue)
			print("\(method.rawValue) a space 结果：\(result?.toJSONString() ?? "nil")")
		}
	}
	
	/// 获取 Snapshot 空间信息
	public static func getSpaceInfoByENSNames(_ names:[String]?) async -> SnapshotSpaceInfo? {
		guard let names else { return nil }
		return await SnapshotManager.interactor.request(api: .spaceInfoByENSNames(names: names), mapTo: SnapshotSpaceInfo.self, queue: SnapshotManager.interactor.concurrentQueue)
	}
	
	/// 是否存在某个空间
	public static func spaceIsExist(domain:String?) async -> Bool {
		guard let domain else { return false }
		let info = await getSpaceInfoByENSNames([domain])
		return info?.spaces?.first?.id != nil
	}
	
	/// 查询用户加入的所有 space
	public static func getUserSpace() async -> SnapshotUserSpaceFollows? {
		guard let wallet = WalletManager.shared.currentWallet else {
			return nil
		}
		let address = wallet.address
		return await SnapshotManager.interactor.request(api: .getUserSpace(address: address), mapTo: SnapshotUserSpaceFollows.self, queue: SnapshotManager.interactor.concurrentQueue)
	}
	
	/// 查看空间订阅者
	public static func getSpaceSubscription(domain: String) async -> SnapshotSubscriptions? {
		guard let wallet = WalletManager.shared.currentWallet else {
			return nil
		}
		let address = wallet.address
		return await SnapshotManager.interactor.request(api: .spaceSubscription(address: address, space: domain), mapTo: SnapshotSubscriptions.self, queue: SnapshotManager.interactor.concurrentQueue)
	}
	
}

extension SnapshotManager {
	
	private static func postAliasIfNeeded() async {
		guard let wallet = WalletManager.shared.currentWallet,
			  let account = wallet.ethereumAddress else {
			return
		}
		
		let address = account.address
		
		let alias = await self.returnAliasWallat() // 本地的 alias
		if let alias {
			// 19.check 线上有没有已经绑定的 alias
			let aliasResult = await self.interactor.request(api: .checkAlias(address: account.address, alias: alias.address), mapTo: SnapshotAliasResult.self, queue: self.interactor.concurrentQueue)
			if aliasResult?.aliases?.first?.alias?.address == alias.address {
				// 说明线上和本地的 alias 一致，不需要重新上报，直接 follow
				return
			} else {
				// 不一致，需要把本地 alias 的同步到远程
				let typedOBJ = EIP712TypedData(types: [
					"EIP712Domain":[
						.init(name: "name", type: "string"),
						.init(name: "version", type: "string")
					],
					"Alias":[
						.init(name: "from", type: "address"),
						.init(name: "alias", type: "address")
				]], primaryType: "Alias", domain: .object(["name":.string("snapshot"),"version":.string("0.1.4")]), message: .object([
					"from":.string(address),
					"alias":.string(alias.address),
					"timestamp":.number(.int(Int(Date().timeIntervalSince1970)))
				]))
				
				print("【postAlias typedOBJ】:\n\(typedOBJ)")
				
				if let signatureString = Web3Signer.signTypedMessage(typedData: typedOBJ, wallet: wallet) {
					
					//18. 上报 alias
					print("18. 上报 alias")
					let result = await SnapshotManager.interactor.request(api: .sigTypedData(address: address, sig: signatureString, typedData: typedOBJ), mapTo: CreateSnapshotAPIMsgResult.self, queue: SnapshotManager.interactor.concurrentQueue)
					print("上报 alias 结果：\(result?.toJSONString() ?? "nil")")
					
				}
			}
		}
	}
	
	// 返回 alias address, if null, create new alias one
	public static func returnAliasWallat() async -> Wallet? {
		guard let wallet = WalletManager.shared.currentWallet else {
			return nil
		}
		if let alias = WalletManager.walletAliases?[wallet.address] {
			return alias
		}
		do {
			return try await withCheckedThrowingContinuation { conti in
				// alias 账号不需要身份验证，直接用本地默认的密码
				WalletManager.shared.createWalletByPrivateKey(walletName: "alias", password: WalletManager.pwdForInput) { aliasWallet, error in
					if let aliasWallet {
						WalletManager.walletAliases?[wallet.address] = aliasWallet
						conti.resume(returning: aliasWallet)
					} else if let error {
						conti.resume(throwing: error)
					}
				}
			}
		} catch let walletError as WalletError {
			debugPrint(walletError.description)
			return nil
		} catch {
			debugPrint(error.localizedDescription)
			return nil
		}
	}
}
