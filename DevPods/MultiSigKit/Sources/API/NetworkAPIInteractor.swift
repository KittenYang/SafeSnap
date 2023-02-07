//
//  NetworkAPIInteractor.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/6/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import RxSwift
import RxCocoa
import web3swift
import BigInt
import NetworkKit
import Moya
import YYDispatchQueuePool
import HandyJSON
import Defaults
import GnosisSafeKit

public class NetworkAPIInteractor: DisposeBagProvider {
	public init() {}

	let concurrentQueue:DispatchQueue = {
		let random = Int.random(in: 0...1000000000)
		return DispatchQueue(label: "com.kittenyang.gnosis.safe.queue_\(random)", qos: .default, attributes: .concurrent)
	}()
	public let serialQueue = DispatchQueue(label: "com.kittenyang.gnosis.safe.queue.serial", qos: .background)
	
	// MARK: 获取指定时间的 block number
	public func getLastBlockNumberByTime(fromDate: Date, toDate: Date) async -> [BlockNumberDataItem]? {
		let blocks = await self.request(api: .blockNumber(fromDate: fromDate, toDate: toDate), mapTo: CovalenthqModel<BlockNumberDataItem>.self, queue: self.concurrentQueue)
		return blocks?.data?.items
	}

	// MARK: 获取过去一段时间的 balance
	public func getBalanceByTime(fromDate: Date, toDate: Date) async -> [BigUInt]? {

		guard let chain = WalletManager.shared.currentFamily?.chain,
			  let erc20Token = WalletManager.shared.currentFamily?.token?.tokenAddress,
			  let currentUser = WalletManager.shared.currentWallet?.ethereumAddress else {
			return nil
		}
		var userBalances = [BigUInt]()
//		print("✅ \(toDate) 请求开始")
		
		// 小于 100s 则认为是当前区块的快照
		if abs(toDate.distance(to: .now)) < 100 {
			if let b = try? ChainManager.global.erc20(chain: chain, tokenAddress: erc20Token)?.getBalance(account: currentUser) {
				userBalances.append(b)
				print("✅ \(toDate) latest")
			}
		} else {
			//#if DEBUG
			//		//8391947 : 7
			//		//8395796 : 21
			//		let bk1 = BlockNumberDataItem()
			//		bk1.height = .init("8391947")
			//
			//		let bk2 = BlockNumberDataItem()
			//		bk2.height = .init("8395796")
			//
			//		let blocks:[BlockNumberDataItem] = [
			//			bk1,bk2
			//		]
			//#else
			let blocks = await self.getLastBlockNumberByTime(fromDate: fromDate, toDate: toDate) ?? []
			print("✅ \(toDate) blocks:\(blocks.compactMap({ $0.height }))")
			//#endif
//			for block in blocks {
			// 最后一个区块高度
			if let number = blocks.last?.height {
					if let b = try? ChainManager.global.erc20(chain: chain, tokenAddress: erc20Token)?.getBalance(account: currentUser, blockNumber: number) {
						// web3 contract
						userBalances.append(b)
						print("✅ \(toDate) b")
					} else if let balance = await self.request(api: .tokenHolders(adress: erc20Token, block: number), mapTo: CovalenthqModel<Erc20TokenHoldersDataItem>.self, queue: self.serialQueue)?.data?.items?.filter({ $0.address?.address == WalletManager.shared.currentWallet?.address }).compactMap({ $0.balance }), !balance.isEmpty {
						// covalenth api
						userBalances.append(contentsOf: balance)
						print("✅ \(toDate) balance")
					} else {
						print("✅ \(toDate) no")
					}
				}
//			}
		}
		
		// 选择出当前用户的货币数量快照
		print("✅ \(toDate) 单次请求完成：\(userBalances)")
		return userBalances
	}
	
	// MARK: 获取多签钱包信息
	public func getSafeInfo(chain:Chain.ChainID,safeAddress: EthereumAddress? = WalletManager.shared.currentFamily?.multiSigAddress) async -> SafeInfo? {
		guard let safe = safeAddress else {
			return nil
		}
		return await self.request(api:.getGnosisSafeInfo(address: safe.address, chain: chain), mapTo: SafeInfo.self, queue: self.concurrentQueue)
	}
	
