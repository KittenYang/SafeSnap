//
//  ProposalDetailVoterView.swift
//  family-dao
//
//  Created by KittenYang on 12/4/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit


struct ProposalDetailVoterView: View {
	
	
	@Binding var proposal: SnapshotProposalInfo.SnapshotProposalInfoProposal
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("\("newPorinext_s_men".appLocalizable)\(Text(Image(systemName: "\(proposal.lazy_votes?.count ?? 0).circle.fill")))")
				.font(.rounded(size: 15.0, weight: .semibold))
				.padding(.bottom, 10.0)
			if let choices = proposal.choices, let votes = proposal.lazy_votes, votes.count > 0 {
				ForEach(votes, id: \.self) { vote in
					HStack {
						AvatarAndETHAddressView(ethAddress: vote.voter?.address)
							.layoutPriority(2)
						Spacer()
						if let choice = vote.choice, choice-1 < choices.count {
							Text("\(choices[choice-1])")
								.layoutPriority(2)
								.font(.rounded(size: 16.0,weight: .semibold))
							Spacer()
						}
						if let symbol = proposal.symbol ?? proposal.space?.symbol, let vp = vote.vp, vp > 0 {
							Text("\(vp)\(symbol)")
								.layoutPriority(1)
						}
//						if let reason = vote.reason {
//							Text(reason)
//						}
//						Spacer()
						if let time = vote.created?.timeAgo().str {
							Text(time)
								.font(.rounded(size: 14.0,weight: .regular))
								.foregroundColor(.label.opacity(0.6))
								.layoutPriority(0)
						}
					}
					.foregroundColor(.label)
					.lineLimit(1)
					.minimumScaleFactor(0.1)
				}
			}
		}
	}
	
	
}


struct ProposalDetailVoterView_Previews: PreviewProvider {
	static var previews: some View {
		ProposalDetailVoterView(proposal: .constant(.testProposal))
			.previewLayout(.fixed(width: 330, height: 80))
	}
}
