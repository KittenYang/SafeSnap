//
//  SafeTxHashInfo.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/6/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import HandyJSON
import web3swift
import BigInt

/*
 {
		 "safeAddress": "0x7860e1F21b84D17A364A6CCc653701a2cCc1Ba6b",
		 "txId": "multisig_0x7860e1F21b84D17A364A6CCc653701a2cCc1Ba6b_0xb5e9fe43295172e242a8d9b1ef313be8bbefda6a2aa62dc43bc2c9a5178c7d11",
		 "executedAt": null,
		 "txStatus": "AWAITING_CONFIRMATIONS",
		 "txInfo": {
				 "type": "Transfer",
				 "sender": {
						 "value": "0x7860e1F21b84D17A364A6CCc653701a2cCc1Ba6b"
				 },
				 "recipient": {
						 "value": "0x36A7784B4C97f77D32e754Df78183df9Ad8a7604"
				 },
				 "direction": "OUTGOING",
				 "transferInfo": {
						 "type": "ERC20",
						 "tokenAddress": "0x3f5faec54Be9beD1756D53818a2c4eaEf6827B56",
						 "tokenName": "Family-DAO-1",
						 "tokenSymbol": "FAMD1",
						 "logoUri": "https://safe-transaction-assets.gnosis-safe.io/tokens/logos/0x3f5faec54Be9beD1756D53818a2c4eaEf6827B56.png",
						 "decimals": 18,
						 "value": "21000000000000000000"
				 }
		 },
		 "txData": {
				 "hexData": "0xa9059cbb00000000000000000000000036a7784b4c97f77d32e754df78183df9ad8a7604000000000000000000000000000000000000000000000001236efcbcbb340000",
				 "dataDecoded": {
						 "method": "transfer",
						 "parameters": [
								 {
										 "name": "to",
										 "type": "address",
										 "value": "0x36A7784B4C97f77D32e754Df78183df9Ad8a7604"
								 },
								 {
										 "name": "value",
										 "type": "uint256",
										 "value": "21000000000000000000"
								 }
						 ]
				 },
				 "to": {
						 "value": "0x3f5faec54Be9beD1756D53818a2c4eaEf6827B56",
						 "name": "Family-DAO-1",
						 "logoUri": "https://safe-transaction-assets.gnosis-safe.io/tokens/logos/0x3f5faec54Be9beD1756D53818a2c4eaEf6827B56.png"
				 },
				 "value": "0",
				 "operation": 0
		 },
		 "detailedExecutionInfo": {
				 "type": "MULTISIG",
				 "submittedAt": 1659708582044,
				 "nonce": 2,
				 "safeTxGas": "0",
				 "baseGas": "0",
				 "gasPrice": "0",
				 "gasToken": "0x0000000000000000000000000000000000000000",
				 "refundReceiver": {
						 "value": "0x0000000000000000000000000000000000000000"
				 },
				 "safeTxHash": "0xb5e9fe43295172e242a8d9b1ef313be8bbefda6a2aa62dc43bc2c9a5178c7d11",
				 "executor": null,
				 "signers": [
						 {
								 "value": "0xab5eAE09AaEF48313fd8a030522A5D2b241df18c"
						 },
						 {
								 "value": "0x36A7784B4C97f77D32e754Df78183df9Ad8a7604"
						 }
				 ],
				 "confirmationsRequired": 2,
				 "confirmations": [
						 {
								 "signer": {
										 "value": "0x36A7784B4C97f77D32e754Df78183df9Ad8a7604"
								 },
								 "signature": "0x35b3bd4f27827d900eb7796cc436badeba69226a8a27e1cd9c33b3f491898c9b1a3348eaee85f5599691c51c9e5e2510082f9b0ed8b92447182e99e408e069ed1c",
								 "submittedAt": 1659708582082
						 }
				 ]
		 },
		 "txHash": null
 }
 */
public class SafeTxHashInfo: HandyJSON, Hashable, ObservableObject {
	
	public enum TXStatus: String, HandyJSONEnum {
		case waitingConfirm = "AWAITING_CONFIRMATIONS"
		case waitingYourConfirmation = "AWAITING_YOUR_CONFIRMATION"
		case waitingExecution = "AWAITING_EXECUTION"
		case cancelled = "CANCELLED"
		case failed = "FAILED"
		case success = "SUCCESS"
		/*
		 只是用来做 UI 显示，实际数据是 AWAITING_EXECUTION
		 */
		case submiting = "SUBMITTING"
		case pending = "PENDING"
		case pendingFailed = "PENDING_FAILED" //TODO: 这里要手动设置一下
	}