	// MARK: 获取 family 包含哪些货币
	public func getSafeBalance(safeAddress: EthereumAddress?/* = WalletManager.shared.currentFamily?.multiSigAddress*/) async -> SafeBalance? {
		guard let safe = safeAddress else {
			return nil
		}
		debugPrint("⚠️开始getSafeBalance....")
		return await self.request(api: .getGnosisSafeBalance(address: safe.address), mapTo: SafeBalance.self, queue: self.concurrentQueue)
	}
	
	// MARK: 拉取 family 信息（获取多签钱包信息+多签钱包还有 erc20 token 的余额）
	/// forceCreate: 是否强制生成一个家庭。新建家庭的时候，可能因为网络问题 getSafeInfo 这一步为报错，但这并不代表 family 没有创建成功，还是可以先创建的。当然，import Family 的时候不能这么做，这个时候必须等 getSafeInfo 返回结果才行。
	/// forceCreate、owners\threshold\token 只需要在 createFamilyView 才需要传；importFamiltView 中不需要传
	@discardableResult
	public func createFamilyIfNeeded(chain:Chain.ChainID,
									 familyName: String,
									 familyAddress: EthereumAddress,
									 forceCreate: Bool,
									 owners: [EthereumAddress] = [],
									 threshold: Int = 0,
									 token:(address:String,
											name:String,
											symbol:String,
											decimals:Int64)? = nil) async -> Family? {
		
		debugPrint("⚠️开始getSafeFamily....")
		
		let safeInfo = await Retry.run(id: "getSafeInfo",retryCount: 2) {
			await self.getSafeInfo(chain: chain, safeAddress: familyAddress)
		} retryCondition: { safeInfo in
			safeInfo?.address == nil
		}
		
		guard let newAddress = safeInfo?.address, safeInfo?.version != nil else {
			if forceCreate {
				// 先创建一个家庭，只不过通过 getSafeInfo 获取的信息先留空
				debugPrint("⚠️强制创建一个新的Family....")
				return await self.forceSaveNewFamilyToCoreDataInFirstTime(chain: chain, familyName: familyName, familyAddress: familyAddress.address, token: token, owners: [], nonce: 0, threshold: Int64(threshold))
			}
			return nil
		}
		
		// 存在对应家庭，先创建一个实例
		debugPrint("⚠️存在对应家庭，开始创建新的Family....")
		let family = await self.forceSaveNewFamilyToCoreDataInFirstTime(chain: chain, familyName: familyName, familyAddress: newAddress, token: token, owners: (safeInfo?.owners ?? owners).compactMap({ $0.address }),nonce:Int64(safeInfo?.nonce ?? 0), threshold: Int64(safeInfo?.threshold ?? threshold))
		if let family {
			Defaults[.lastCreatingFamily] = nil
			// 同时把当前家庭写入 Keychain
			KeychainManager.saveFamily(familyname: familyName, chain: chain, familyAddress: family.address)
			await AppHUD.dismissAll()
			await WalletManager.refreshCurrentSelectedFamily()
		}
		
		return family
		
	}
	
	private func forceSaveNewFamilyToCoreDataInFirstTime(chain:Chain.ChainID,
														 familyName: String,
														 familyAddress: String,
														 token:(address:String,name:String,symbol:String,decimals:Int64)?,
														 owners: [String],
														 nonce: Int64,
														 threshold: Int64) async -> Family? {
		
		// 强制先创建一个家庭
		// TODO: 切换链
		await Family.create(address: familyAddress, name: familyName, chain: chain, owners: owners, nonce: nonce, threshold: threshold)
		
		await self.reloadFamilyInfo(familyChain: chain, familyAddress: familyAddress, initialToken: token)
	
		return try? Family.getSelected()
	}
	
