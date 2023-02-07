//
//  TransactionModel.swift
//  family-dao
//
//  Created by KittenYang on 8/3/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift
import BigInt
import GnosisSafeKit

// Transaction domain model based on https://docs.gnosis.io/safe/docs/contracts_tx_execution/#transaction-hash
public struct SignTransaction: Codable {
	public var safe: EthereumAddress

	public var chainId: String = WalletManager.shared.currentFamilyChain.rawValue
	
	// required by a smart contract
	public let to: EthereumAddress // 这个可以是 erc20 token 地址
	public let value: BigUInt

	public let data: Data // data 里面包含钱转到目标地址的信息

	public var operation: TxData.Operation = .call
	// can be modified for WalletConnect transactions
	public var safeTxGas: UInt256 = 0
	public var baseGas: UInt256 = 0
	public var gasPrice: UInt256 = 0
	public var gasToken: EthereumAddress = .ethZero
	// zero address if no refund receiver is set
	public var refundReceiver: EthereumAddress
	// can be modified for WalletConnect transactions
	public var nonce: UInt256
	
	// computed based on other properties
	public var transactionHash: HashString?
	
//	public init(safe: EthereumAddress, to: EthereumAddress, tokenAddress: EthereumAddress, value: BigUInt, nonce: UInt256) {
//		if tokenAddress == .zero {
//			// 转移 ETH，to 就是接受对象，data 为空
//			self.to = to
//			self.data = Data()
//		} else {
//			// 转移自定义货币，自定义货币 to 是货币address, 接受对象是包在 data 里面的
//			self.to = tokenAddress
//			self.data = ERC20.transfer(
//				to: Sol.Address(stringLiteral: to.address),
//				value: Sol.UInt256(value)
//			).encode()
//		}
//		self.safe = safe
//		self.value = value
//		self.nonce = nonce
//	}
	
	public init?(tx: SafeTxHashInfo) {
		guard let txData = tx.txData,
					let _safe = tx.safeAddress,
					let _to = txData.to?.value?.ethereumAddress(),
					let _value = txData.value?.convertToBigUInt(),
					let multiSigTxInfo = tx.detailedExecutionInfo,
					let _nonce = multiSigTxInfo.nonce else {
				return nil
		}
		safe = _safe
		to = _to
		value = _value
		data = txData.hexData?.toHexData() ?? .init()
		operation = txData.operation ?? .call
		
		safeTxGas = multiSigTxInfo.safeTxGas ?? 0
		baseGas = multiSigTxInfo.baseGas ?? 0
		gasPrice = multiSigTxInfo.gasPrice ?? 0
		gasToken = multiSigTxInfo.gasToken ?? .ethZero
		refundReceiver = multiSigTxInfo.refundReceiver?.ethereumAddress() ?? .ethZero
		nonce = _nonce
		safeTxHash = multiSigTxInfo.safeTxHash
	}
	
	public init(safe: EthereumAddress,
							chainId: String = WalletManager.shared.currentFamilyChain.rawValue,
							to: EthereumAddress,
							tokenAddress: EthereumAddress,
							value: BigUInt,
							data: Data? = nil,
							operation: TxData.Operation = .call,
							safeTxGas: UInt256 = 0,
							baseGas: UInt256 = 0,
							gasPrice: UInt256 = 0,
							gasToken: EthereumAddress = .zero,
							refundReceiver: EthereumAddress = .zero,
							nonce: UInt256) {
		if tokenAddress == .zero {
			// 转移 ETH，to 就是接受对象(reject 是钱包地址)，data 为空
			// 或者是 changeSettings
			self.to = to
			self.data = data ?? Data()
			self.value = value
		} else {
			// 转移自定义货币，自定义货币 to 是货币address, 接受对象是包在 data 里面的
			self.to = tokenAddress
			self.data = data ?? ERC20.transfer(
				to: Sol.Address(stringLiteral: to.address),
				value: Sol.UInt256(value)
			).encode()
			self.value = BigUInt(0)
		}
		
		self.safe = safe
		self.chainId = chainId
		self.operation = operation
		self.safeTxGas = safeTxGas
		self.baseGas = baseGas
		self.gasPrice = gasPrice
		self.gasToken = gasToken
		self.refundReceiver = refundReceiver
		self.nonce = nonce
		updateSafeTxHash()
	}
	
