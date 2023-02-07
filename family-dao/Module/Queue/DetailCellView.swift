//
//  DetailCellView.swift
//  family-dao
//
//  Created by KittenYang on 8/29/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import GnosisSafeKit
import MultiSigKit
import SheetKit
import web3swift
import BigInt

struct DetailCellView: View {
	
	let interactor: NetworkAPIInteractor = NetworkAPIInteractor()

	var txHashInfo: SafeTxHashInfo? {
		self.result.queueDetail
	}

	@ObservedObject var result: SafeHistory.SafeHistoryResult
	
	var isNextNonce: Bool
	var transaction: SafeHistory.SafeHistoryResult.SafeHistoryResultTxn? {
		return result.transaction
	}

	@Environment(\.modalTransitionPercent) var animationPercent: CGFloat
	var shouldClose: Bool = false
	
	func getrecipient() -> [SafeTxHashInfo.DetailedExecutionInfo.Confirmations]? {
		if let recipient = txHashInfo?.txInfo?.recipient {
			let conf = SafeTxHashInfo.DetailedExecutionInfo.Confirmations()
			conf.signer = recipient.value.address
			return [conf]
		}
		return nil
	}
	
	func getBlankConfirmation() -> [SafeTxHashInfo.DetailedExecutionInfo.Confirmations] {
		let missingCount = result.transaction?.executionInfo?.missingSigners?.count ?? 0
		let conf = SafeTxHashInfo.DetailedExecutionInfo.Confirmations()
		conf.signer = EthereumAddress.ethZero.address
		return Array(repeating: conf, count: missingCount)
	}
	
	func getMissingSignersConfirmation() -> [SafeTxHashInfo.DetailedExecutionInfo.Confirmations] {
		guard let missingSigners = result.transaction?.executionInfo?.missingSigners, !missingSigners.isEmpty else {
			return []
		}
		return missingSigners.compactMap { add in
			let conf = SafeTxHashInfo.DetailedExecutionInfo.Confirmations()
			conf.signer = add.address
			return conf
		}
	}
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10.0) {
				QueueViewCell(result: result, isNextNonce: isNextNonce, shouldShowMissCount: false, shouldClose: shouldClose, shouldShowDisableButton: true/*, detailInfo: txHashInfo*/)
					.padding([.top,.bottom],15.0)
				dataDecodedView()
					.padding([.top,.bottom],10.0)
				VStack(alignment: .leading, spacing: 20.0) {
					if let txHashInfo = txHashInfo {
						if let re = getrecipient() {
							UserAvatarWithLineView(title: "fasfnew_hofasfafme_name_perospn_fsafsasfa_sdasn".appLocalizable, confirmations: re)
								.addZStackBKG(color: .secondarySystemBackground, alignment: .leading)
						}
						if let confirmations = txHashInfo.detailedExecutionInfo?.confirmations {
							UserAvatarWithLineView(title: "fasfnew_hofasfsfasfafme_name_pfserospfasfan".appLocalizable, confirmations: confirmations + getBlankConfirmation())
								.addZStackBKG(color: .secondarySystemBackground, alignment: .leading)
						}
						
						if let missingSigners = result.transaction?.executionInfo?.missingSigners, !missingSigners.isEmpty {
							UserAvatarWithLineView(title: "dasasf_fasfnew_hofasfafme_name_pe_dasdsrospn".appLocalizable, confirmations: getMissingSignersConfirmation())
								.addZStackBKG(color: .secondarySystemBackground, alignment: .leading)
						}
						
						HStack(alignment: .center) {
							Image(systemName: "megaphone")
							if let waitingSignerCounts =  transaction?.executionInfo?.waitingSignerCounts, waitingSignerCounts > 0 {
								Text("\("fasfnew_hofasfafme_name_perospndasfasf_dassf".appLocalizable) \(waitingSignerCounts) \("fasfnew_hofasfafme_name_perospndasfasf_dassf_lallal".appLocalizable)")
									.font(.rounded(size: 17.0))
//									.padding(EdgeInsets(top: 8.0, leading: 0.0, bottom: 5.0, trailing: 0.0))
							} else {
								Text("fasfnew_hofasfafme_name_perospn_norteyo_sadnas".appLocalizable)
									.font(.rounded(size: 17.0))
									.multilineTextAlignment(.leading)
							}
						}
						.foregroundColor(result.uiPattern.color)
						.padding(.top,10.0)
						
					} else {
						ProgressView()
							.padding()
					}
				}
//				.offset(x:25.0)
				Spacer()
			}
			.padding()
			.background(Color.appBkgColor)
		}
		.cornerRadius(8.0)
		.onAppear {
			if txHashInfo == nil {
				getSafeTxHashInfo()
			}
		}
	}
	
	@ViewBuilder
	private func dataDecodedView() -> some View {
		if let dataDecoded = self.result.queueDetail?.txData?.dataDecoded {
			VStack(alignment: .leading, spacing: 10.0) {
				if let method = dataDecoded.method?.uppercased() {
					Text(method)
						.font(.rounded(size: 17.0,weight: .bold))
				}
				if let params = dataDecoded.parameters {
					ForEach(params, id: \.self) { param in
						HStack {
							if let name = param["name"]?.uppercased() {
								Text(name)
									.font(.rounded(size: 14.0, weight: .medium))
									.frame(width: 50,alignment: .leading)
							}
							if let name = param["value"]?.ethereumAddress()?.address.aliasNickName().str {
								Text(name)
									.font(.rounded(size: 14.0, weight: .regular))
							} else if let amount = param["value"],
									  let bigint = BigUInt(amount) {
//								Text("\(bigint.SimplifiedString(decimals:WalletManager.currentFamilyTokenDecimals)) \(WalletManager.currentFamilyTokenSymbol)")
								Text(amount)
									.font(.rounded(size: 14.0, weight: .regular))
							}
						}
					}
				}
			}
			.addZStackBKG(color: .secondarySystemBackground, alignment: .leading)
		}
	}
}

extension DetailCellView {
	private func getSafeTxHashInfo() {
		guard let txHash = result.transaction?.id else {
			return
		}
		self.interactor.getSafeTxHashInfo(safeTxHash: txHash) { safeTxHashInfo, error in
			if let safeTxHashInfo {
				DispatchQueue.main.async {
					self.result.queueDetail = safeTxHashInfo
				}
			}
		}		
	}
}


struct DetailCell_Previews: PreviewProvider {
//	@Namespace private static var namespace
//	@State static var selected: SafeHistory.SafeHistoryResult? = SafeHistory.SafeHistoryResult()
	static var previews: some View {
		DetailCellView(result: SafeHistory.SafeHistoryResult(), isNextNonce: false)
//			.cornerRadius(8.0)
			.padding()
//			.background(Color.gray)
//			.previewLayout(.fixed(width: 300, height: 100))
	}
}