	public static func == (lhs: SafeTxHashInfo, rhs: SafeTxHashInfo) -> Bool {
		return lhs.txId == rhs.txId && lhs.safeAddress == rhs.safeAddress && lhs.txInfo == rhs.txInfo && lhs.detailedExecutionInfo == rhs.detailedExecutionInfo && lhs.txHash == rhs.txHash && lhs.executedAt == rhs.executedAt
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(txId)
		hasher.combine(safeAddress)
		hasher.combine(txStatus)
		hasher.combine(txInfo)
		hasher.combine(detailedExecutionInfo)
		hasher.combine(txHash)
		hasher.combine(executedAt)
	}
	
	public var txId: String?
	public var safeAddress: EthereumAddress?
	public var txStatus: TXStatus?
	public var txInfo: TxInfo?
	public var txData: TxData?
	public var detailedExecutionInfo: DetailedExecutionInfo?
	public var txHash: String?
	public var executedAt: Date?
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.safeAddress <-- EthereumAddressTransform()
		mapper <<<
			self.executedAt <-- YMDDateFormatTransform()
	}
	
	public class DetailedExecutionInfo: HandyJSON, Hashable {
		
		public enum DetailedExecutionInfoType: String, HandyJSONEnum {
			case multisig = "MULTISIG"
			case module = "MODULE"
		}
		
		public static func == (lhs: SafeTxHashInfo.DetailedExecutionInfo, rhs: SafeTxHashInfo.DetailedExecutionInfo) -> Bool {
			return lhs.type == rhs.type && lhs.submittedAt == rhs.submittedAt && lhs.nonce == rhs.nonce && lhs.signers == rhs.signers && lhs.rejectors == rhs.rejectors && lhs.confirmations == rhs.confirmations
		}

		public func hash(into hasher: inout Hasher) {
			hasher.combine(type)
			hasher.combine(submittedAt)
			hasher.combine(nonce)
			hasher.combine(signers)
			hasher.combine(rejectors)
			hasher.combine(confirmations)
		}
		
		public var type: DetailedExecutionInfoType?
		public var submittedAt: Date?
		public var nonce: UInt256?
		public var safeTxGas: UInt256?
		public var baseGas: UInt256?
		public var gasPrice: UInt256?
		public var gasToken: EthereumAddress?
		public var refundReceiver: String?
		public var safeTxHash: String?
		public var executor: String?
		public var signers: [EthereumAddress]?
		public var rejectors: [EthereumAddress]?
		public var missingSigners: [EthereumAddress]?
		public var confirmationsRequired: Int?
		public var confirmationsSubmitted: Int?
		public var confirmations: [Confirmations]?
		/*
		 module 才有
		 */
		public var address: String?

		public func mapping(mapper: HelpingMapper) {
			mapper <<<
						self.refundReceiver <-- "refundReceiver.value"
			mapper <<<
						self.executor <-- "executor.value"
			mapper <<<
						self.address <-- "address.value"
			mapper <<<
						self.gasToken <-- EthereumAddressTransform()
			mapper <<<
						self.nonce <-- UInt256Transform()
			mapper <<<
						self.safeTxGas <-- UInt256Transform()
			mapper <<<
						self.baseGas <-- UInt256Transform()
			mapper <<<
						self.gasPrice <-- UInt256Transform()
			mapper <<<
						self.submittedAt <-- YMDDateFormatTransform()
			mapper <<<
						self.signers <-- EthereumAddressArrayTransform()
			mapper <<<
						self.rejectors <-- EthereumAddressArrayTransform()
			mapper <<<
						self.missingSigners <-- EthereumAddressArrayTransform()
		}
		
		public class Confirmations: HandyJSON, Hashable,ObservableObject {
			public static func == (lhs: SafeTxHashInfo.DetailedExecutionInfo.Confirmations, rhs: SafeTxHashInfo.DetailedExecutionInfo.Confirmations) -> Bool {
				return lhs.signer == rhs.signer && lhs.signature == rhs.signature && lhs.submittedAt == rhs.submittedAt
			}
			
			public func hash(into hasher: inout Hasher) {
				hasher.combine(signer)
				hasher.combine(signature)
				hasher.combine(submittedAt)
			}

			public var signer: String?
			public var signature: String?
			public var submittedAt: Date?
			
			public func mapping(mapper: HelpingMapper) {
				mapper <<<
							self.signer <-- "signer.value"
				mapper <<<
					submittedAt <-- YMDDateFormatTransform()
			}
			required public init() {}
		}
		
		required public init() {}
	}
	required public init() {}
}

public class TxInfo: HandyJSON, Hashable {
	public struct AddressInfo: Decodable {
		public var value: EthereumAddress
		public var name: String?
		public var logoUri: URL?
	}
	