	/// 完成上次未完成的 token 和 family
	public static func continusLastFamilyCreatingIfNeeded() async -> Family? {
		guard let pair = Defaults[.lastCreatingFamily],
				let multiSig = pair.family.ethereumAddress() else {
			await AppHUD.dismissAll()
			return nil
		}
		
		let last = Defaults[.lastCreatingFamily]
		//FIXME: 创建第二个家庭的时候，这里会直接return
		if let last,
		   let currentFamyAddr = WalletManager.shared.currentFamily?.address,
//		   let currentUserAddr = WalletManager.shared.currentWallet?.address,
		   let currentTokenAddr = WalletManager.shared.currentFamily?.token?.address,
		   last.family == currentFamyAddr,
			last.token == currentTokenAddr {
			// 如果内存中已经存在 UD 里的上一个团队，说明 UD 中的团队已经创建成功，可以清除标记了
			Defaults[.lastCreatingFamily] = nil
			debugPrint("📢 所有账户已就绪！删除 .lastCreatingFamily 上次标记....")
			return try? Family.getSelected()
		}
		debugPrint("📢 继续上次未完成的family....")
		// 再异步转移初始货币
		let txStatus = await ERC20TokenManager.shared.sendAllFamilyTokenToMultiSig(newWallet: multiSig,chain: last?.chain, tokenAddr: pair.token.ethereumAddress(), amount: pair.supply, statusHandler: { status in
			RunOnMainThread {
				WalletManager.shared.currentChainLoadingStatus = status
			}
		})
		
		if txStatus == .ok {
			// 初始货币转移完，再切换家庭
			let owners = pair.owners.compactMap { str in
				return str.ethereumAddress()
			}
			let fam = await WalletManager.shared.interactor.createFamilyIfNeeded(chain: pair.chain, familyName:pair.familyName,familyAddress:multiSig,forceCreate:true,owners: owners,threshold: pair.threshold,token:(pair.token,pair.tokenName,pair.tokenSymbol,Int64(Constant.defaultTokenDecimals)))
			return fam
		}
		
		return nil
	}
	
	/// initialToken 一般只在新创建或者新导入一个 family 的时候才需要传入
	public func reloadFamilyInfo(familyChain: Chain.ChainID,familyAddress: String, initialToken token:(address:String,name:String,symbol:String,decimals:Int64)? = nil) async {
		let existFamily = WalletManager.shared.currentFamily
		
		// 每次刷新时候请求一下多签钱包信息
		let safeInfo = await Retry.run(id: "getSafeInfo") {
			await self.getSafeInfo(chain: familyChain, safeAddress: familyAddress.ethereumAddress())
		} retryCondition: { safeInfo in
			safeInfo?.address == nil
		}

		debugPrint("⚠️收到 getSafeInfo 回调")
		debugPrint("safeInfo:\(String(describing: safeInfo))")
		
		let nonce = safeInfo?.nonce ?? Int(existFamily?.nonce ?? 0)
		let threshold = safeInfo?.threshold ?? Int(existFamily?.threshold ?? 0)
		if let owners = safeInfo?.owners,
			let newChainID = safeInfo?.chainId ?? existFamily?.chainID,
			let chain = Chain.ChainID(rawValue: newChainID) {
			func updateTokenAmount() async {
				// 这里是erc20
				// (所有owner分别占比货币有多少)
				let balance = await ERC20TokenManager.shared.checkFamilyTokenHolderInfo(chain: chain, tokenAddress: existFamily?.token?.tokenAddress, owners: owners)
				var validBalance: OwnersTokenBalance? = balance
				if balance.isEmpty {
					validBalance = nil
				}
				// 更新 Family
				await existFamily?.update(name: existFamily?.name, owners: safeInfo?.owners?.compactMap({$0.address}), nonce: Int64(nonce), threshold: Int64(threshold), ownerTokenBalance: validBalance)
				debugPrint("⚠️更新 owner 持有货币信息：\(String(describing: validBalance))")
			}
			
			if existFamily?.token == nil {
				let balance = await Retry.run(id: "getSafeBalance") {
					await self.getSafeBalance(safeAddress: familyAddress.ethereumAddress())
				} retryCondition: { balance in
					(balance?.items?.isEmpty ?? true) == true
				}

				let item = balance?.items?.filter({ $0.tokenInfo?.type == .erc20 }).first
				   
				var total: String?
				let tokenAddr = token?.address.ethereumAddress() ?? item?.tokenInfo?.address?.ethereumAddress()
				if let tokenAddr, let erc20 = ChainManager.global.erc20(chain: chain, tokenAddress: tokenAddr) {
					do {
						let _total = try erc20.totalSupply()
						let _decimals = erc20.decimals
						total = Web3.Utils.formatToEthereumUnits(_total, toUnits: .eth, decimals: Int(_decimals))//Constant.defaultTokenDecimals
					} catch {
						print("totalSupply error:\(error)")
					}
				}
				
				// 第一个 erc20
				if let item = item,
				   let tokenName = item.tokenInfo?.name,
				   let tokenSymbol = item.tokenInfo?.symbol,
				   let tokenDecimals = item.tokenInfo?.decimals,
				   let tokenAddr = item.tokenInfo?.address?.ethereumAddress() {
					let newToken = await FamilyToken.create(address: tokenAddr.address, name: tokenName, symbol: tokenSymbol, decimals: tokenDecimals, totalSupply: total)
					try? await Family.getSelected()?.update(token: newToken)
				} else if let token {
					let newToken = await FamilyToken.create(address: token.address, name: token.name, symbol: token.symbol, decimals: token.decimals, totalSupply: total)
					try? await Family.getSelected()?.update(token: newToken)
				}
			}
			await updateTokenAmount()
		} else {
			// 更新 family
			await existFamily?.update(name: existFamily?.name, owners: existFamily?.owners, nonce: Int64(existFamily?.nonce ?? 0), threshold: Int64(existFamily?.threshold ?? 0))
			debugPrint("⚠️更新 family 普通信息")
		}
	}
	
