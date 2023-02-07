//
//  ProposalDetailVoteResultView.swift
//  family-dao
//
//  Created by KittenYang on 12/3/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

struct ProposalDetailVoteResultView: View {
	
	@Binding var proposal: SnapshotProposalInfo.SnapshotProposalInfoProposal
	
    var body: some View {
		VStack(alignment: .leading) {
			Text("\("newPorinext_sresult".appLocalizable)")
				.font(.rounded(size: 15.0, weight: .semibold))
				.padding(.bottom, 10.0)
			ForEach(proposal.votingResults, id: \.choice) { result in
				VStack(alignment: .leading, spacing: 9.0) {
					HStack {
						Text(result.choice)
							.font(.rounded(size: 15.0,weight: .medium))
							.foregroundColor(.label)
						Spacer()
						Text(result.score)
							.font(.rounded(size: 15.0,weight: .regular))
							.foregroundColor(.label.opacity(0.6))
							.padding(.trailing,12.0)
						Text("\(String(format: "%.1f", result.percent * 100))%")
							.font(.rounded(size: 17.0,weight: .semibold))
							.foregroundColor(.label)
					}
					GeometryReader { geo in
						let pdd = 10.0
						ZStack {
							Path { path in
								path.move(to: .zero)
								path.addLine(to: .init(x: geo.size.width-pdd, y: .zero))
							}
							.stroke(
								Color.appGray,
								style: StrokeStyle(lineWidth: pdd, lineCap: .round, lineJoin: .round)
							)
							if result.percent > 0 {
								Path { path in
									path.move(to: .zero)
									path.addLine(to: .init(x: (geo.size.width-pdd)*result.percent, y: .zero))
								}
								.stroke(
									Color.appBlue,
									style: StrokeStyle(lineWidth: pdd, lineCap: .round, lineJoin: .round)
								)
							}
						}
						.padding([.leading,.trailing],pdd/2)
					}
					.frame(height: 10.0)
				}
			}
		}
    }
}

struct ProposalDetailVoteResultView_Previews: PreviewProvider {
    static var previews: some View {
		ProposalDetailVoteResultView(proposal: .constant(.testProposal))
			.padding()
    }
}
