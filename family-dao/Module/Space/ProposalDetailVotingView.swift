//
//  ProposalDetailVotingView.swift
//  family-dao
//
//  Created by KittenYang on 12/3/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

struct ProposalDetailVotingView: View {
	
	@Binding var proposal: SnapshotProposalInfo.SnapshotProposalInfoProposal
	
	@State var currentSelection: String?
	
	@State var reason: String?
	
    var body: some View {
		VStack(alignment: .leading) {
			Text("next_s_voteee".appLocalizable)
				.font(.rounded(size: 15.0, weight: .semibold))
				.padding(.bottom, 10.0)
			ForEach(proposal.choices ?? [], id: \.self) { choice in
				Button {
					currentSelection = choice
				} label: {
					RoundedRectangle(cornerRadius: 24.0)
						.foregroundColor(currentSelection == choice ? .appGreen : .black.opacity(0.1))
						.frame(height: 48.0)
						.overlay {
							Text(choice)
								.font(.rounded(size: 18.0, weight: .medium))
								.foregroundColor(currentSelection == choice ? .white : .label)
						}
				}
			}
			TextField("next_s_reson".appLocalizable, text: $reason)
				.padding()
				.background(Color.secondarySystemBackground)
				.cornerRadius(12.0)
			Button {
				vote()
			} label: {
				RoundedRectangle(cornerRadius: 24.0)
					.foregroundColor(currentSelection != nil ? .appRed : .appRed.opacity(0.3))
					.frame(height: 48.0)
					.overlay {
						Text("newPorinext_s_voteee".appLocalizable)
							.font(.rounded(size: 18.0, weight: .medium))
							.foregroundColor(.white)
					}
			}
			.disabled(currentSelection == nil)
		}
		.onAppear {
			if currentSelection == nil {
				if let choices = proposal.choices,
					let existSelection = proposal.lazy_votes?.first(where: { ele in
						return ele.voter?.address == WalletManager.shared.currentWallet?.address
					})?.choice,
					existSelection > 0,
					existSelection-1 < choices.count {
					currentSelection = choices[existSelection-1]
				}
			}
		}
    }
	
	private func vote() {
		guard let currentUser = WalletManager.shared.currentWallet?.address,
			  let strategy = proposal.strategies?.first,
			  let bn = proposal.snapshot,
			  let domain = WalletManager.shared.currentFamily?.spaceDomain,
			  let pid = proposal.pid,
			  let currentSelection,
			  let index = proposal.choices?.firstIndex(where: { $0 == currentSelection }) else {
			return
		}
	
		Task {
			//SnapshotVotesResultDetail
			// check 是否有足够多的 power
			await AppHUD.show("newPorinext_sing".appLocalizable,loading:true)
			let res = await SnapshotManager.getScoreOfSpaceByUser(domain:domain, api_method: "get_vp", address: currentUser, strategy: strategy, blockNumber: bn)
			guard let vp = res?.result?.vp, vp != 0 else {
				await AppHUD.dismissAll()
				await AppHUD.show("newPorinext_sorry".appLocalizable)
				return
			}
			let voteRes = await SnapshotManager.voteAProposal(domain: domain, proposal: pid, choice: index + 1/*注意这里要加1*/, reason: self.reason)
			if voteRes?.isValid ?? false {
				proposal.votes = (proposal.votes ?? 0) + 1
				await SheetManager.dismissAllSheets()
				await AppHUD.dismissAll()
				await AppHUD.show("newPorinext_success".appLocalizable)
			}
		}
	}
}

struct ProposalDetailVotingView_Previews: PreviewProvider {
    static var previews: some View {
		ProposalDetailVotingView(proposal: .constant(.testProposal))
    }
}
