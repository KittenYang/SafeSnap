//
//  WalletManager.swift
//  family-dao
//
//  Created by KittenYang on 6/26/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift
import BiometricAuthentication
import Defaults
import BigInt
import SwiftUI
import NetworkKit

public struct FamilyTokenPair: Codable, Defaults.Serializable {
	public var family: String
	public var familyName: String
	public var owners: [String]
	public var threshold: Int
	public var chain: Chain.ChainID
	
	public var token: String
	public var tokenName: String
	public var tokenSymbol: String
	public var supply: BigUInt
	
	public init(chain: Chain.ChainID,family: String, familyName: String, owners: [String], threshold: Int, token: String, tokenName: String, tokenSymbol: String, supply: BigUInt) {
		self.chain = chain
		self.family = family
		self.familyName = familyName
		self.owners = owners
		self.threshold = threshold
	
		self.token = token
		self.tokenName = tokenName
		self.tokenSymbol = tokenSymbol
		self.supply = supply
	}
}

//public extension FamilyTokenPair {
//	static let bridge = UserBridge()
//}
//
//public struct UserBridge: Defaults.Bridge {
//	public typealias Value = FamilyTokenPair
//	public typealias Serializable = [String: Any]
//
//	public func serialize(_ value: Value?) -> Serializable? {
//		guard let value = value else {
//			return nil
//		}
//
//		return [
//			"chain": value.chain.rawValue,
//			"family": value.family,
//			"familyName": value.familyName,
//			"owners": value.owners,
//			"threshold": value.threshold,
//			"token": value.token,
//			"tokenName": value.tokenName,
//			"tokenSymbol": value.tokenSymbol,
//		]
//	}
//
//	public func deserialize(_ object: Serializable?) -> Value? {
//		guard
//			let object = object,
//			let chainID = object["chain"] as? String,
//			let family = object["family"] as? String,
//			let familyName = object["familyName"] as? String,
//			let owners = object["owners"] as? [String],
//			let threshold = object["threshold"] as? Int,
//			let token = object["token"] as? String,
//			let tokenName = object["tokenName"] as? String,
//			let tokenSymbol = object["tokenSymbol"] as? String
//		else {
//			return nil
//		}
//
//		return FamilyTokenPair(chain: .init(rawValue: chainID) ?? .ethereumMainnet, family: family, familyName: familyName, owners: owners, threshold: threshold, token: token, tokenName: tokenName, tokenSymbol: tokenSymbol)
//	}
//}

public extension Defaults.Keys {
	static let pwdForInput = Key<String?>("pwdForInput", default: nil)
	static let currentWallet = Key<Wallet?>("currentWallet", default: nil)
	static let lastCreatingFamily = Key<FamilyTokenPair?>("lastUnfinishedCreating", default: nil)
//	static let currentSpaceDomain = Key<String?>("currentSpaceDomain", default: nil)
	static let godWallet = Key<Wallet?>("godWallet", default: nil)
	// App 当前显示的DAO
//	static let currentFamily = Key<Family?>("currentFamily", default: nil)
	// App 内存在的DAO
//	static let families = Key<[Family]>("appFamilies", default: [])
	// 全局昵称别名。但是当前只能登录一个账号，以这个账号为视角，显示其他账户的别名。即使钱包和家庭移除，全局的昵称信息仍然可以保留
	static let ownersNickname = Key<[String:[String:String]]>("appFamilies", default: [:])
	
	//【1】 全局钱包 alias
	static let WalletAliases = Key<[String:Wallet]>("WalletAliases",default: [:])

}


// Welcome ->
extension EthereumAddress: Defaults.Serializable {}
//extension Family: Defaults.Serializable {}
extension BigUInt: Defaults.Serializable {}

public class WalletManager: ObservableObject {
	
	@Published
	public var currentContainerID:String = Constant.AppContainerID
	
	@MainActor @Published
	public var reloadChart: Bool = true
	
