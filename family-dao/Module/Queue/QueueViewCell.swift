//
//  QueueViewCell.swift
//  family-dao
//
//  Created by KittenYang on 8/27/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//

import SwiftUI
import MultiSigKit
import BigInt
import GnosisSafeKit
import SwiftUIX

public extension SafeHistory.SafeHistoryResult {
	
	var noConflict: Bool {
		return conflictType ==  SafeHistory.SafeHistoryResult.ConflictType.none
	}
	
	var executionInfo: SafeTxHashInfo.DetailedExecutionInfo? {
		queueDetail?.detailedExecutionInfo ?? transaction?.executionInfo
	}
	
	var isReject: Bool {
		return transaction?.isReject ?? false
	}
	
	var uiPattern: (icon:UIImage?,color:Color?) {
		return transaction?.uiPattern ?? (nil,nil)
	}
}

struct QueueViewCell: View {
	
	@Environment(\.currentQueueType) var queue: BindingLoadable<FixedSafeHistoryObject>

	@ObservedObject var result: SafeHistory.SafeHistoryResult {
		didSet {
			self.mainStatus = result.transaction?.txStatus
		}
	}
	//如果是下一笔，可以执行；其他交易不可执行
	var isNextNonce: Bool
	
	@State private var mainStatus: SafeTxHashInfo.TXStatus?

	@StateObject var walletManager = WalletManager.shared
	
	let interactor: NetworkAPIInteractor = NetworkAPIInteractor()
	
	// 显示还剩几个名额
	var shouldShowMissCount: Bool = true
	
	// 点击还剩几个名额是否触发按钮操作
	var shouldClose: Bool = true
	
	/// 是否显示已经完成的操作（detail 页面需要显示半透明按钮，一级页面为了整洁不需要显示）
	var shouldShowDisableButton: Bool = false

	private var showsRejectButton: Bool {
		guard let queueDetail = result.queueDetail else {
			return false
		}
		if result.isReject {
			return false
		} else {
			guard let multisigInfo = queueDetail.detailedExecutionInfo,
				  let status = queueDetail.txStatus, multisigInfo.canSign else {
				return false
			}
			
			if (status == .waitingExecution || status == .pendingFailed) && !multisigInfo.isRejected() {
				return true
			} else if status.isAwatingConfiramtions {
				return true
			}
			
			return false
		}
	}

	private var showsConfirmButton: Bool {
		guard let queueDetail = result.queueDetail else {
			return false
		}
		if result.isReject {
			if queueDetail.txStatus?.isAwatingConfiramtions ?? false,
			   let multisigInfo = queueDetail.detailedExecutionInfo, multisigInfo.canSign {
				return true
			}
			return false
		} else {
			return queueDetail.txStatus?.isAwatingConfiramtions ?? false
		}
	}
	
	private var showsExecuteButton: Bool {
		guard let queueDetail = result.queueDetail else {
			return false
		}
		guard let _ = WalletManager.shared.currentFamily else { return false }
//		只有最前面的 nonce 才能执行
//		guard let nonce = safe.nonce, nonce == tx?.multisigInfo?.nonce.value else {
//			return false
//		}
//		guard let tx = transaction else {
//			return false
//		}
		let result = isNextNonce && queueDetail.needsYourExecution()
		return result
	}
	
	private var enableRejectionButton: Bool {
		guard let queueDetail = result.queueDetail else {
			return false
		}
		if let executionInfo = queueDetail.detailedExecutionInfo, !executionInfo.isRejected(), showsRejectButton {
			return true
		}
		return false
	}
	
	private var enableConfirmButton: Bool {
		result.queueDetail?.needsYourConfirmation ?? false
	}
	
