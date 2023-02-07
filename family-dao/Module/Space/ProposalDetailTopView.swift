//
//  ProposalDetailTopView.swift
//  family-dao
//
//  Created by KittenYang on 12/3/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

struct ProposalDetailTopView: View {
	
	@Binding var proposal: SnapshotProposalInfo.SnapshotProposalInfoProposal
	
    var body: some View {
		VStack(alignment: .leading) {
			HStack(alignment:.top,spacing: 2.0) {
				VStack(alignment:.leading,spacing: 0.0) {
					Text(proposal.title ?? "")
						.font(.rounded(size: 20.0,weight: .semibold))
						.lineLimit(1)
					AvatarAndETHAddressView(ethAddress: proposal.author)
						.padding(.top,8.0)
				}
				Spacer()
				SolidColorButton(text: proposal.state?.cnName ?? "", bkgColor: proposal.stateColor)
			}.padding(.bottom, 16)
			Text(proposal.body ?? "")
				.foregroundColor(.label.opacity(0.7))
				.font(.rounded(size: 15.0, weight: .regular))
		}
    }
}

struct ProposalDetailTopView_Previews: PreviewProvider {
    static var previews: some View {
		ProposalDetailTopView(proposal: .constant(SnapshotProposalInfo.SnapshotProposalInfoProposal.testProposal))
			.previewLayout(.fixed(width: 387, height: 170))
			.padding()
    }
}