	public static let pwdForFaceID = "da0.faMily^%&1"
	public static var currentPwd: String {
		return Self.pwdForInput ?? self.pwdForFaceID
	}
	public static var pwdForInput: String? {
		didSet {
			Defaults[.pwdForInput] = self.pwdForInput
		}
	}
	//【2】 全局钱包 alias
	public static var walletAliases: [String:Wallet]? {
		didSet {
			Defaults[.WalletAliases] = self.walletAliases ?? [:]
		}
	}
	
	public static let shared = WalletManager()
	
	public let interactor: NetworkAPIInteractor = NetworkAPIInteractor()
	
	private init() {
		// 必须先设置 currentFamily，再设置 currentWallet
//		self.currentFamily = try? Family.getSelected() //Defaults[.currentFamily]
		self.currentWallet = Defaults[.currentWallet]
//		self.currentSpaceDomain = Defaults[.currentSpaceDomain]
		Self.pwdForInput = Defaults[.pwdForInput]
		//【3】 启动初始化
		Self.walletAliases = Defaults[.WalletAliases]
//		ChainManager.currentChain = .ethereumGoerli
		debugPrint("当前钱包：\(self.currentFamily?.multiSigAddress.address ?? "nil")")
		debugPrint("当前用户：\(self.currentWallet?.address ?? "nil")")
		debugPrint("当前货币：\(self.currentFamily?.token?.tokenAddress?.address ?? "nil")")
		debugPrint("当前空间URL：\(spaceURL()?.absoluteString ?? "nil")")
	}
	
	// 专门用于发币和生成多签钱包的钱包
	public private(set) lazy var godWallet: Wallet? = {
		// 只有开发者模式下，才有 godWallet
		if !NetworkEnviroment.shared.isDeveloperMode {
			return WalletManager.shared.currentWallet
		}
		guard let store = Defaults[.godWallet] else {
			if var wallet = try? WalletManager.shared.importWalletWithPrivateKey(Constant.god_private_key, name: "GOD_WALLET", password: WalletManager.currentPwd) {
				let _ = wallet.privateKey // lazy set private key
				Defaults[.godWallet] = wallet
				return wallet
			}
			return nil
		}
		return store
	}()
	
	/// 当前登录用户
	/// Wallet 系统没有使用 Core Data，而是使用传统的 UserDefaults
	@Published public var currentWallet: Wallet? {
		didSet {
			Defaults[.currentWallet] = self.currentWallet
			updateWallet()
		}
	}
	
	/* Space 相关 - START*/
	/// familydao-0x786252.... (没有 .eth 后缀)
//	@Published public var currentSpaceDomain: String? {
//		didSet {
//			Defaults[.currentSpaceDomain] = self.currentSpaceDomain
//		}
//	}
	
	/// https://snapshot.org/#/\(domain).eth/"
	public func spaceURL() -> URL? {
		if let domain = currentFamily?.spaceDomain, !domain.isEmpty, let chain = currentFamily?.chain {
			return URL(string: "https://snapshot.org/#/\(domain).eth/")!.snapshotURLifIsTestnet(chain: chain,prefix:"demo")
		}
		return nil
	}
	
	@MainActor
	public func updateDomain() async {
		await self.currentFamily?.updateSpaceDomain()
//		WalletManager.shared.currentSpaceDomain = domainString
	}
	
	/// familydao-0x786252.... (没有 .eth 后缀)
//	private var domainString: String? {
//		guard let currentFamily = self.currentFamily else { return nil }
////		let id = String.randomAlphaNumericString(length: 8)
//		return "familydao-\(currentFamily.address)" //currentFamily.address
//	}
	/* Space 相关 - END */
	
	// 当前DAO是否是我参与的 DAO
	@Published public var isMyFamily: Bool = false
	
//	@Published public var mainChainID: AppChain = .Ethereum
	
	@MainActor @Published public var shouldReloadQueue: Bool = false
	
