//
//  ProposalDetailView.swift
//  family-dao
//
//  Created by KittenYang on 12/3/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

struct ProposalDetailView: View {
	
	// 巨坑大坑：这里不知道为啥只保留 fromProposal，无法修改 fromProposal 的值，必须多一个 @State 的变量才能正确刷新。展示保留两个变量吧，修改当前页面的同时也能修改之前列表里的数据.
	@Binding var fromProposal: SnapshotProposalInfo.SnapshotProposalInfoProposal
	@State var proposal: SnapshotProposalInfo.SnapshotProposalInfoProposal
	
	@Environment(\.currentFamily) var currentFamily: Family?
	
	init(fromProposal: Binding<SnapshotProposalInfo.SnapshotProposalInfoProposal>) {
		self._fromProposal = fromProposal
		self.proposal = fromProposal.wrappedValue
	}
	
	@State var loading: Bool = true
	
    var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				HStack {
					Spacer()
					Text("newPorinext_s".appLocalizable)
						.font(.rounded(size: 22.0))
						.padding(.bottom, 20)
					Spacer()
				}
				ProposalDetailTopView(proposal: $proposal)
				
				Divider()
					.padding([.top,.bottom], 20)
				
				if !proposal.isEnded {
					// 投出你的票
					ProposalDetailVotingView(proposal: $proposal)
					Divider()
						.padding([.top,.bottom], 20)
				}
				
				// 投票人
				if let voted = proposal.lazy_votes, voted.count > 0 {
					ProposalDetailVoterView(proposal: $proposal)
						.transition(.blur)
						.animation(.easeInOut(duration: 0.3), value: proposal.lazy_votes)
					
					Divider()
						.padding([.top,.bottom], 20)
				} else if loading {
					HStack {
						Spacer()
						ActivityIndicatorView(style: .medium)
						Spacer()
					}
					//1.transition动画必须
					.transition(.blur)
					//2.transition动画必须
					.animation(.easeInOut(duration: 0.3), value: loading)
					
					Divider()
						.padding([.top,.bottom], 20)
				}
				
				// 提案信息
				ProposalDetailInfomationView(proposal: $proposal)
				
				Divider()
					.padding([.top,.bottom], 20)
				
				// 投票结果
				ProposalDetailVoteResultView(proposal: $proposal)
			}
//			.id(proposal)
//			.transition(.blur)
//			.animation(.easeOut, value: proposal)
			.padding()
		}
//		.id(proposal)
//		.animation(.easeInOut(duration: 0.3), value: proposal)
		.onAppear {
			if let pid = proposal.pid {
				Task {
					// 刷新整体数据
					if let new = await SnapshotManager.checkProposalInfo(pid: pid)?.proposal {
						debugPrint(new.toJSONString() ?? "nil")
							// 请求当前用户对当前投票的vote
							if let lazy_votes = await SnapshotManager.getVotes(proposalID: pid, space: currentFamily?.spaceDomain, user: nil)?.votes {
								new.lazy_votes = lazy_votes
							}
						withAnimation { //3.transition动画必须
							self.loading = false
							self.proposal = new
						}
						self.fromProposal = new
					}
				}
			}
		}
    }
}

struct ProposalDetailView_Previews: PreviewProvider {
    static var previews: some View {
//		ProposalDetailView(proposal:.testProposal)
		ProposalDetailView(fromProposal:.constant(.testProposal))
    }
}
