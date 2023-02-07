//
//  SnapshotManager+Vote.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift

extension SnapshotManager {

	/// 发布提案，发布一个新提案
	@discardableResult
	public static func voteAProposal(domain:String,
									 proposal:String,
									 choice:Int,
									 reason:String? = "") async -> CreateSnapshotAPIMsgResult? {
		
		guard let wallet = WalletManager.shared.currentWallet,
			  let account = wallet.ethereumAddress else {
			return nil
		}
		
		let address = account.address
		
		let message = EIP712TypedData.JSON.object([
			"space": .string(domain.wthETHSuffix.lowercased()),
			"proposal": .string(proposal),
			"choice": .number(.int(Int(choice))),
			"app": .string("snapshot"),
			"reason": .string(""),
			"from": .string(address),
			"timestamp": .number(.int(Int(Date().timeIntervalSince1970)))
		])
		let typedOBJ = EIP712TypedData(types: [
			"EIP712Domain":[
				.init(name: "name", type: "string"),
				.init(name: "version", type: "string")
			],
			"Vote":[
				.init(name: "from", type: "address"),
				.init(name: "space", type: "string"),
				.init(name: "timestamp", type: "uint64"),
				.init(name: "proposal", type: "bytes32"),
				.init(name: "choice", type: "uint32"),
				.init(name: "reason", type: "string"),
				.init(name: "app", type: "string")
		]], primaryType: "Vote", domain: .object(["name":.string("snapshot"),"version":.string("0.1.4")]), message: message)
		print("【post a new proposal typedOBJ】:\n\(typedOBJ)")
		
		if let signatureString = Web3Signer.signTypedMessage(typedData: typedOBJ, wallet: wallet) {
			print("9.投票")
			let result = await SnapshotManager.interactor.request(api: .sigTypedData(address: address, sig: signatureString, typedData: typedOBJ), mapTo: CreateSnapshotAPIMsgResult.self, queue: SnapshotManager.interactor.concurrentQueue)
			print("投票 结果：\(result?.toJSONString() ?? "nil")")
			return result
		}
		
		return nil
	}
	
	
	/// 查询某个用户对某个 proposal 的投票
	public static func getVotes(proposalID: String, space: String?, user: String?) async -> SnapshotVotesResult? {
		return await SnapshotManager.interactor.request(api: .getVoteOfProposal(proposalID: proposalID, first: 10, address: user, space:space), mapTo: SnapshotVotesResult.self, queue: SnapshotManager.interactor.concurrentQueue)
	}
	
}