	// 全局昵称别名，即使钱包和家庭移除，全局的昵称信息仍然可以保留
	// 不要直接修改这个值，为了保证同步 UD，请使用 updateNickName 方法
	@Published public var currentWalletOwnersNickname: [String:String] = [:]
	
	
//	@Published public var currentWallet: Wallet? {
//		didSet {
//			Defaults[.currentWallet] = self.currentWallet
//			updateWallet()
//		}
//	}
	

//	@Environment(\.managedObjectContext) var coreDataContext
//	@FetchRequest(fetchRequest: Family.fetchRequest().selected()) public var currentFamily: FetchedResults<Family>
	
	/// 当前选中家庭
	/// 家庭系统使用 Core Data 存储方案
	public var currentFamily: FamilyViewModel? {
		return FamilyViewModel(managedObject: try? Family.getSelected())
//		didSet {
////			Defaults[.currentFamily] = self.currentFamily
//			// 外部重新设置一个新的 Family 时，需要添加到全局家庭里
//			if let f = self.currentFamily, !Defaults[.families].contains(f) {
//				Defaults[.families].append(f)
//			}
//		}
	}
	
	public static var currentFamilyTokenDecimals: Int {
		return Int(WalletManager.shared.currentFamily?.token?.decimals ?? Int64(Constant.defaultTokenDecimals))
	}
	
	public static var currentFamilyTokenSymbol: String {
		return WalletManager.shared.currentFamily?.token?.symbol ?? ""
	}
	
	public var currentFamilyChain: Chain.ChainID {
		return self.currentFamily?.chain ?? .ethereumMainnet
	}
	
	// 是否正在上链
	@Published public var currentChainLoadingStatus: ChainLoadingStatus = .end {
		didSet {
			Task {
				await AppHUD.show(self.currentChainLoadingStatus.statusDesc)
			}
		}
	}
	
	// 更新当前用户视角下的别名
	public func updateNickName(_ map:[String:String]) {
		guard let current = currentWallet?.ethereumAddress?.address else {
			return
		}
		if Defaults[.ownersNickname][current] == nil {
			Defaults[.ownersNickname][current] = [:]
		}
		Defaults[.ownersNickname][current]?.merge(dict: map)
		self.currentWalletOwnersNickname.merge(dict: map)
	}
	
	// 移除某个DAO
	public static func logOutFamily(_ family: Family) async {
		// 首先从全局数据库中移除
		await Family.remove(safe: family)
		// 切换成缓存的另一个DAO
		await refreshCurrentSelectedFamily()
	}
	
	// 更新当前选中 family 的 owners、nonce、threshold，还有最重要的 ownerBalance
	// 这个方法每次 view appear 都会调用一次
	public static func refreshCurrentSelectedFamily() async {
		// 如果有上一个正在创建的中途退出，这里继续创建
		await NetworkAPIInteractor.continusLastFamilyCreatingIfNeeded()
		
		// 这里会读取 CoreData 最上层的家庭（移除一个的时候，会自动获取下一个家庭）
		guard let family = WalletManager.shared.currentFamily else {
			debugPrint("不存在selected family")
			return
		}
		
		// 每次刷新时候请求一下多签钱包信息
		await WalletManager.shared.interactor.reloadFamilyInfo(familyChain: family.chain, familyAddress: family.address)
		
		// 每次更新页面的时候去请求一下当前对应的空间存不存在
		let newDomain = family.staticDomain
		var spaceExist = await SnapshotManager.spaceIsExist(domain: "\(newDomain).eth")
		if !spaceExist {
			// 如果 family 对应的 Space 不存在，要及时创建一个新的 snapshot space
			spaceExist = await SnapshotManager.createSpace(newDomain: newDomain)
		} else {
			debugPrint("✅Space存在 \(newDomain)")
		}
		if spaceExist {
			await WalletManager.shared.updateDomain()
		}
	}
	
	// 当前登录DAO的货币地址
//	public var tokenAddress: EthereumAddress? {
//		guard let addr = self.currentFamily?.token.tokenAddress else { return nil }
//		return addr
//	}
	
