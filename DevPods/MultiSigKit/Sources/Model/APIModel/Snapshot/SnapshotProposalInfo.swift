//
//  SnapshotSpaceInfo.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/8/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import HandyJSON
import web3swift

public class SnapshotProposals: HandyJSON, Hashable {
	public static func == (lhs: SnapshotProposals, rhs: SnapshotProposals) -> Bool {
		return lhs.proposals == rhs.proposals
	}
	public func hash(into hasher: inout Hasher) {
		hasher.combine(proposals)
	}
	public var proposals: [SnapshotProposalInfo.SnapshotProposalInfoProposal]?
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.proposals <-- "data.proposals"
	}
	
	required public init() {}
}

public class SnapshotProposalInfo: HandyJSON {
	
	public var proposal: SnapshotProposalInfoProposal?
	
	public enum ProposalState:String, HandyJSONEnum {
		public var cnName: String {
			switch self {
			case .active:
				return "new_home_name_perospn_lasss".appLocalizable
			case .closed:
				return "new_home_name_perospn_dadasdsad".appLocalizable
			case .all:
				return "new_home_name_perospn_alllll".appLocalizable
			}
		}
		
		case active
		case closed
		case all
		
	}
	
	public enum ScoresState:String, HandyJSONEnum {
		case pending
	}
	
	public class SnapshotProposalInfoProposal: HandyJSON, CustomDebugStringConvertible, Hashable, Identifiable {
		
		// 坑：这里的 hashable 一定要实现，不然同一个 proposal 更新之后 view 不会刷新
		public static func == (lhs: SnapshotProposalInfo.SnapshotProposalInfoProposal, rhs: SnapshotProposalInfo.SnapshotProposalInfoProposal) -> Bool {
			return lhs.id == rhs.id && lhs.ipfs == rhs.ipfs && lhs.title == rhs.title && lhs.choices == rhs.choices && lhs.snapshot == rhs.snapshot && lhs.scores == rhs.scores && lhs.lazy_votes == rhs.lazy_votes && lhs.votes == rhs.votes && lhs.created == rhs.created && lhs.end == rhs.end
		}
		
		public func hash(into hasher: inout Hasher) {
			hasher.combine(id)
			hasher.combine(ipfs)
			hasher.combine(title)
			hasher.combine(choices)
			hasher.combine(snapshot)
			hasher.combine(scores)
			hasher.combine(lazy_votes)
			hasher.combine(votes)
			hasher.combine(created)
			hasher.combine(end)
		}
		
		public var id: String {
			let lazy_votes_str = lazy_votes?.compactMap({ $0.id }).joined() ?? ""
			return "\(pid ?? "")_\(ipfs ?? "")_\(choices?.joined() ?? "")_\(title ?? "")_\(votes ?? 0)_\(lazy_votes_str)"
		}
		
		public var isEnded: Bool {
			guard let end else {
				return true
			}
			return Date() > end
		}
		
		public var isVoted:Bool {
			return (votes ?? 0) > 0
		}
		
		public typealias VotingResult = (choice:String,score:String,percent:Double)
		public var votingResults: [VotingResult] {
			var results = [VotingResult]()
			let choices = self.choices ?? []
			for index in 0..<choices.count {
				let choice = choices[index]
				var score = 0//scores?[index] ?? 0
				if let scores, index < scores.count {
					score = scores[index]
				}
				var percent: Double = 0.0
				if let scores_total, !Double(scores_total).isZero {
					percent = Double(score) / Double(scores_total)
				}
				results.append((choice, "\(score) \(symbol ?? space?.symbol ?? "")", percent))
			}
			return results
		}
		
		public var pid: String?
		public var ipfs: String?
		public var title: String?
		public var body: String?
		public var discussion: String?
		
		public var choices:[String]?
		
		public var start:Date?
		public var end:Date?
		
		public var snapshot:String? //blockNumber
		
		public var state: ProposalState?
		
		public var author: String?
		public var created: Date?
		public var plugins: [String:Any]?
		public var network: Chain.ChainID?
		public var type: SnapshotManager.VotingSystem?
		public var quorum: Int?
		public var symbol: String?
		
		public var strategies: [SnapshotSpaceInfo.SnapshotSpaceInfoDetail.SnapshotSpaceInfoDetailStrategy]?
		
		public var space: SnapshotSpaceInfo.SnapshotSpaceInfoDetail?
		public var scores_state:ScoresState?
		public var scores:[Int]?
		public var scores_by_strategy: [[Int]]?
		public var scores_total: Int?
		public var votes: Int?
		
		public var lazy_votes: [SnapshotVotesResultDetail]?
		
		required public init() {}
		
		public func mapping(mapper: HelpingMapper) {
			mapper <<<
				self.pid <-- "id"
			mapper <<<
				self.start <-- DateTransform()
			mapper <<<
				self.end <-- DateTransform()
			mapper <<<
				self.created <-- DateTransform()
		}
		
		public var debugDescription: String {
			return title ?? ""
		}
	}
	
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.proposal <-- "data.proposal"
	}
	
	required public init() {}
	
}