	// MARK: 获取发送交易详情（和发送交易返回的数据一致）
	public func getSafeTxHashInfo(safeTxHash: String, completionHandler:((SafeTxHashInfo?, BaseError?) -> Void)?) {
		debugPrint("⚠️开始获取一笔交易详情....")
		// 为了防止并发太多详情，这里也用一个串行队列
		Network.getSafeTxHashInfo(safeTxHash: safeTxHash)
			.request(autoLoading: true, callbackQueue: YYDispatchQueueGetForQOS(.background))
			.asObservable()
			.showErrorToast({ completionHandler?(nil, $0) })
			.mapObject(to: SafeTxHashInfo.self)
			.subscribe(onNext: { (result) in
				completionHandler?(result, nil)
			}).disposed(by: self.disposeBag)
	}

	// MARK: 获取钱包交易的历史记录
	public func getSafeHistory(completionHandler:((SafeHistory?, BaseError?) -> Void)?) {
		debugPrint("⚠️开始getSafeHistory....")
		guard let safe = WalletManager.shared.currentFamily?.multiSigAddress else {
			return
		}
		Network.getSafeHistory(address: safe.address)
			.request(autoLoading: true, callbackQueue: self.concurrentQueue)
			.asObservable()
			.showErrorToast({ completionHandler?(nil, $0) })
			.mapObject(to: SafeHistory.self)
			.subscribe(onNext: { (result) in
				completionHandler?(result, nil)
			}).disposed(by: self.disposeBag)
	}
	
	// MARK: 获取等待处理的交易
	public func getSafeQueues(offset:Int?, limit:Int?) async -> FixedSafeHistory? {
		debugPrint("⚠️开始getSafeQueues....")
		guard let safe = WalletManager.shared.currentFamily?.multiSigAddress else {
			return nil
		}
		var cursor: NetworkAPIGnosiSafeQueued.Cursor?
		var more: Bool = false
		if let offset, let limit {
			cursor = .init(limit: limit, offset: offset)
			more = true
		}
		let history = await self.request(api: .getSafeQueued(address: safe.address, cursor: cursor), mapTo: SafeHistory.self, queue: self.concurrentQueue)
		let fixed = self._assembleSafeHistory(history: history, more: more)
		return fixed
	}
	