	public static func == (lhs: TxInfo, rhs: TxInfo) -> Bool {
		return lhs.type == rhs.type && lhs.sender?.value == rhs.sender?.value && lhs.recipient?.value == rhs.recipient?.value && lhs.direction == rhs.direction && lhs.dataDecoded == rhs.dataDecoded
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(type)
		hasher.combine(sender?.value)
		hasher.combine(recipient?.value)
		hasher.combine(direction)
		hasher.combine(dataDecoded)
	}
	
	public enum TxInfoType: String, HandyJSONEnum {
		// 交易（根据 direction: 转出 or 转入）
		case tranfer = "Transfer"
		// 创建钱包
		case creation = "Creation"
		// 拒绝 or custom
		case custom = "Custom"
		// 修改钱包配置
		case settingsChange = "SettingsChange"
	}
	
	public var isRejectionAction: Bool {
		if let isCancellation, isCancellation == true, type == .custom {
			return true
		} else {
			return false
		}
	}
	
	public enum TxInfoDirection: String, HandyJSONEnum {
		case outgoing = "OUTGOING"
		case incoming = "INCOMING"
		
		public var title: String {
			switch self {
			case .outgoing:
				return "new_home_name_perospn_oooooorrr".appLocalizable
			case .incoming:
				return "new_home_name_perospn_iniinnnin".appLocalizable
			}
		}
		
		public var symbol: String {
			switch self {
			case .outgoing:
				return "-"
			case .incoming:
				return "+"
			}
		}
		
		public var icon: UIImage? {
			switch self {
			case .outgoing:
				return UIImage(systemName: "arrowshape.turn.up.right.fill")
			case .incoming:
				return UIImage(systemName: "arrowshape.turn.up.left.fill")
			}
		}
	}

	public var type: TxInfoType?

	/*
	 Transfer 才有
	 */
	public var sender: AddressInfo?
	public var recipient: AddressInfo?
	public var direction: TxInfoDirection?
	//TODO: 现在 map 会失败
	public var transferInfo: TxTransferInfo?
	
