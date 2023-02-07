//
//  GnosisSafeManager.swift
//  family-dao
//
//  Created by KittenYang on 7/18/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import GnosisSafeKit
import SwiftUI
import web3swift
import AlscCodableJSON
import BigInt
import Defaults

public enum BlockChainStatus: Error, Equatable {
	
	var value: String? {
		return String(describing: self).components(separatedBy: "(").first
	}
	
	public static func == (lhs: BlockChainStatus, rhs: BlockChainStatus) -> Bool {
		lhs.value == rhs.value
	}
	
	case noNeedExecu
	case noInput
	case submit
	case submited
	case done
	case failed
	case errorOccur(e: Error)
	
	public var toSafeStatus: SafeTxHashInfo.TXStatus? {
		switch self {
		case .noInput:
			return nil
		case .submit:
			return .submiting
		case .submited:
			return .pending
		case .done:
			return .success
		case .failed:
			return .failed
		case .errorOccur(_):
			return nil
		case .noNeedExecu:
			return nil
		}
	}
	
	public var desc: String {
		switch self {
		case .noInput:
			return "new_home_name_perospn_eoororooror".appLocalizable
		case .submit:
			return "new_home_name_perospn_lininkindds".appLocalizable
		case .submited:
			return "new_home_name_perospn_locoaspiciiqcont".appLocalizable
		case .done:
			return "new_home_name_perospn_sdlineksis".appLocalizable
		case .errorOccur(let err):
			var errStr = err.localizedDescription
			if let pe = err as? web3swift.Web3Error {
				errStr = pe.errorDescription
			}
			return "\("new_home_name_perospn_losodsooweeerr".appLocalizable)\(errStr)"
		case .noNeedExecu:
			return "new_home_name_perospnffnotneedofaex".appLocalizable
		case .failed:
			return "new_home_name_ssperofasfspnfas".appLocalizable
		}
	}
}

public class GnosisSafeManagerL2: BlockChainInteractable {
	
	public static let shared = GnosisSafeManagerL2()
	@Binding private var isCreating: Bool
	
	private init() {
		self._isCreating = .constant(false)
	}
	
	public static let gnosis_safe_contract: ContractModel? = {
		return decodeContractJSON("l2_gnosis_safe")
	}()
	
	public static let proxy_factory_contract: ContractModel? = {
		return decodeContractJSON("l2_proxy_factory")
	}()
	
	public static let fallback_handler_contract: ContractModel? = {
		return decodeContractJSON("l2_compatibility_fallback_handler")
	}()
	
	/*
	 完整的入口
	 */
	public static func entryNew(familyName: String,
								chainID:Chain.ChainID,
								token:(name:String,symbol:String,supply:BigUInt),
								owners: [EthereumAddress],
								threshold: Int) async -> Bool {
		
		//TODO: 替换成 await API，并且加上重试逻辑
		let result = await GnosisSafeManagerL2.shared.createNewMultiSig(familyName: familyName, familyChain: chainID,token: token, owners: owners, threshold: threshold, statusHandler: { status in
			RunOnMainThread {
				if case ChainLoadingStatus.creating(_) = status {
					//					// 先pop，再退出整个页面
					//					if let first = self.pathManager.path.first {
					//						self.pathManager.path = [first]
					//					}
					//					NavigationStackPathManager.shared.showSheetModel.presented = false
				} else if case ChainLoadingStatus.error(let msg) = status {
					Task {
						await AppHUD.show(msg)
					}
				}
				WalletManager.shared.currentChainLoadingStatus = status
			}
		})
		
		guard let _ = result?.0, let _ = result?.1 else {
			RunOnMainThread {
				WalletManager.shared.currentChainLoadingStatus = .end
			}
			await AppHUD.dismissAll()
			return false
		}
		
		// 继续创建家庭
		await NetworkAPIInteractor.continusLastFamilyCreatingIfNeeded()
		
		return true
	}
	