	// 退出当前用户
	public static func logOutWallet() {
		//【4】适时移除
		if let oldwallet = WalletManager.shared.currentWallet {
			WalletManager.walletAliases?.removeValue(forKey: oldwallet.address)
		}
		WalletManager.shared.currentWallet = nil
		WalletManager.pwdForInput = nil
	}
	
	// 更新用户
	private func updateWallet() {
//		var map = [String:String]()
//		var nickNames = ["妈妈","姐姐","爸爸","哥哥"] //TODO: 自己设置昵称
//		for owner in currentFamilyOwners {
//			if owner == currentWallet?.ethereumAddress {
//				map[owner.address] = "我"
//			} else {
//				map[owner.address] = nickNames.removeFirst()
//			}
//		}
//		self.familyOwnersNickname.merge(dict: map)
		
		guard let current = currentWallet?.ethereumAddress else {
			self.isMyFamily = false
			self.currentWalletOwnersNickname = [:]
			return
		}
		// 更新别名publisher
		self.currentWalletOwnersNickname = Defaults[.ownersNickname][current.address] ?? [:]
		// 更新当前DAO是否是登录用户参与的DAO
		self.isMyFamily = self.currentFamily?.owners.contains(current.address) ?? false
	}
	
}

//MARK: Create Wallet
public extension WalletManager {
	//创建一个新钱包 - 返回秘钥
	func createWalletByPrivateKey(walletName: String, password: String? = nil, handler: @escaping (Wallet?,WalletError?)->Void) {
		
		// 如果手动传入 pass，说明用户执意使用密码
		guard let password = password else {
			// 使用生物识别登录
			if BioMetricAuthenticator.canAuthenticate() {
				BioMetricAuthenticator.authenticateWithBioMetrics(reason: "newfas_hofasme_nafasfsame_pefasrospn".appLocalizable) { (result) in
					switch result {
					case .success( _):
						debugPrint("Face ID 认证通过！")
						_createWalletByPrivateKey(pass: WalletManager.pwdForFaceID)
					case .failure(let error):
						debugPrint("Authentication Failed")
						handler(nil, WalletError.FailToBioMetricAuthenticate(error))
					}
				}
			} else {
				handler(nil, WalletError.BioMetricAuthenticateNotSupportAndNoPass)
			}
			return
		}
		
		_createWalletByPrivateKey(pass: password)
		
		func _createWalletByPrivateKey(pass: String) {
			guard let keystore = try? EthereumKeystoreV3(password: pass) else {
				handler(nil,.FailToCreateKeystore)
				return
			}
			guard let keyData = try? JSONEncoder().encode(keystore.keystoreParams) else {
				handler(nil,.JSONEncoderFailed)
				return
			}
			guard let address = keystore.addresses?.first?.address else {
				handler(nil,.KeystoreNoAddress)
				return
			}
			debugPrint("钱包地址：\(address)")
			let wallet = Wallet(address: address, data: keyData, name: walletName, mnemonics: nil, isHD: false)
			handler(wallet,nil)
		}
	}
	