	private func _assembleSafeHistory(history: SafeHistory?, more: Bool) -> FixedSafeHistory {
		/*
		 {
				"next": [["发送"]],
				"queue": [["发送"],["发送","拒绝"]]
		 }
		 */
		var fixed = FixedSafeHistory()
		var headLabel: SafeHistory.SafeHistoryResult.LabelType? // next\queue
		if more {
			headLabel = .queued
			fixed[headLabel!] = [[SafeHistory.SafeHistoryResult]]()
		}
		history?.results?.forEach({ res in
			if let newLabel = res.label {
				headLabel = newLabel
				if fixed[newLabel] == nil {
					fixed[newLabel] = [[SafeHistory.SafeHistoryResult]]()
				}
			}
			func addMultiple() {
				if let currentLabel = headLabel {
					var last = fixed[currentLabel]?.last ?? [SafeHistory.SafeHistoryResult]()
					last.append(res)
					let _ = fixed[currentLabel]?.popLast()
					fixed[currentLabel]?.append(last)
				}
			}
			if let currentLabel = headLabel {
				// 关键 cell 要加入
				if let conflictType = res.conflictType, res.transaction != nil {
					switch conflictType {
					case .end,.next:
						addMultiple()
					case .none:
						fixed[currentLabel]?.append([res])
					}
				}
				
				// 冲突 header 也要加入
				if res.type == .conflictheader {
					fixed[currentLabel]?.append([res])
				}
			}
		})
		return fixed

	}
	
	/*
	 **************************************** POST ****************************************
	 */
	
	// MARK: 预测一下 nonce 和 gsa 费
	public func getTransactionEstimation() async -> SafeTransactionEstimation? {
		debugPrint("⚠️开始预测nonce....")
		guard let safe = WalletManager.shared.currentFamily?.multiSigAddress else {
			return nil
		}
		return await self.request(api: .multisigTransactionsEstimations(address: safe.address), mapTo: SafeTransactionEstimation.self,queue: self.concurrentQueue)
	}
	
	//MARK: 上链
	public func execuAction(txHashInfo: SafeTxHashInfo?, statusHandler: ((BlockChainStatus)->Void)?) {
		DispatchQueue.global().async {
			guard let txData = txHashInfo?.txData,
						let executionInfo = txHashInfo?.detailedExecutionInfo,
						let confirmations = executionInfo.confirmations else {
				return
			}
			
//			第一次上链走
			// All the signatures are sorted by the signer hex address and concatenated
			let signatures = confirmations.sorted { lhs, rhs in
				if let l = lhs.signer?.toHexData().toHexStringWithPrefix(), let r = rhs.signer?.toHexData().toHexStringWithPrefix() {
					return l < r
				}
				return false
			}.map { confirmation in
				if let sig = confirmation.signature {
					return Data(hex: sig)
				}
				return Data()
			}.joined()
			
			GnosisSafeManagerL2.shared.execTransaction(chain: WalletManager.shared.currentFamilyChain, tokenAddress: txData.to!.value!.ethereumAddress()!,
													   value: txData.value!.convertToBigUInt()!,
													   data: txData.hexData?.toHexData() ?? .init(),
													   operation: txData.operation ?? .call,
													   safeTxGas: executionInfo.safeTxGas ?? 0,
													   baseGas: executionInfo.baseGas ?? 0,
													   gasPrice: executionInfo.gasPrice ?? 0,
													   gasToken: executionInfo.gasToken ?? .ethZero,
													   refundReceiver: executionInfo.refundReceiver?.ethereumAddress() ?? .ethZero,
													   signatures: Data(signatures)) { status in
				DispatchQueue.main.async {
					statusHandler?(status)
				}
			}
		}
	}
	