	/*
	 创建一个新的多签钱包
	 */
	// 最终问题还是出在账号上面！！！！ 直接用 private key 就没问题！！！草！！！
	public func createNewMultiSig(familyName: String,
								  familyChain: Chain.ChainID,
								  token:(name:String,symbol:String,supply:BigUInt),
								  owners: [EthereumAddress],
								  threshold: Int,
								  statusHandler:((ChainLoadingStatus)->Void)? = nil) async -> RepeatCheckTXTwoAddressCompletion? {
		if isCreating {
			return (nil,nil)
		}
		isCreating = true
		statusHandler?(.creating("new_wallsdnew_home_name_perospn".appLocalizable))
		debugPrint("开始创建")
		
		guard let godWallet = WalletManager.shared.godWallet,
			  let contractModel = GnosisSafeManagerL2.proxy_factory_contract,
			  let singleton = self.getSingleton(chain: familyChain),
			  let initializer = self.getInitializer(chain:familyChain, owners: owners, threshold: threshold) else {
			await AppHUD.show("crr_no_login_user_wallet".appLocalizable)
			statusHandler?(.end)
			self.isCreating = false
			return (nil,nil)
		}

		return await withCheckedContinuation ({ conti in
			let walletAddress = godWallet.ethereumAddress!
						
			//这一步创建私钥时间可以优化，不用每次重新生成。之前遇到过直接使用 data 创建的 keystoreManager 无效的情况；需要重新生成一遍 privateKey 再生成 keystoreManager 才可以。
			let web3 = ChainManager.global.currentGodWalletWeb3provider(familyChain)//web3(provider: Web3HttpProvider(URL(string: endpoint)!)!)
			let value: String = "0.0" // Any amount of Ether you need to send
						
			do {
				// other
				let abiVersion = 2 // Contract ABI version
				let parameters: [AnyObject] = [singleton, initializer, BigInt(Date().timeIntervalSince1970)] as [AnyObject] // Parameters
				let extraData: Data = Data() // Extra data for contract method
				let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
				
				// contract
				let contractAddressString = contractModel.networkAddresses[WalletManager.shared.currentFamilyChain.rawValue] ?? contractModel.defaultAddress
				let contractMethod = "createProxyWithNonce" // Contract method you want to write
				let contractABI = contractModel.abi
				let contractAddress = EthereumAddress(contractAddressString)!
				let contract = web3?.contract(contractABI, at: contractAddress, abiVersion: abiVersion)
				
				// option
				var options = TransactionOptions.defaultOptions
				options.from = walletAddress
				options.value = amount
				options.type = .eip1559
				options.maxFeePerGas = .automatic
				options.maxPriorityFeePerGas = .automatic
				//					options.gasPrice = .automatic
				//					options.gasLimit = .automatic
				options.callOnBlock = .pending // 结束才返回
				
				// send
				let tx = contract?.write(contractMethod, parameters: parameters, extraData: extraData, transactionOptions: options)
				let transactionResult = try tx?.send(password: WalletManager.currentPwd, transactionOptions: options)
				debugPrint("新建家庭 tx: \(String(describing: transactionResult))")
				self.isCreating = false // 恢复
								
				// 查询多签钱包是否创建成功
				debugPrint("✅开始轮询 MultiSig 创建结果")
				
				statusHandler?(.pending)
				
				// check
				var multiSigAddress: EthereumAddress? = nil
				var m_done: Bool = false
				var tokenAddress: EthereumAddress? = nil
				var t_done: Bool = false
				
				func check() {
					debugPrint("✅check!!!! - multiSigAddress:\(multiSigAddress?.address ?? "nil"), tokenAddress:\(tokenAddress?.address ?? "nil")")
					if m_done && t_done {
						statusHandler?(.end)
						if let family = multiSigAddress?.address, let tkn = tokenAddress?.address {
							// 此时已经有 family 和 token 了，保存一下到本地
							let addes = owners.compactMap({ $0.address })
							debugPrint("📢 lastCreatingFamily....")
							Defaults[.lastCreatingFamily] = FamilyTokenPair(chain: familyChain, family: family, familyName: familyName, owners: addes, threshold: threshold, token: tkn, tokenName: token.name, tokenSymbol: token.symbol, supply: token.supply)
						}
						conti.resume(returning: (multiSigAddress, tokenAddress))
					}
				}
				
				self.repeatCheckCreateMultiSigStatus(chain: familyChain, transactionResult: transactionResult) { hashReceipt in
					m_done = true
					multiSigAddress = hashReceipt?.logs.first?.address
					check()
				}
				
				// 创建完 Safe 后再新建货币，不然可能两笔交易上链会冲突
				// 新建一个属于自己家庭的货币
				// TODO: 同时并发两个transaction? https://github.com/skywinder/web3swift/issues/42#issuecomment-470256654
				ERC20TokenManager.shared.createToken(chain: familyChain, name: token.name, symbol: token.symbol,initialTotalSupply: token.supply, statusHandler: { status in
					statusHandler?(status)
				},finalCompletion:  { hashReceipt in
					t_done = true
					tokenAddress = hashReceipt?.logs.first?.address
					check()
				})
				
			} catch let err_tx {
				statusHandler?(.error(err_tx.localizedDescription))
				debugPrint("err_tx:\(err_tx)")
				conti.resume(returning: (nil,nil))
			}
		})
	}
	
	
	public func changeThreshold(_ new: UInt256) async {
		guard let currentUser = WalletManager.shared.currentWallet else {
			return
		}
		
		
//		await L2GnosisSafeContract().callContract(sigWallet: &currentUser, method: L2GnosisSafeContract.Method.changeThreshold(new), returnType: Void.self)
	}
	
