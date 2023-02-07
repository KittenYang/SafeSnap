//
//  ChainManager.swift
//  family-dao
//
//  Created by KittenYang on 7/30/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift

public class ChainManager {
	
	public static var global = ChainManager()
	
	// 默认绑定的是当前登录用户钱包
	public func web3() -> web3? {
		guard let chain = WalletManager.shared.currentFamily?.chain else {
			return nil
		}
		return self.currentWeb3provider(chain)
	}
	
	public func currentWeb3provider(_ chain: Chain.ChainID) -> web3? {
		var pro: web3
		switch chain {
		case .ethereumMainnet:
			pro = Chain.ChainID.web3provider_mainnet
		case .ethereumGoerli:
			pro = Chain.ChainID.web3provider_goerli
		default:
			pro = Chain.ChainID.web3provider_mainnet
//		case .ethereumMainnet:
//			pro = Chain.ChainID.web3provider_mainnet
//		case .ethereumRinkeby:
//			pro = Chain.ChainID.web3provider_rinkeby
//		case .ethereumRopsten:
//			pro = Chain.ChainID.web3provider_ropsten
//		case .ethereumKovan:
//			pro = Chain.ChainID.web3provider_kovan
//		case .ethereumGoerli:
//			pro = Chain.ChainID.web3provider_goerli
//		default:
//			pro = Chain.ChainID.web3provider_mainnet
		}
		return pro
	}

	// 默认绑定的是当前登录用户钱包
	public func currentGodWalletWeb3provider(_ chain: Chain.ChainID) -> web3? {
		var pro: web3
		switch chain {
		case .ethereumMainnet:
			pro = Web3.InfuraMainnetWeb3(accessToken: Constant.InfuraToken)
		case .ethereumGoerli:
			pro = Web3.InfuraGoerliWeb3(accessToken: Constant.InfuraToken)
		default:
			pro = Chain.ChainID.web3provider_mainnet
//		case .ethereumMainnet:
//			pro = Web3.InfuraMainnetWeb3(accessToken: Constant.InfuraToken)
//		case .ethereumRinkeby:
//			pro = Web3.InfuraRinkebyWeb3(accessToken: Constant.InfuraToken)
//		case .ethereumRopsten:
//			pro = Web3.InfuraRopstenWeb3(accessToken: Constant.InfuraToken)
//		case .ethereumKovan:
//			pro = Web3.InfuraKovanWeb3(accessToken: Constant.InfuraToken)
//		case .ethereumGoerli:
//			pro = Web3.InfuraGoerliWeb3(accessToken: Constant.InfuraToken)
//		default:
//			pro = Web3.InfuraMainnetWeb3(accessToken: Constant.InfuraToken)
		}
		if var godWallet = WalletManager.shared.godWallet {
			pro.addKeystoreManager(godWallet.keystoreManager)
		}
		return pro
	}

	
	public func erc20(chain: Chain.ChainID, tokenAddress: web3swift.EthereumAddress?) -> ERC20? {
		guard let pro = self.currentWeb3provider(chain), let tokenAddress else {
			return nil
		}
		return ERC20(web3: pro, provider: pro.provider, address: tokenAddress)
	}
	
	public func erc721(chain: Chain.ChainID, tokenAddress: web3swift.EthereumAddress?) -> ERC721? {
		guard let pro = self.currentWeb3provider(chain), let tokenAddress else {
			return nil
		}
		return ERC721(web3: pro, provider: pro.provider, address: tokenAddress)
	}
	
	private init() {
		print("ChainManager init")
//		updateWeb3Provider()
	}
	
	public static var currentChain: Chain.ChainID {
		return WalletManager.shared.currentFamilyChain
	}
	
	// 切换家庭要更新这里
//	private func updateWeb3Provider() {
//		var pro: web3
//		switch ChainManager.currentChain {
//		case .ethereumMainnet:
//			pro = Chain.ChainID.web3provider_mainnet
//		case .ethereumRinkeby:
//			pro = Chain.ChainID.web3provider_rinkeby
//		case .ethereumRopsten:
//			pro = Chain.ChainID.web3provider_ropsten
//		case .ethereumKovan:
//			pro = Chain.ChainID.web3provider_kovan
//		case .ethereumGoerli:
//			pro = Chain.ChainID.web3provider_goerli
//		default:
//			pro = Chain.ChainID.web3provider_mainnet
//		}
//		self.currentWeb3provider = pro
//	}
	
}

//MARK: private method
extension ChainManager {
	
}