	var body: some View {
		VStack {
			HStack(alignment: .top) {
				if let uiPattern = result.uiPattern, let icon = uiPattern.icon {
					Image(uiImage: icon)
						.renderingMode(.template)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 20.0, height: 16.0)
						.scaledToFit()
						.foregroundColor(uiPattern.color)
				}
				VStack(alignment: .leading, spacing: 5.0) {
					sendText()
					toRecipientText()
					Group {
						if let n = result.executionInfo?.nonce, let i = Int(n) {
							Text("No.\(i)")
						}
						HStack {
							Image(systemName: "person.3.fill")
								.resizable()
								.frame(width: 19.0, height: 10.0)
							Text("\(result.executionInfo?.confirmations?.count ?? result.executionInfo?.confirmationsSubmitted ?? 0)/\(result.executionInfo?.confirmationsRequired ?? 0) \("newPorinext_s_voteee".appLocalizable) \(result.isReject ? "fasfnew_hofasfafme_name_perosp_kuieoccen".appLocalizable : "done".appLocalizable)")
						}
						if let time = result.transaction?.timestamp?.toYMDString() {
							Text(time)
						}
					}
					.font(.rounded(size: 13.0))
					.foregroundColor(.appGrayMiddle)
					
					if shouldShowMissCount {
						Button {
							debugPrint("展开...")
							SheetManager.showSheetWithContent {
								DetailCellView(result: result, isNextNonce: isNextNonce)
							}
							//						withAnimation(.easeInOut(duration: 0.3)) {
							//							selectedResult = result
							//						}
						} label: {
							HStack(alignment: .center) {
								if let waitingSignerCounts = result.executionInfo?.waitingSignerCounts, waitingSignerCounts > 0 {
									Text("\("fasfnew_hofasfafme_name_perospndasfasf_dassf".appLocalizable) \(waitingSignerCounts) \("fasfnew_hofasfafme_name_perospndasfasf_dassf_lallal".appLocalizable)")
										.font(.rounded(size: 14.0))
										.padding(EdgeInsets(top: 8.0, leading: 0.0, bottom: 5.0, trailing: 0.0))
								} else {
									Text("fasfnew_hofasfafme_name_perospn_norteyo_sadnas".appLocalizable)
										.font(.rounded(size: 14.0))
										.multilineTextAlignment(.leading)
								}
								if shouldClose {
									Image(systemName: "chevron.right.circle.fill")
										.resizable()
										.frame(width: 15.0, height: 15.0)
								}
							}
							.foregroundColor(result.uiPattern.color)
						}
						.disabled(!shouldClose)
						.buttonStyle(BorderlessButtonStyle())
					}
				}
				Spacer()
				VStack {
					if result.queueDetail == nil || mainStatus == .submiting {
						ActivityIndicatorView(style: .medium)
							.frame(width: 15.0, height: 15.0)
							.padding()
					}
					if showsConfirmButton && (enableConfirmButton || shouldShowDisableButton) && mainStatus != .submiting {
						Button {
							Task {
								await agreeOrVote()
							}
						} label: {
							Text(result.noConflict ? "fasfnew_hofasfafme_name_perospnvovyeee".appLocalizable : "fasfnew_hofasfafme_name_perospn_fasfsfsa_vssaf".appLocalizable)
								.font(.rounded(size: 15.0))
								.foregroundColor(.white)
						}
						.addBKG(color: enableConfirmButton ? (result.isReject ? .appRed : .appBlue) : .appGrayMiddle)
						.disabled(!enableConfirmButton)
						.buttonStyle(BorderlessButtonStyle())
					}
					if showsExecuteButton && mainStatus != .submiting {
						Button {
							Task {
								await agreeOrVote()
							}
						} label: {
							Text("ffasfas_link_fasasfnew_hofasfafme_name_perospn".appLocalizable)
								.font(.rounded(size: 15.0))
								.foregroundColor(.white)
								.addBKG(color: result.isReject ? .appRed : .appBlue)
						}
						.buttonStyle(BorderlessButtonStyle())
					}
					if showsRejectButton && (enableRejectionButton || shouldShowDisableButton) && mainStatus != .submiting {
						Button {
							Task {
								await reject()
							}
						} label: {
							Text("fasfnew_hofasfafme_name_perosp_kuieoccen".appLocalizable)
								.font(.rounded(size: 15.0))
								.foregroundColor(.white)
						}
						.addBKG(color: enableRejectionButton ? .appRed : .appGrayMiddle)
						.disabled(!enableRejectionButton)
						.buttonStyle(PlainButtonStyle())
					}
				}
				.show(isVisible: $walletManager.isMyFamily)
			}
		}
		.id(result)
		.onAppear {
			if result.queueDetail == nil {
				getSafeTxHashInfo()
			}
		}
	}
	
	private func sendText() -> some View {
		if result.isReject {
			return Text("fasfnew_hofasfafme_name_peros_nonnonnopn".appLocalizable)
				.foregroundColor(.appRed)
				.font(.rounded(size: 16.0))
		} else {
			var hello = AttributedString("fasfnew_hofasfafme_name_perosfasfasff_fasmuespn".appLocalizable)
			var world_str: String?
			switch result.transaction?.txInfo?.type {
			case .creation:
				hello = AttributedString("ffaasfn_fasfsa_asfsaew_hofasfafme_name_perospn".appLocalizable)
			case .custom:
				hello = AttributedString("fafsasffnasf_fasf_fasew_hofasfafme_name_perospn".appLocalizable)
				world_str = result.transaction?.txInfo?.methodName
			case .settingsChange:
				hello = AttributedString("fdafasfnew_hofa_dassfsfsfaffasfme_name_perfasfsaospn".appLocalizable)
				world_str = result.transaction?.txInfo?.dataDecoded?.method
			case .tranfer:
				let prefix = result.transaction?.txInfo?.direction?.title ?? "fasfnew_hofasfafme_name_perospn_fasfass_fasfs_s".appLocalizable
				hello = AttributedString(prefix)
			default:
				break
			}
			hello += AttributedString(" ")// 间隔
			hello.foregroundColor = result.uiPattern.color //.label
			hello.font = Font.rounded(size: 16.0)
			
			var world: AttributedString?
			if let world_str {
				world = AttributedString(world_str)
			} else if let amount = result.transaction?.txInfo?.transferInfo?.value?.SimplifiedString(),
					  let symbol = result.transaction?.txInfo?.transferInfo?.tokenSymbol {
				let prefix = result.transaction?.txInfo?.direction?.symbol ?? ""
				world = AttributedString("\(prefix)\(amount) \(symbol)")
			}
			
			world?.font = Font.rounded(size: 16.0).bold()
			world?.foregroundColor = Color.appGreen
			
			if let world {
				hello += world
			}
			
			return Text(hello)
		}
	}
	
	@ViewBuilder
	private func toRecipientText() -> some View {
		switch result.transaction?.txInfo?.type {
		case .tranfer:
			if let address = result.transaction?.txInfo?.recipient?.value.address {
				let nickName = address.nickNameAttributedString()
				HStack(alignment: .top, spacing: 0.0) {
					Text("fasfnew_hofasfafme_name_perospnfasf_tototo".appLocalizable)
						.font(.rounded(size: 12.0))
						.foregroundColor(.label)
					Text(nickName)
						.fontWeight(.medium)
				}.longPressGestureIfNeeded(true) {
					let pasteboard = UIPasteboard.general
					pasteboard.string = address
					AppHUD.show("copy_suss".appLocalizable)
				}
			}
		case .settingsChange:
			if let value = result.transaction?.txInfo?.dataDecoded?.parameters?.first?.value {
//				var toLabel = AttributedString("变更值： ", attributes: .init([.font:Font.rounded(size: 11.0), .foregroundColor: Color.label])) // 坑：这么写 AttributedString 会导致切换家庭的时候崩溃：SwiftUI/ListHeaderFooterCellSupport.swift:85: Fatal error: PlatformListViewBase has no ViewGraph!
				if let vStr = value.string {
					HStack(alignment: .top, spacing:0.0) {
						Text("settingsChange_value_change_txt".appLocalizable)
							.font(.rounded(size: 12.0))
							.foregroundColor(.label)
						Text(vStr)
							.font(.rounded(size: 13.0, weight: .medium))
							.foregroundColor(.label)
					}.longPressGestureIfNeeded(true) {
						let pasteboard = UIPasteboard.general
						pasteboard.string = vStr
						AppHUD.show("copy_suss".appLocalizable)
					}
				} else {
					EmptyView()
				}
			}
		case .custom:
			if let value = result.transaction?.txInfo?.to?.value.address {
				let valueStr =
				HStack(alignment: .top, spacing:0.0) {
					Text("fasfnew_hofasfafme_name_perospn_fasfasqwkdas".appLocalizable)
						.font(.rounded(size: 12.0))
						.foregroundColor(.label)
					Text(value)
						.font(.rounded(size: 13.0, weight: .medium))
						.foregroundColor(.label)
				}.longPressGestureIfNeeded(true) {
					let pasteboard = UIPasteboard.general
					pasteboard.string = value
					AppHUD.show("copy_suss".appLocalizable)
				}
			}
			
		default:
			EmptyView()
		}
		
//		EmptyView()
	}
		
	/*
	 包括同意和投票
	 */
	private func agreeOrVote() async {
		guard let queueDetail = result.queueDetail else {
			return
		}
		if await FaceID() {
			let previousStatus = result.transaction?.txStatus
			if showsExecuteButton {
				mainStatus = .submiting
				self.interactor.execuAction(txHashInfo: queueDetail) {  status in
					DispatchQueue.main.async {
						AppHUD.show(status.desc)
						if status == .done {
							mainStatus = .success
							var ss = queue.wrappedValue.value?.storage
							ss?.removeValue(forKey: .next)
							if let ss {
								queue.wrappedValue = .loaded(FixedSafeHistoryObject(ss))
							}
							// TODO: 直接移除数据更新
							self.walletManager.shouldReloadQueue.toggle()
							self.walletManager.reloadChart.toggle()
						} else if status == .failed {
							mainStatus = previousStatus
						} else if case .errorOccur(_) = status {
							mainStatus = previousStatus
						}
					}
				}
			} else {
				mainStatus = .submiting
				self.interactor.confirmations(safeTxHashInfo: queueDetail) {  txHashInfo, error in
					DispatchQueue.main.async {
						if let txHashInfo {
							mainStatus = .success
							withAnimation {
								self.result.queueDetail = txHashInfo
								self.walletManager.shouldReloadQueue.toggle()
							}
							debugPrint("\("fafasfs_kkkeelsfnew_hofasfafme_name_perospn".appLocalizable)\(txHashInfo)")
						} else if let error {
							mainStatus = previousStatus
							AppHUD.show(error.message)
						}
					}
				}
			}
		}
	}
	
	private func reject() async {
		guard let nonce = result.executionInfo?.nonce else {
			return
		}
		if await FaceID() {
			let previousStatus = result.transaction?.txStatus
			mainStatus = .submiting
			Task {
				let result = await self.interactor.proposeRejectAction(nonce: nonce, errorHandler: { err in
					DispatchQueue.main.async {
						self.mainStatus = previousStatus
					}
				})
				await MainActor.run {
					if let txHashInfo = result.0 {
						mainStatus = .success
						withAnimation {
							self.result.queueDetail = txHashInfo
							self.walletManager.shouldReloadQueue.toggle()
						}
						debugPrint("拒绝结果:\(txHashInfo)")
					}
				}
			}
		}
	}

}

extension QueueViewCell {
	private func getSafeTxHashInfo() {
		guard walletManager.isMyFamily else {
			return
		}
		guard let txHash = result.transaction?.id else {
			self.mainStatus = .success
			return
		}
		self.interactor.getSafeTxHashInfo(safeTxHash: txHash) { safeTxHashInfo, error in
			DispatchQueue.main.async {
				if let safeTxHashInfo {
					self.result.queueDetail = safeTxHashInfo
				} else {
					self.mainStatus = .success
				}
			}
		}
	}
}

struct QueueViewCell_Previews: PreviewProvider {
	static var previews: some View {
		QueueViewCell(result: SafeHistory.SafeHistoryResult(), isNextNonce: false)
			.previewLayout(.fixed(width: 300, height: 200))
	}
}