	/*
	 TransactionIntegrationTests.swift line 408
	 发起一笔新交易
	 https://arbiscan.io/tx/0x1f078430afd6770a225ea1f80f1ff5d34490fb01657266c7d6ae4c04d78cbe79
	 0	to	address	0x5d0Fe869e120747E0e692636D02B7422fC66d37c
	 1	value	uint256	5000000000000000
	 2	data	bytes
	 3	operation	uint8	0
	 4	safeTxGas	uint256	0
	 5	baseGas	uint256	0
	 6	gasPrice	uint256	0
	 7	gasToken	address	0x0000000000000000000000000000000000000000
	 8	refundReceiver	address	0x0000000000000000000000000000000000000000
	 9	signatures	bytes	0x095971623a3e17ad053b24e9c140a25120f3f038a26865a49af57503b1473efc571ca3db48db9774a116b399ee2eeb4969aff6caad11f90c3d381b9164acc5791c00000000000000000000000085ff3e1b3055d379548b59de2aaad3de86769380000000000000000000000000000000000000000000000000000000000000000001
	 
	 
	 通过一笔交易
	 https://arbiscan.io/tx/0x1f078430afd6770a225ea1f80f1ff5d34490fb01657266c7d6ae4c04d78cbe79
	 0	to	address	0x5d0Fe869e120747E0e692636D02B7422fC66d37c
	 1	value	uint256	5000000000000000
	 2	data	bytes
	 3	operation	uint8	0
	 4	safeTxGas	uint256	0
	 5	baseGas	uint256	0
	 6	gasPrice	uint256	0
	 7	gasToken	address	0x0000000000000000000000000000000000000000
	 8	refundReceiver	address	0x0000000000000000000000000000000000000000
	 9	signatures	bytes	0x095971623a3e17ad053b24e9c140a25120f3f038a26865a49af57503b1473efc571ca3db48db9774a116b399ee2eeb4969aff6caad11f90c3d381b9164acc5791c00000000000000000000000085ff3e1b3055d379548b59de2aaad3de86769380000000000000000000000000000000000000000000000000000000000000000001

	 */
	public func execTransaction(chain:Chain.ChainID,
								tokenAddress: EthereumAddress,
								value: BigUInt,
								data: Data,
								operation: TxData.Operation = .call,
								safeTxGas: UInt256 = 0,
								baseGas: UInt256 = 0,
								gasPrice: UInt256 = 0,
								gasToken: EthereumAddress = .ethZero,
								refundReceiver: EthereumAddress = .ethZero,
								signatures: Data,
								statusHandler: ((BlockChainStatus)->Void)?) {
	
		debugPrint("开始execTransaction")
		DispatchQueue.global().async {
			guard var wallet = WalletManager.shared.currentWallet,
//						let account = wallet.ethereumAddress,
						let contractModel = GnosisSafeManagerL2.gnosis_safe_contract else {
				statusHandler?(.noInput)
				return
			}
			
			statusHandler?(.submit)
			let web3 = ChainManager.global.currentWeb3provider(chain)
			web3?.addKeystoreManager( wallet.keystoreManager )

			let walletAddress = wallet.ethereumAddress!
			do {
				
				// contract
//				let contractAddress = contractModel.networkAddresses[ChainManager.currentChain.rawValue] ?? contractModel.defaultAddress
				let contractAddress = WalletManager.shared.currentFamily?.multiSigAddress.address ?? contractModel.defaultAddress
				let contractMethod = "execTransaction" // Contract method you want to write
				let contractABI = contractModel.abi

				let contract = web3?.contract(contractABI, at: EthereumAddress(contractAddress))
				
				// option
				var options = TransactionOptions.defaultOptions
				options.from = walletAddress
//				options.value = BigUInt(0)
				
				//坑：第一笔上链会报 Failed to fetch gas estimate，后面发现就是 goeril oracel 预言机有问题，
				options.chainID = ChainManager.currentChain.web3Networks.chainID
//				options.nonce = .manual(0)
//				options.accessList = []
//				options.inpi
				
				options.type = .eip1559
				
				options.maxFeePerGas = .automatic
				options.maxPriorityFeePerGas = .automatic
//				options.maxFeePerGas = .manual(Web3.Utils.parseToBigUInt("25.5",units: .Gwei)!)
//				options.maxPriorityFeePerGas = .manual(Web3.Utils.parseToBigUInt("1.5",units: .Gwei)!)//.automatic
				
//				options.gasPrice = .manual(Web3.Utils.parseToBigUInt("1.5",units: .Gwei)!)
//				options.gasPrice = .manual(BigUInt(87500000))
//				options.gasLimit = .manual(BigUInt(100591))//草，这里写死 gasLimit 会导致第一笔上链失败！！！ 果然是这个！！！
				options.callOnBlock = .pending // 结束才返回
				
				// Others
//				var signTxn = SignTransaction(safe: safe, to: toAddress, tokenAddress: tokenAddress, value: value, nonce: nonce)
//				let signature = signTxn.signature ?? Data()
				let parameters: [AnyObject] = [
					tokenAddress,
					value,
					data,
					operation.rawValue,
					safeTxGas,
					baseGas,
					gasPrice,
					gasToken,
					refundReceiver,
					signatures] as [AnyObject] // Parameters
				
				let extraData: Data = Data()//"This is Family-DAO".toHexData() // Extra data for contract method
			
				// send
				let tx = contract?.write(contractMethod, parameters: parameters, extraData: extraData, transactionOptions: options)
				let transactionResult = try tx?.send(password: WalletManager.currentPwd, transactionOptions: options)
			
				statusHandler?(.submited)
				debugPrint("✅成功execTransaction，等待链上确认transaction:\(String(describing: transactionResult))")
				
				// 查询多签钱包是否创建成功
				debugPrint("开始轮询 MultiSig 创建结果")
				self.repeatCheckCreateMultiSigStatus(chain: chain, transactionResult: transactionResult) { hashReceipt in
					statusHandler?(hashReceipt?.status == .ok ? .done : .noNeedExecu)
					debugPrint("\(hashReceipt?.status == .ok ? "✅" : "❌")链上结果:\(String(describing: hashReceipt))")
				}
				
			} catch let err_tx {
				statusHandler?(.errorOccur(e: err_tx))
				debugPrint("❌发送交易错误:\(err_tx)")
			}

		}
	}
	

	
}