	//MARK: 获取详情并上链
	public func getSafeTxHashInfoThenExecu(safeTxHash: String, statusHandler: ((BlockChainStatus)->Void)?) {
		debugPrint("⚠️开始获取一笔交易详情+执行....")
		statusHandler?(.submit)
		Network.getSafeTxHashInfo(safeTxHash: safeTxHash)
			.request(autoLoading: true, callbackQueue: self.concurrentQueue)
			.asObservable()
			.showErrorToast({ statusHandler?(.errorOccur(e: $0)) })
			.mapObject(to: SafeTxHashInfo.self)
			.subscribe(onNext: { [weak self] (result) in
				self?.execuAction(txHashInfo: result, statusHandler: statusHandler)
			}).disposed(by: self.disposeBag)
	}
	
	// MARK: 修改 family App settings 配置
	public func proposeChangeSettingsAction(nonce: UInt256? = nil, data: Data) async -> (SafeTxHashInfo?, BlockChainStatus?) {
		guard let safe = WalletManager.shared.currentFamily?.multiSigAddress else {
			return (nil, nil)
		}
		return await self.proposeAction(nonce: nonce, value: BigUInt(0), tokenAddr: .zero, toAddress: safe, data: data)
	}
	
	// MARK: 修改 family 配置 - 通过人数
	public func proposeChangeThreshold(nonce: UInt256? = nil, threshold: Int) async -> (SafeTxHashInfo?, BlockChainStatus?) {
		let threshold = Sol.UInt256.init(threshold)
		let data = GnosisSafe_v1_3_0.changeThreshold(_threshold: threshold).encode()
		return await self.proposeChangeSettingsAction(nonce:nonce,data: data)
	}
	
	// MARK: 增加人数同时修改通过人数
	public func proposeAddOwnerWithThreshold(threshold: Int, owner: EthereumAddress) async -> (SafeTxHashInfo?, BlockChainStatus?) {
		guard let owner = Sol.Address.init(maybeData:owner.data32) else { return (nil,nil) }
		let threshold = Sol.UInt256.init(threshold)
		let data = GnosisSafe_v1_3_0.addOwnerWithThreshold(owner: owner, _threshold: threshold).encode()
		return await self.proposeChangeSettingsAction(nonce:nil,data: data)
	}
	
	// MARK: 移除人数同时修改通过人数
	public func proposeRemoveOwnerWithThreshold(threshold: Int, prevOwner: EthereumAddress?, oldOwner: EthereumAddress) async -> (SafeTxHashInfo?,BlockChainStatus?) {
		guard let oldOwner = Sol.Address.init(maybeData:oldOwner.data32),
			  let prevOwner = prevOwner == nil ? Sol.Address(1) : Sol.Address.init(maybeData:prevOwner!.data32)
		else { return (nil,nil) }

		let threshold = Sol.UInt256.init(threshold)
		let data = GnosisSafe_v1_3_0.removeOwner(prevOwner: prevOwner, owner: oldOwner, _threshold: threshold).encode()
		
		return await self.proposeChangeSettingsAction(nonce:nil,data: data)
	}
	
	
	// MARK: 发起一笔交易
	/**
	 同一个 nonce, 同一个 value, 重复多次无效
	 */
	public func proposeAction(nonce: UInt256? = nil, value: BigUInt, tokenAddr: EthereumAddress? = nil, toAddress: EthereumAddress? = nil, data: Data? = nil) async -> (SafeTxHashInfo?, BlockChainStatus?) {
		guard let tokenAddr = tokenAddr ?? WalletManager.shared.currentFamily?.token?.tokenAddress,
			  let toAddress = toAddress ?? WalletManager.shared.currentWallet?.ethereumAddress,
			  let safe = WalletManager.shared.currentFamily?.multiSigAddress else {
			return (nil,nil)
		}
		do {
			if let nonce {
				let signTxn = SignTransaction(safe: safe, to: toAddress, tokenAddress: tokenAddr, value: value, data:data, nonce: nonce)
				return try await self.runProposeAction(_n: nonce, value: value, tokenAddress: tokenAddr, signTxn: signTxn)
			} else {
				let estimation = await self.getTransactionEstimation()
				if let _nonce = estimation?.nonce {
					print("最终_nonce：\(_nonce.description)")
					let signTxn = SignTransaction(safe: safe, to: toAddress, tokenAddress: tokenAddr, value: value, data:data, nonce: _nonce)
					return try await self.runProposeAction(_n: _nonce, value: value, tokenAddress: tokenAddr, signTxn: signTxn)
				} else {
					throw BaseError("dasaf_nonopdasfnew_home_name_perospn".appLocalizable)
				}
			}
		} catch let error as BaseError {
			await AppHUD.show(error.message)
			return (nil, nil)
		} catch {
			await AppHUD.show(error.localizedDescription)
			return (nil, nil)
		}
	}
	
