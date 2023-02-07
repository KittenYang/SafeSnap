//
//  SnapshotManager+Proposal.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/15/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift
import HandyJSON

public protocol EnumName {
	var name: String { get }
}
public typealias EnumCategoryable = CaseIterable & EnumName

extension SnapshotManager {
	
	// 坑：enum 一定要集成自 HandyJSONEnum
	public enum VotingSystem:String, EnumCategoryable, HandyJSONEnum {
		
		//单选投票，每个投票人只能选择一个选项。
		/*
		 选项1（必填）
		 选项2（选填）
		 */
		case single_choice = "single-choice" //Each voter may select only one choice.
		//赞成投票，每个投票人可以选择任意数量的选项。
		case approval_voting = "approval"//Each voter may select any number of choices.
		//排序选择投票，每个选民都可以选择和排列任何数目的选择。结果是通过即时计算的。
		case ranked_choice_voting = "ranked-choice" //Each voter may select and rank any number of choices. Results are calculated by instant-runoff counting method.
		//二次投票,每个选民都可以在任何数量的选择中分配投票权。结果按四舍五入计算。
		case quadratic_voting = "quadratic"//Each voter may spread voting power across any number of choices. Results are calculated quadratically.
		//加权投票，每个选民都可以在任何选择中分散投票权。
		case weighted_voting = "weighted"//Each voter may spread voting power across any number of choices.
		//基本投票，有三种投票单选项：支持（1.For），反对（2.Against），和弃权（3.Abstain）
		case basic_voting = "basic"//Single choice voting with three choices: For, Against or Abstain
		case custom = "custom"
		
		public var name: String {
			switch self {
			case .single_choice:
				return "new_home_name_perospn_singkecgis".appLocalizable
			case .approval_voting:
				return "fassfanew_home_name_perospn_approavir".appLocalizable
			case .ranked_choice_voting:
				return "fdsafanew_hfasfome_nfasfame_pfaserospn".appLocalizable
			case .quadratic_voting:
				return "hnjhnew_jhghjome_name_perospn".appLocalizable
			case .weighted_voting:
				return "fafnefwas_home_fasnfamfeas_perospn".appLocalizable
			case .basic_voting:
				return "new_home_name_perospn_basisciniopda".appLocalizable
			case .custom:
				return "fasfnew_fashomfase_name_fafsperospn".appLocalizable
			}
		}
		
		public var minOptions:Int {
			switch self {
			case .single_choice,.approval_voting,.ranked_choice_voting,.quadratic_voting,.weighted_voting,.basic_voting:
				return 1
			case .custom:
				return 0
			}
		}
		
	}
	
	/// 发布提案，发布一个新提案
	@discardableResult
	public static func postAnewProposal(domain:String,
										system:SnapshotManager.VotingSystem = .single_choice,
										title:String,
										body:String,
										discussion:String = "",
										choices:[String],
										start:Date = Date(),
										end:Date? = nil) async -> CreateSnapshotAPIMsgResult? {
		
		guard let wallet = WalletManager.shared.currentWallet,
			  let account = wallet.ethereumAddress,
			  let currentChain = WalletManager.shared.currentFamily,
			  let blockNumber = try? ChainManager.global.currentWeb3provider(currentChain.chain)?.eth.getBlockNumber() else {
			return nil
		}
		
		let address = account.address
		let end_date = end ?? start.addingTimeInterval(TimeInterval(3*24*60*60))//默认3天
		let message = EIP712TypedData.JSON.object([
			"from": .string(address),
			"space": .string(domain.lowercased()),
			"timestamp": .number(.int(Int(Date().timeIntervalSince1970))),
			"type": .string(system.rawValue),
			"title": .string(title),
			"body": .string(body),
			"discussion": .string(discussion),
			"choices": .array(choices.compactMap({ .string($0) })),
			"start": .number(.int(Int(start.timeIntervalSince1970))),
			"end": .number(.int(Int(end_date.timeIntervalSince1970))),
			"snapshot": .number(.int(Int(blockNumber))),
			"plugins": .string("{}"),
			"app": .string("snapshot")
		])
		let typedOBJ = EIP712TypedData(types: [
			"EIP712Domain":[
				.init(name: "name", type: "string"),
				.init(name: "version", type: "string")
			],
			"Proposal":[
				.init(name: "from", type: "address"),
				.init(name: "space", type: "string"),
				.init(name: "timestamp", type: "uint64"),
				.init(name: "type", type: "string"),
				.init(name: "title", type: "string"),
				.init(name: "body", type: "string"),
				.init(name: "discussion", type: "string"),
				.init(name: "choices", type: "string[]"),
				.init(name: "start", type: "uint64"),
				.init(name: "end", type: "uint64"),
				.init(name: "snapshot", type: "uint64"),
				.init(name: "plugins", type: "string"),
				.init(name: "app", type: "string")
		]], primaryType: "Proposal", domain: .object(["name":.string("snapshot"),"version":.string("0.1.4")]), message: message)
		print("【post a new proposal typedOBJ】:\n\(typedOBJ)")
		
		if let signatureString = Web3Signer.signTypedMessage(typedData: typedOBJ, wallet: wallet) {

			print("8. 发布一个提案")
			let result = await SnapshotManager.interactor.request(api: .sigTypedData(address: address, sig: signatureString, typedData: typedOBJ), mapTo: CreateSnapshotAPIMsgResult.self, queue: SnapshotManager.interactor.concurrentQueue)
			print("发布提案 结果：\(result?.toJSONString() ?? "nil")")
			return result
		}
		
		return nil
	}
	
	/// 获取一个提案的内容
	public static func checkProposalInfo(pid: String) async -> SnapshotProposalInfo? {
		return await SnapshotManager.interactor.request(api: .getProposalInfo(id: pid), mapTo: SnapshotProposalInfo.self, queue: SnapshotManager.interactor.concurrentQueue)
	}
	
	/// 查询某个space 前 n 条提案
	public static func getAllProposalOfSpace(domain:String, first:Int, skip: Int) async -> SnapshotProposals? {
		let proposals = await SnapshotManager.interactor.request(api: .getSpaceAllProposal(domain: domain, first: first, skip: skip), mapTo: SnapshotProposals.self, queue: SnapshotManager.interactor.concurrentQueue)
		return proposals
	}
	
	/// 查询某个 space 前 n 条活跃/关闭的提案
	public static func getAllStateProposalOfSpace(domain: String, first: Int, skip: Int, state: SnapshotProposalInfo.ProposalState, startDate: Date?, authors_in:[String]?) async -> SnapshotProposals? {
		return await NetworkAPIInteractor().request(api: .getSpaceStateProposal(domain: domain, first: first, skip: skip, state: state, startDate: startDate, authors_in: authors_in), mapTo: SnapshotProposals.self, queue: SnapshotManager.interactor.concurrentQueue)
	}
	
	/// 查询某个用户是否有足够多的 score 投票
	public static func getScoreOfSpaceByUser(domain:String, api_method: String, address: String, strategy: SnapshotSpaceInfo.SnapshotSpaceInfoDetail.SnapshotSpaceInfoDetailStrategy, blockNumber:String) async -> SnapshotScoreResult? {
		return await SnapshotManager.interactor.request(api: .getScore(domain:domain, api_method: api_method, address: address, strategy: strategy, blockNumber: blockNumber), mapTo: SnapshotScoreResult.self, queue: interactor.concurrentQueue)
	}
	
}