//MARK: Helper
extension GnosisSafeManagerL2 {
	// Singleton 参数
	private func getSingleton(chain: Chain.ChainID) -> EthereumAddress? {
		guard let contractModel = GnosisSafeManagerL2.gnosis_safe_contract else {
			return nil
		}
		let address = contractModel.networkAddresses[chain.rawValue] ?? contractModel.defaultAddress
		return EthereumAddress(address)
	}
	
	// Initializer 参数
	private func getInitializer(chain: Chain.ChainID, owners: [EthereumAddress], threshold: Int) -> Data? {
		guard let contractModel = GnosisSafeManagerL2.fallback_handler_contract else {
			return nil
		}
		
		// TODO: 替换初始化 owners
//		let owners: [EthereumAddress] = {
//			let own1 = currentWalletAddress
//			let own2 = EthereumAddress("0x36A7784B4C97f77D32e754Df78183df9Ad8a7604")!
//			return [own1,own2]
//		}()
		let ownerAddresses: [Sol.Address]
		do {
			ownerAddresses = try owners
				.filter({ $0 != .ethZero })
				.map { owner -> Sol.Address in
				try Sol.Address(owner.data32)
			}
		} catch {
			return nil
		}

		guard ownerAddresses.count > 0, ownerAddresses.count >= threshold else {
			return nil
		}
		// threshold
		let threshold = threshold
		
		// fallbackHandler
		let fallbackHandler = contractModel.networkAddresses[chain.rawValue] ?? contractModel.defaultAddress
		
		let setupFunctionType: GnosisSafeSetup_v1_3_0.Type = GnosisSafe_v1_3_0.setup.self
		let setupFunction = setupFunctionType.init(
				_owners: Sol.Array<Sol.Address>(elements: ownerAddresses),
				_threshold: Sol.UInt256(threshold),
				to: 0,
				data: Sol.Bytes(), //TODO: Data 存入自定义数据
				fallbackHandler: Sol.Address(hex: fallbackHandler)!,
				paymentToken: 0, //TODO: 创建钱包这些什么意思
				payment: 0,
				paymentReceiver: 0
		)
		let setupAbi = setupFunction.encode()

		return setupAbi
	}
	