	/*
	 Custom 才有
	 */
	public var to: AddressInfo?
	public var dataSize: String?
	public var value: String?
	public var methodName: String?
	public var actionCount: UInt256?
	public var isCancellation: Bool?
	/*
	 Creation 才有
	 */
	public var creator: AddressInfo?
	public var transactionHash: String?
	public var implementation: AddressInfo?
	public var factory: AddressInfo?
	/*
	 SettingsChange 才有
	 */
	public var dataDecoded: DataDecoded?
	public var settingsInfo: SettingsInfo?
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.to <-- DecodableTransform<AddressInfo>()
		mapper <<<
			self.sender <-- DecodableTransform<AddressInfo>()
		mapper <<<
			self.recipient <-- DecodableTransform<AddressInfo>()
		mapper <<<
			self.creator <-- DecodableTransform<AddressInfo>()
		mapper <<<
			self.implementation <-- DecodableTransform<AddressInfo>()
		mapper <<<
			self.factory <-- DecodableTransform<AddressInfo>()
		mapper <<<
			self.dataDecoded <-- DecodableTransform<DataDecoded>()
		mapper <<<
			self.settingsInfo <-- DecodableTransform<SettingsInfo>()
	}
	
	required public init() {}
	
	public struct DataDecoded: Decodable, Hashable {
		public static func == (lhs: TxInfo.DataDecoded, rhs: TxInfo.DataDecoded) -> Bool {
			return lhs.method == rhs.method
		}
		public func hash(into hasher: inout Hasher) {
			hasher.combine(method)
		}
		public var method: String
		public var parameters: [Parameter]?
		
		public struct Parameter: Decodable {
			public var name: String
			public var type: String
			public var value: Value
			public var valueDecoded: ValueDecoded?
			
			public enum Value: Decodable {
				case string(String)
				case address(EthereumAddress)
				case uint256(UInt256)
				case data(Data)
				case array([Value])
				case unknown
				
				public var string: String? {
					switch self {
					case .string(let str):
						return str
					case .address(let address):
						return address.address
					case .uint256(let uint):
						return uint.description
					case .array(_),.data(_),.unknown:
						return nil
					}
				}
				
				public init(from decoder: Decoder) throws {
					let container = try decoder.singleValueContainer()
					
					if let string = try? container.decode(String.self) {
						
						if string.hasPrefix("0x"), let address = try? container.decode(EthereumAddress.self) {
							self = .address(address)
						} else if string.hasPrefix("0x"), let data = try? container.decode(Data.self) {
							self = .data(data)
						} else if let uint256 = try? container.decode(UInt256.self) {
							self = .uint256(uint256)
						} else {
							self = .string(string)
						}
						
					} else if let array = try? container.decode([Value].self) {
						self = .array(array)
					} else {
						self = .unknown
					}
				}
			}
			
			public enum ValueDecoded: Decodable {
				case multiSend([MultiSendTx])
				case unknown
				
				public init(from decoder: Decoder) throws {
					let container = try decoder.singleValueContainer()
					if let multiSend = try? container.decode([MultiSendTx].self) {
						self = .multiSend(multiSend)
					} else {
						self = .unknown
					}
				}
				
				public struct MultiSendTx: Decodable {
					var operation: TxData.Operation
					var to: EthereumAddress
					var value: UInt256?
					var data: Data?
					var dataDecoded: DataDecoded?
				}
			}
		}
		
	}
	
	public enum SettingsInfo: Decodable {
		case setFallbackHandler(SetFallbackHandler)
		case addOwner(AddOwner)
		case removeOwner(RemoveOwner)
		case swapOwner(SwapOwner)
		case changeThreshold(ChangeThreshold)
		case changeImplementation(ChangeImplementation)
		case enableModule(EnableModule)
		case disableModule(DisableModule)
		case setGuard(SetGuard)
		case deleteGuard
		case unknown
		
		public init(from decoder: Decoder) throws {
			enum Keys: String, CodingKey { case type }
			let container = try decoder.container(keyedBy: Keys.self)
			let type = try container.decode(String.self, forKey: .type)
			
			switch type {
			case "SET_FALLBACK_HANDLER":
				self = try .setFallbackHandler(SetFallbackHandler(from: decoder))
			case "ADD_OWNER":
				self = try .addOwner(AddOwner(from: decoder))
			case "REMOVE_OWNER":
				self = try .removeOwner(RemoveOwner(from: decoder))
			case "SWAP_OWNER":
				self = try .swapOwner(SwapOwner(from: decoder))
			case "CHANGE_THRESHOLD":
				self = try .changeThreshold(ChangeThreshold(from: decoder))
			case "CHANGE_IMPLEMENTATION":
				self = try .changeImplementation(ChangeImplementation(from: decoder))
			case "ENABLE_MODULE":
				self = try .enableModule(EnableModule(from: decoder))
			case "DISABLE_MODULE":
				self = try .disableModule(DisableModule(from: decoder))
			case "SET_GUARD":
				self = try .setGuard(SetGuard(from: decoder))
			case "DELETE_GUARD":
				self = .deleteGuard
			default:
				self = .unknown
			}
		}
		
		public struct SetFallbackHandler: Decodable {
			var handler: AddressInfo
		}
		
		public struct AddOwner: Decodable {
			var owner: AddressInfo
			var threshold: UInt64
		}
		
		public struct RemoveOwner: Decodable {
			var owner: AddressInfo
			var threshold: UInt64
		}
		
		public struct SwapOwner: Decodable {
			var newOwner: AddressInfo
			var oldOwner: AddressInfo
		}
		
		public struct ChangeThreshold: Decodable {
			var threshold: UInt64
		}
		
		public struct ChangeImplementation: Decodable {
			var implementation: AddressInfo
		}
		
		public struct EnableModule: Decodable {
			var module: AddressInfo
		}
		
		public struct DisableModule: Decodable {
			var module: AddressInfo
		}
		
		public struct SetGuard: Decodable {
			var `guard`: AddressInfo
		}
	}
	
}

public class TxTransferInfo: HandyJSON {
	public var type: SafeBalance.SafeBalanceTokenInfo.TokenType?
	public var tokenAddress: String?
	public var tokenName: String?
	public var tokenSymbol: String?
	public var logoUri: String?
	public var decimals: Int?
	public var value: BigUInt?
	
	required public init() {}
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.value <-- BigUIntTransform()
	}
	
}

public class TxData: HandyJSON {
	public var hexData: String?
	public var dataDecoded: TxDataDataDecoded?
	public var to: To?
	public var value: String?
	public var operation: TxData.Operation?
	
	public enum Operation: Int, Codable, HandyJSONEnum {
		case call = 0
		case delegate = 1
		
		var data32: Data {
			UInt256(self.rawValue).data32
		}
		
		var uint256: UInt256 {
			UInt256(self.rawValue)
		}
		
		var name: String {
			switch self {
			case .call:
				return "call"
			case .delegate:
				return "delegateCall"
			}
		}
	}

	public class TxDataDataDecoded: HandyJSON {
		public var method: String?
		public var parameters: [[String:String]]?
		required public init() {}
	}
	
	public class To: HandyJSON {
		public var value: String?
		public var name: String?
		public var logoUri: String?
		
		required public init() {}
	}
	
	required public init() {}
}
