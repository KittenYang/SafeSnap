//
//  ProposalDetailInfomationView.swift
//  family-dao
//
//  Created by KittenYang on 12/3/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

struct ProposalDetailInfomationView: View {
	@Binding var proposal: SnapshotProposalInfo.SnapshotProposalInfoProposal

	typealias INFO = (left:String,right:String, handler:(()->Void)?)
	
	@ViewBuilder
	func infosView() -> some View {
		let infos:[INFO] = [
			("newPorinext_strategy".appLocalizable,proposal.strategies?.first?.name?.rawValue ?? "",nil),
			("IPFS",proposal.ipfs ?? "",nil),
			("newPorinext_ssdad".appLocalizable,proposal.type?.name ?? "",nil),
			("newPorinext_stasuitmtg".appLocalizable,proposal.start?.toYMDString() ?? "",nil),
			("faafasnewPasforinext_s".appLocalizable,proposal.end?.toYMDString() ?? "",nil),
			("sdasnewPordassdinext_s".appLocalizable,proposal.created?.toYMDString() ?? "",nil),
			("ccmkmznewPorinext_ssadas".appLocalizable,proposal.snapshot ?? "",nil)
		]
		VStack(alignment: .leading, spacing: 2.0) {
			ForEach(infos, id:\.left) { info in
				LeftAndRightView(leftText: info.left, rightText: info.right,rightAction:info.handler)
			}
		}
	}
	
    var body: some View {
		VStack(alignment: .leading) {
			Text("sdnffedfwggPorinext_s".appLocalizable)
				.font(.rounded(size: 15.0, weight: .semibold))
				.padding(.bottom, 10.0)
			infosView()
		}
    }
}

struct LeftAndRightView: View {
	
	var leftText: String
	var rightText: String
	var rightAction: (()->Void)?
	
	var body: some View {
		HStack {
			Text(leftText)
				.font(.rounded(size: 15.0,weight: .regular))
				.foregroundColor(.label.opacity(0.4))
			Spacer()
			Button {
				rightAction?()
			} label: {
				Text(rightText)
					.font(.rounded(size: 15.0,weight: .regular))
					.foregroundColor(.label.opacity(0.4))
					.lineLimit(1)
					.padding(.leading,60.0)
			}
			.buttonStyle(.plain)
		}
	}
}

struct ProposalDetailInfomationView_Previews: PreviewProvider {
    static var previews: some View {
		ProposalDetailInfomationView(proposal: .constant(.testProposal))
    }
}