	// 1
	private var safeEncodedTxData: Data {
		[
			Constant.DefaultEIP712SafeAppTxTypeHash,
			to.data32,
			value.data32,
			EthHasher.hash(data),
			operation.data32,
			safeTxGas.data32,
			baseGas.data32,
			gasPrice.data32,
			gasToken.data32,
			refundReceiver.data32,
			nonce.data32
		].reduce(Data()) { $0 + $1 }
	}
	
	// hash(1) = data
	public var encodeTransactionData: Data {
		let ERC191MagicByte = Data([0x19])
		let ERC191Version1Byte = Data([0x01])
		return [
			ERC191MagicByte,
			ERC191Version1Byte,
			EthHasher.hash(Constant.domainData(for: safe, chainId: chainId)),
			EthHasher.hash(safeEncodedTxData)
		].reduce(Data()) { $0 + $1 }
	}
	
	// hash(data).toHexString
	public var safeTxHash: String?
	
	// hash(data).toHexStringPrefix
	public lazy var safeTxHashWithPrefix: String = {
		let data = encodeTransactionData
		return EthHasher.hash(data).toHexStringWithPrefix()
	}()
	
	// sign(Data(hash(data).toHexString))
	public lazy var signature: Data? = {
		guard var wallet = WalletManager.shared.currentWallet,
					let account = wallet.ethereumAddress else { return nil }
		let data = encodeTransactionData
		var sig: Data? = nil
		do {
			
			let hashToSign = Data(ethHex: safeTxHashWithPrefix)
			guard EthHasher.hash(data) == hashToSign else {
					return nil
			}
			
			let waitingToSignData = Data(hex: EthHasher.hash(data).toHexString())
			sig = try Web3Signer.signPersonalMessage2(waitingToSignData, keystore: wallet.keystore, account: account, password: WalletManager.currentPwd, useExtraEntropy: false)
		} catch let err_sig {
			debugPrint("❌签名错误:\(err_sig)")
		}
		return sig
	}()
	
	public lazy var signatureString: String? = {
		guard let sig = signature else { return nil }
		return sig.toHexString()
	}()
	
	mutating func updateSafeTxHash() {
			safeTxHash = safeTransactionHash()
	}
	
	private func safeTransactionHash() -> String {
		let data = encodeTransactionData
		return EthHasher.hash(data).toHexString()
	}
	
}

//extension SignTransaction {
//	static func rejectionTransaction(safeAddress: EthereumAddress,
//																	 nonce: UInt256,
//																	 chainId: String) -> SignTransaction {
//
//		SignTransaction(safe: <#T##EthereumAddress#>, to: <#T##EthereumAddress#>, tokenAddress: <#T##EthereumAddress#>, value: <#T##BigUInt#>, nonce: <#T##UInt256#>)
//			var transaction = Transaction(to: EthereumAddress(safeAddress),
//																		value: "0",
//																		data: "0x",
//																		operation: SCGModels.Operation.call,
//																		safeTxGas: "0",
//																		baseGas: "0",
//																		gasPrice: "0",
//																		gasToken: "0x0000000000000000000000000000000000000000",
//																		refundReceiver: "0x0000000000000000000000000000000000000000",
//																		nonce: nonce,
//																		safeTxHash: nil)
//			transaction.safe = AddressString(safeAddress)
//			transaction.safeVersion = safeVersion
//			transaction.chainId = chainId
//
//			transaction.safeTxHash = transaction.safeTransactionHash()
//
//			return transaction
//	}
//}
