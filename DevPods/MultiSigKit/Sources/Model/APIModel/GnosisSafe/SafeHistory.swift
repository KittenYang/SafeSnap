//
//  SafeHistory.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/7/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import HandyJSON
import web3swift

/*
 {
		 "next": null,
		 "previous": null,
		 "results": [
				 {
						 "type": "LABEL",
						 "label": "Next"
				 },
				 {
						 "type": "TRANSACTION",
						 "transaction": {
								 "id": "multisig_0x7860e1F21b84D17A364A6CCc653701a2cCc1Ba6b_0x1d104d710b9fb0c811d869cae50eb3ab25db04860f7c27bf4499cdf638386c66",
								 "timestamp": 1659447863836,
								 "txStatus": "AWAITING_CONFIRMATIONS",
								 "txInfo": {
										 "type": "Transfer",
										 "sender": {
												 "value": "0x7860e1F21b84D17A364A6CCc653701a2cCc1Ba6b"
										 },
										 "recipient": {
												 "value": "0xab5eAE09AaEF48313fd8a030522A5D2b241df18c"
										 },
										 "direction": "OUTGOING",
										 "transferInfo": {
												 "type": "ERC20",
												 "tokenAddress": "0x3f5faec54Be9beD1756D53818a2c4eaEf6827B56",
												 "tokenName": "Family-DAO-1",
												 "tokenSymbol": "FAMD1",
												 "logoUri": "https://safe-transaction-assets.gnosis-safe.io/tokens/logos/0x3f5faec54Be9beD1756D53818a2c4eaEf6827B56.png",
												 "decimals": 18,
												 "value": "100000000000000000000"
										 }
								 },
								 "executionInfo": {
										 "type": "MULTISIG",
										 "nonce": 0,
										 "confirmationsRequired": 2,
										 "confirmationsSubmitted": 1,
										 "missingSigners": [
												 {
														 "value": "0xab5eAE09AaEF48313fd8a030522A5D2b241df18c"
												 }
										 ]
								 }
						 },
						 "conflictType": "None"
				 },
				 {
						 "type": "LABEL",
						 "label": "Queued"
				 },
				 {
						 "type": "TRANSACTION",
						 "transaction": {
								 "id": "multisig_0x7860e1F21b84D17A364A6CCc653701a2cCc1Ba6b_0x2b0a518749b24b8b7b015cf2cde6243c3edff0887942130e8371e3db8d6cbc4d",
								 "timestamp": 1659637040646,
								 "txStatus": "AWAITING_CONFIRMATIONS",
								 "txInfo": {
										 "type": "Transfer",
										 "sender": {
												 "value": "0x7860e1F21b84D17A364A6CCc653701a2cCc1Ba6b"
										 },
										 "recipient": {
												 "value": "0xab5eAE09AaEF48313fd8a030522A5D2b241df18c"
										 },
										 "direction": "OUTGOING",
										 "transferInfo": {
												 "type": "ERC20",
												 "tokenAddress": "0x3f5faec54Be9beD1756D53818a2c4eaEf6827B56",
												 "tokenName": "Family-DAO-1",
												 "tokenSymbol": "FAMD1",
												 "logoUri": "https://safe-transaction-assets.gnosis-safe.io/tokens/logos/0x3f5faec54Be9beD1756D53818a2c4eaEf6827B56.png",
												 "decimals": 18,
												 "value": "36000000000000000000"
										 }
								 },
								 "executionInfo": {
										 "type": "MULTISIG",
										 "nonce": 1,
										 "confirmationsRequired": 2,
										 "confirmationsSubmitted": 1,
										 "missingSigners": [
												 {
														 "value": "0xab5eAE09AaEF48313fd8a030522A5D2b241df18c"
												 }
										 ]
								 }
						 },
						 "conflictType": "None"
				 },
				 {
						 "type": "TRANSACTION",
						 "transaction": {
								 "id": "multisig_0x7860e1F21b84D17A364A6CCc653701a2cCc1Ba6b_0xb5e9fe43295172e242a8d9b1ef313be8bbefda6a2aa62dc43bc2c9a5178c7d11",
								 "timestamp": 1659708582044,
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
								 "executionInfo": {
										 "type": "MULTISIG",
										 "nonce": 2,
										 "confirmationsRequired": 2,
										 "confirmationsSubmitted": 1,
										 "missingSigners": [
												 {
														 "value": "0xab5eAE09AaEF48313fd8a030522A5D2b241df18c"
												 }
										 ]
								 }
						 },
						 "conflictType": "None"
				 }
		 ]
 }
 */
public class SafeHistory: HandyJSON {
	public var next: String?
	
	/*
	 上拉刷新加载更多才会有的参数
	 https://safe-client.safe.global/v1/chains/5/safes/0xE37670f8c186E763545a1E1d5EfDAE745127d0E4/transactions/queued?cursor=limit%3D20%26offset%3D0&timezone_offset=0&trusted=true"
	 */
	public var previous: URL?
	public var results: [SafeHistoryResult]?