	// MARK: 发起一笔拒绝
	/*
	 1. nonce -1(相当于替换之前 tranfer 的交易)
	 2. to 变成钱包地址
	 3. data 变成 0x
	 */
	public func proposeRejectAction(nonce: UInt256, errorHandler:((Error)->Void)?) async -> (SafeTxHashInfo?, BlockChainStatus?) {
		
		do {
			guard let safe = WalletManager.shared.currentFamily?.multiSigAddress else {
				throw BaseError("new_home_name_perospn_nsojopfajsfa".appLocalizable)
			}
			
			debugPrint("⚠️开始一笔拒绝交易....")
			// 拒绝交易只要对当下的nonce 执行一次 value==0 的操作即可
			let value = BigUInt(0)
			var signTxn = SignTransaction(safe: safe, to: safe, tokenAddress: .zero, value: value, nonce: nonce)
			
			debugPrint("⚠️开始签名....")
			guard let sig = signTxn.signatureString else {
				throw BaseError("sinbgerrornew_home_name_perospn".appLocalizable)
			}
			debugPrint("⚠️开始 RPC 请求 - proposeRejectAction")
			let hashInfo = await self._proposeAction(safe: safe.address, to: safe.address, data: signTxn.data, nonce: String(signTxn.nonce), safeTxHash: signTxn.safeTxHashWithPrefix, signature: sig)
			//TODO: 自动上链
			//				if let hashInfo, hashInfo.canExecu() {
			//					self.execuAction(txHashInfo: hashInfo) { status in
			//						debugPrint("自动执行：\(status.desc)")
			//						completionHandler?(hashInfo, err, status)
			//					}
			//				} else {
			return (hashInfo,.noNeedExecu)
			//				}
		} catch let error as BaseError {
			await AppHUD.show(error.message)
			errorHandler?(error)
			return (nil, nil)
		} catch {
			await AppHUD.show(error.localizedDescription)
			errorHandler?(error)
			return (nil, nil)
		}
	}
	
	/*
	 获取本笔交易详情，然后再 confirm
	 */
	public func getSafeTxHashInfoThenConfirmations(safeTxHash: String, _ completionHandler:((SafeTxHashInfo?, BaseError?) -> Void)?) {
		debugPrint("⚠️开始获取本笔交易详情....")
		Network.getSafeTxHashInfo(safeTxHash: safeTxHash)
			.request(autoLoading: true, callbackQueue: self.concurrentQueue)
			.asObservable()
			.showErrorToast({ completionHandler?(nil, $0) })
			.mapObject(to: SafeTxHashInfo.self)
			.subscribe(onNext: { [weak self] (result) in
				self?.confirmations(safeTxHashInfo: result, completionHandler)
			}).disposed(by: self.disposeBag)
	}
	