	private static func decodeContractJSON(_ withName: String) -> ContractModel? {
		if let path = Bundle.main.path(forResource: withName, ofType: "json") {
			do {
				let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
				let decoder = AlscJSONDecoder()
				decoder.valueNotFoundDecodingStrategy = .custom(CustomTransformer())
				let contract = try decoder.decode(ContractModel.self, from: data)
				return contract
			} catch {
				// handle error
				return nil
			}
		}
		return nil
	}
}

class CustomTransformer: Transformer {
	override func transform(_ decoder: AlscDecoder) throws -> String {
		guard !decoder.decodeNil() else { return String.defaultValue }
		if decoder.codingPath.first?.stringValue == "abi" {
			if let container = decoder.currentContainer() as? [[String: Any]] {
				if let jsonString = container.toJSONString() {
					return jsonString
				}
			}
		}
		return try super.transform(decoder)
	}
}


public class L2GnosisSafeContract: Contract {
	
	static let contractModel = GnosisSafeManagerL2.gnosis_safe_contract
	
	public static func ContractAssress(_ chain: Chain.ChainID) -> EthereumAddress {
		guard let contractModel = L2GnosisSafeContract.contractModel else {
			return .ethZero
		}
		let addr = contractModel.networkAddresses[chain.rawValue] ?? contractModel.defaultAddress
		return EthereumAddress(addr)!
	}
	
	public static var ContractABI: String {
		return L2GnosisSafeContract.contractModel?.abi ?? ""
	}
	
	
	public enum Method: ContractMethod {
		
		case changeThreshold(_ threshold: UInt256)
		
		public var methodName: String {
			switch self {
			case .changeThreshold(_):
				return "changeThreshold"
			}
		}
		
		public var priceValue: BigUInt {
			return 0
		}
		
		public var type: MethodType {
			switch self {
			case .changeThreshold(_):
				return .write
			}
		}
		
		public var params: [AnyObject] {
			switch self {
			case .changeThreshold(let threhold):
				return [threhold,["gasLimit":BigUInt(148188),"maxFeePerGas":Web3.Utils.parseToBigUInt("1.5",units: .Gwei)!,"maxPriorityFeePerGas":Web3.Utils.parseToBigUInt("1.5",units: .Gwei)!]] as [AnyObject]
			}
		}
		
		public var extraData: Data {
			return .init()
		}
		
	}
	
}