	/// 创建一个新钱包 - 返回助记词
	/// autoSendInitialToken 是否默认创建完之后，从 godwallet 接受 0.1eth 测试币
	func createWalletByMnemonicsPhrase(walletName: String, password: String? = nil, autoReceiveInitialToken:Bool = true, handler: @escaping (Wallet?,WalletError?)->Void) {
		// 如果手动传入 pass，说明用户执意使用密码
		guard let password = password else {
			// 使用生物识别登录(人脸识别/FaceID)
			if BioMetricAuthenticator.canAuthenticate() {
				BioMetricAuthenticator.authenticateWithBioMetrics(reason: "new_home_name_perospnasf_huelloe".appLocalizable) { (result) in
					switch result {
					case .success( _):
						debugPrint("Face ID 认证通过！")
						_createWalletByMnemonics(pass: WalletManager.pwdForFaceID)
					case .failure(let error):
						debugPrint("Authentication Failed")
						handler(nil, WalletError.FailToBioMetricAuthenticate(error))
					}
				}
			} else {
				handler(nil, WalletError.BioMetricAuthenticateNotSupportAndNoPass)
			}
			return
		}
		
		_createWalletByMnemonics(pass: password)
		
		func _createWalletByMnemonics(pass: String) {
			//HUD starting
			/*
			 defer {
			 HUD.stop()
			 }
			 */
			debugPrint("开始创建新钱包")
			let bitsOfEntropy: Int = 128 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
			guard let mnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy) else {
				handler(nil,.FailToGenerateMnemonics)
				return
			}
			debugPrint("助记词：\(mnemonics)")
			guard let keystore = try? BIP32Keystore(mnemonics: mnemonics,
													password: pass,
													mnemonicsPassword: "",
													language: .english) else {
				handler(nil,.FailToCreateKeystore)
				return
			}
			
			guard let keyData = try? JSONEncoder().encode(keystore.keystoreParams) else {
				handler(nil,.JSONEncoderFailed)
				return
			}
			
			let ethAddress = keystore.addresses?.first
			guard let address = ethAddress?.address else {
				handler(nil,.KeystoreNoAddress)
				return
			}
			if autoReceiveInitialToken {
				Task {
					//TODO: 看来初始化转移 0.1 还不够啊
					await ERC20TokenManager.shared.sendETHFromGodWallet(to: ethAddress, amountInEther: "0.2", statusHandler: nil)
				}
			}
			debugPrint("钱包地址：\(address)")
			let wallet = Wallet(address: address, data: keyData, name: walletName, mnemonics: mnemonics, isHD: true)
			handler(wallet,nil)
		}
	}
}

//MARK: Import Wallet
public extension WalletManager {
	
	// 从秘钥导入
	func importWalletWithPrivateKey(_ privatekey: String, name: String, password: String) throws -> Wallet? {
		let formattedKey = privatekey.trimmingCharacters(in: .whitespacesAndNewlines)
		guard let dataKey = Data.fromHex(formattedKey) else {
			return nil
		}
		guard let keystore = try EthereumKeystoreV3(privateKey: dataKey, password: password) else {
			return nil
		}
		let keyData = try JSONEncoder().encode(keystore.keystoreParams)

		guard let address = keystore.addresses?.first?.address else {
			return nil
		}
		let wallet = Wallet(address: address, data: keyData, name: name, mnemonics: nil, isHD: false)
		return wallet
	}
	
	
	// 从助记词导入
	func importWalletWithMnemonicsPhrase(_ mnemonics: String, name: String, password: String) throws -> Wallet? {
		let keystore = try BIP32Keystore(mnemonics: mnemonics,
																		 password: password,
																			 mnemonicsPassword: "",
																			 language: .english)

		guard let keystore else {
			return nil
		}
		let keyData = try JSONEncoder().encode(keystore.keystoreParams)

		guard let address = keystore.addresses?.first?.address else {
			return nil
		}
		let wallet = Wallet(address: address, data: keyData, name: name, mnemonics: mnemonics, isHD: true)
		return wallet
	}
}

public extension String {
	static var ethSuffix: String {
		return ".eth"
	}
	var wthETHSuffix:String {
		if self.hasSuffix(String.ethSuffix) {
			return self
		}
		return "\(self)\(String.ethSuffix)"
	}
	mutating func withoutETHSuffix() {
		if let range = self.range(of: String.ethSuffix) {
			self.removeSubrange(range)
		}
	}
	func aliasNickName() -> (str:String, hasNick:Bool) {
		guard let current = WalletManager.shared.currentWallet?.ethereumAddress?.address, current != self else {
			if let nick = WalletManager.shared.currentWalletOwnersNickname[self], !nick.isEmpty {
				return (nick, true)
			}
			return ("new_home_name_perospn_memememem".appLocalizable, true)
		}
		if let nick = WalletManager.shared.currentWalletOwnersNickname[self], !nick.isEmpty {
			return (nick,true)
		}
		return (self.etherAddressDisplay(),false)
	}
}