	/*
	 同意一笔发送 or 同意一笔拒绝
	 */
	public func confirmations(safeTxHashInfo: SafeTxHashInfo, _ completionHandler:((SafeTxHashInfo?, BaseError?) -> Void)?) {
		DispatchQueue.global().async {
			guard let safe = WalletManager.shared.currentFamily?.multiSigAddress,
						var transaction = SignTransaction(tx: safeTxHashInfo),
						let safeTxHash = transaction.safeTxHash else {
				completionHandler?(nil,nil)
				return
			}
			
			transaction.safe = safe
			
			if let sig = transaction.signatureString {
				Network.confirmations(txHash: safeTxHash, signedTxHash: sig)
					.request(autoLoading: true, callbackQueue: self.concurrentQueue)
					.asObservable()
					.showErrorToast({ completionHandler?(nil, $0) })
					.mapObject(to: SafeTxHashInfo.self)
					.subscribe(onNext: { (result) in
						completionHandler?(result, nil)
					}).disposed(by: self.disposeBag)
			} else {
				completionHandler?(nil,nil)
			}			
		}
	}
	
}

extension NetworkAPIInteractor {
	private func _proposeAction(safe: String, to: String, data: Data, nonce: String, safeTxHash: String, signature: String) async -> SafeTxHashInfo? {
		// 发起操作为了避免同一个 nonce 期间多次，这里用一个串行队列
		return await self.request(api: .propose(safe: safe, to: to, data: data, nonce: nonce, safeTxHash: safeTxHash, signature: signature), mapTo: SafeTxHashInfo.self, queue: self.serialQueue)
	}
}

// MARK: private
extension NetworkAPIInteractor {
	
	//TODO: 循环引用
	func runProposeAction(_n: UInt256, value: BigUInt, tokenAddress:EthereumAddress, signTxn: SignTransaction) async throws -> (SafeTxHashInfo?, BlockChainStatus?) {
		guard let safe = WalletManager.shared.currentFamily?.multiSigAddress
//				,let toAddress = WalletManager.shared.currentWallet?.ethereumAddress
		else {
			throw BaseError("eororkkknlokanew_home_name_perospn".appLocalizable)
		}
		
		debugPrint("⚠️开始一笔多签交易....:\(_n)")
		var signTxn = signTxn//SignTransaction(safe: safe, to: toAddress, tokenAddress: tokenAddress, value: value, nonce: _n)
		debugPrint("⚠️开始签名....")
		guard let sig = signTxn.signatureString else {
			debugPrint("❌签名错误")
			throw BaseError("sinbgerrornew_home_name_perospn".appLocalizable)
		}
		debugPrint("⚠️开始 RPC 请求 - proposeAction")
		let hashInfo = await self._proposeAction(safe: safe.address, to: signTxn.to.address, data: signTxn.data, nonce: String(_n), safeTxHash: signTxn.safeTxHashWithPrefix, signature: sig)
		
		//TODO: 自动上链
//				if let hashInfo, hashInfo.canExecu() {
//					self?.execuAction(txHashInfo: hashInfo, statusHandler: { status in
//						debugPrint("自动执行：\(status.desc)")
//						completionHandler?(hashInfo, err, status)
//					})
//				} else {
		return (hashInfo, .noNeedExecu)
//				}
	}
}

extension NetworkAPIInteractor {
	func request<T>(api: Network, mapTo:T.Type, queue: DispatchQueue) async -> T? where T:HandyJSON {
		do {
			return try await withCheckedThrowingContinuation ({ conti in
				Network.provider.rx.request(api.api.autoLoading, callbackQueue: queue)
					.asObservable()
					.showErrorToast({ baseError in
						conti.resume(throwing: baseError)
					})
					.mapObject(to: T.self)
					.subscribe(onNext: { (result) in
						conti.resume(returning: result)
					}).disposed(by: self.disposeBag)
			})
		} catch let error as BaseError {
			DispatchQueue.main.async {
				AppHUD.show(error.message)
			}
			return nil
		} catch {
			DispatchQueue.main.async {
				AppHUD.show(error.localizedDescription)
			}
			return nil
		}
	}
}

public extension BidirectionalCollection {
	typealias Element = Self.Iterator.Element

	func before(_ itemIndex: Self.Index?) -> Element? {
		if let itemIndex = itemIndex {
			let firstItem: Bool = (itemIndex == startIndex)
			if firstItem {
				return nil
			} else {
				return self[index(before: itemIndex)]
			}
		}
		return nil
	}
}