	public class SafeHistoryResult: HandyJSON, Hashable, ObservableObject, Identifiable {
		public static func == (lhs: SafeHistory.SafeHistoryResult, rhs: SafeHistory.SafeHistoryResult) -> Bool {
			return lhs.label == rhs.label
			&& lhs.transaction == rhs.transaction
			&& lhs.conflictType == rhs.conflictType
			&& lhs.type == rhs.type
			&& lhs.nonce == rhs.nonce
			&& lhs.timestamp == rhs.timestamp
			&& lhs.queueDetail == rhs.queueDetail
		}
		
		public func hash(into hasher: inout Hasher) {
//			hasher.combine(queueDetail)
			hasher.combine(label)
			hasher.combine(transaction)
			hasher.combine(conflictType)
			hasher.combine(type)
			hasher.combine(nonce)
			hasher.combine(timestamp)
			hasher.combine(queueDetail)
		}
		
		public enum SafeHistoryResultType: String, HandyJSONEnum {
			case label = "LABEL"
			case dataLebel = "DATE_LABEL"
			case transaction = "TRANSACTION"
			case conflictheader = "CONFLICT_HEADER"
		}
		public var type: SafeHistoryResultType?
		public var label: LabelType?
		public var transaction: SafeHistoryResultTxn?
		public var conflictType: ConflictType?
		public var nonce: Int?
		public var timestamp: Date?

		// 注入，提前获取详情
		@Published public var queueDetail: SafeTxHashInfo? {
			didSet {
				self.timestamp = queueDetail?.executedAt // 这一步让 result 的 hashable 改动，从而触发该 cell 的重渲
			}
		}
		
		public var canShowCell: Bool {
			return type == .transaction
			&& transaction != nil
			&& conflictType != nil //排除是一个header
		}
		
		public func mapping(mapper: HelpingMapper) {
			mapper <<<
				self.timestamp <-- YMDDateFormatTransform()
		}

		public enum LabelType: String, Hashable, HandyJSONEnum {
			case next = "Next"
			case queued = "Queued"
		}
		
		public enum ConflictType: String, HandyJSONEnum {
			case none = "None"
			case next = "HasNext"
			case end = "End"
		}
		
		public class SafeHistoryResultTxn: HandyJSON, Hashable {
			public static func == (lhs: SafeHistory.SafeHistoryResult.SafeHistoryResultTxn, rhs: SafeHistory.SafeHistoryResult.SafeHistoryResultTxn) -> Bool {
				return lhs.id == rhs.id
								&& lhs.timestamp == rhs.timestamp
								&& lhs.txStatus == rhs.txStatus
								&& lhs.txInfo == rhs.txInfo
								&& lhs.executionInfo == rhs.executionInfo
			}
			
			public func hash(into hasher: inout Hasher) {
				hasher.combine(id)
				hasher.combine(timestamp)
				hasher.combine(txStatus)
				hasher.combine(txInfo)
				hasher.combine(executionInfo)
			}
			
//			public func canExecu() -> Bool {
//				return self.txStatus == .waitingExecution || (self.executionInfo?.canExecu() ?? false)
//			}
			
			public var id: String?
			public var timestamp: Date?
//			@Published
			public var txStatus: SafeTxHashInfo.TXStatus?
			public var txInfo: TxInfo?
			public var executionInfo:SafeTxHashInfo.DetailedExecutionInfo?
			
			public func mapping(mapper: HelpingMapper) {
				mapper <<<
					self.timestamp <-- YMDDateFormatTransform()
			}
			required public init() {}
		}
		required public init() {}
	}
	required public init() {}
}

/*
 {
		"next": [["发送"]],
		"queue": [["发送"],["发送","拒绝"]]
 }
 */
public typealias HistoryResults = [SafeHistory.SafeHistoryResult]
public typealias LabelValue = [HistoryResults]
public typealias FixedSafeHistory = [SafeHistory.SafeHistoryResult.LabelType:LabelValue]

extension HistoryResults: Identifiable {
	public var id: String {
		return self.compactMap({ $0.transaction?.id }).joined()
	}
}

public func ==(lhs: FixedSafeHistory, rhs: FixedSafeHistory) -> Bool {
	let key1 = lhs.keys.first
	let key2 = rhs.keys.first
	if let key1, let key2 {
		if key1 != key2 {
			return false
		}
		let value1 = lhs[key1]
		let value2 = rhs[key2]
		return value1 == value2
	}
	return false
}

//public typealias TwoObservableArray = ObservableArray<ObservableArray<SafeHistory.SafeHistoryResult>>
//public typealias FixedSafeHistory = [SafeHistory.SafeHistoryResult.LabelType : TwoObservableArray]

public class FixedSafeHistoryObject: ObservableObject, Hashable, Equatable {
	public static func == (lhs: FixedSafeHistoryObject, rhs: FixedSafeHistoryObject) -> Bool {
		return lhs.storage == rhs.storage
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(storage)
	}
	
	@Published public var storage: FixedSafeHistory
//	{
//		objectWillChange
//	}
	
	public init() {
		self.storage = .init()
	}
	
	public init(_ storage: FixedSafeHistory) {
		self.storage = storage
	}
	
}
