//
//  ProposalListView.swift
//  family-dao
//
//  Created by KittenYang on 11/27/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import web3swift
import struct LonginusSwiftUI.LGImage

struct ProposalListView: View {
	
	init() {
		UITableView.appearance().sectionFooterHeight = 0
		UITableView.appearance().sectionHeaderHeight = 0
	}
	
	@FetchRequest(fetchRequest: Family.fetchRequest().selected()) var currentFamily: FetchedResults<Family>
//	@Environment(\.currentFamily) var currentFamily: Family?
	
	@EnvironmentObject var walletManager: WalletManager
	
	@State var queue: Loadable<SnapshotProposals> = .notRequested
	
    var body: some View {
		AppInsetGroupedList(list: list(), retryAction: {force in
			await getProposalQueues(skip: nil, limit: 10, force)
		}, queue: $queue)
		.environment(\.currentProposalListType, $queue)
    }
	
	private func getDuration(_ proposal: SnapshotProposalInfo.SnapshotProposalInfoProposal) -> String? {
		var duration: String?
		if let end = proposal.end, let start = proposal.start, let d = start.distance(to: end).friendString {
			duration = "\("cccccnext_s".appLocalizable)\(d)"
		}
		return duration
	}
	
	@ViewBuilder
	func sectionheader(_ proposal: SnapshotProposalInfo.SnapshotProposalInfoProposal, index:Int) -> some View {
		if let blockNumber = proposal.start?.timeAgo() {
			Text("\("beginnext_s".appLocalizable)\(blockNumber.str)   |   \(getDuration(proposal) ?? "")")
				.font(.rounded(size: 12.0))
				.listRowInsets(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
		}
	}
	
	@State var loading: Loading = .noMore
	
	@ViewBuilder
	func list() -> some View {
		GeometryReader { proxy in
			List {
				ForEach(enumerating: queue.value?.proposals ?? []) { index,proposal in
					Section(header:sectionheader(proposal, index: index)) {
						ProposalCell(proposal: .init(get: {
							return proposal
						}, set: { newP in
							self.queue.value?.proposals?[index] = newP
						}))
							.padding([.top,.bottom],8.0)
							.contentShape(Rectangle())
							.onTapGesture {
								SheetManager.showSheetWithContent(heightFactor: 0.9) {
									ProposalDetailView(fromProposal: .constant(proposal))
										.id(proposal)
								}
							}
					}
					.listRowBackground(Color.appBkgColor)
				}
				
				if (queue.value?.proposals?.count ?? 0) > 0 {
					LoadMoreView(loadingState: $loading, proxy: proxy, runLoadingAction: {
						Task {
							await self.loadMore()
						}
					})
					.id(loading)
				}
			}
			//			.id(proposals) // 坑：必须有这句，不然列表不会刷新
//			.id(queue)
			.modifier(DynamicTopCurrentFamilyModifer(listOffsetPercent: .constant(0.0)))
//			.modifier(TopCurrentFamilyModifer(offsetPercent: .constant(0.0)))
			.listRowInsets(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
			//		.background(.ultraThinMaterial)
			//		.scrollContentBackground(.hidden)
			.listStyle(InsetGroupedListStyle())
		}
		.transition(.blur)
		.animation(.easeInOut(duration: 0.3), value: queue.value?.proposals)
	}
	
	func canLoadMore() -> Bool {
		return getCurrentCount() >= 0
	}
	
	private func loadMore() async  {
		var limit = 10
#if DEBUG
		limit = 2
#endif
		let new = await self.getMore(limit: limit)
		if canLoadMore() && (getCountBy(his: new) >= limit) {
			self.loading = .waitingMore
		} else {
			self.loading = .noMore
		}
	}
	
	func getCurrentCount() -> Int {
		return getCountBy(his: self.queue.value)
	}
	
	func getMore(limit:Int) async -> SnapshotProposals?  {
		let skip = getCurrentCount()
		guard skip >= 0 else {
			return nil
		}

		return await getProposalQueues(skip: skip, limit: limit, false)
	}
	
	func getCountBy(his: SnapshotProposals?) -> Int {
		guard let ps = his?.proposals else {
			return 0
		}
		return ps.count
	}
	
	@discardableResult
	private func getProposalQueues(skip:Int?,limit:Int?,_ force: Bool) async -> SnapshotProposals? {
		// 如果已经有数据了，不需要再次loading
		if case .loaded(_) = self.queue, !force {
		} else {
			let cancelBag = CancelBag()
			queue.setIsLoading(cancelBag: cancelBag)
		}
		
		guard let domain = currentFamily.first?.spaceDomain else {
			queue = .failed(nil)
			return nil
		}
//#if DEBUG
//		domain = "karate-combat-stage"
//#endif
		var isRequestMore: Bool = false
		if let _ = skip {
			isRequestMore = true
		}

		if let proposals = await SnapshotManager.getAllStateProposalOfSpace(domain: domain, first: limit ?? 10, skip: skip ?? 0, state: .all, startDate: nil, authors_in: []) {
			if isRequestMore {
				withAnimation {
					self.queue.value?.proposals?.append(contentsOf: proposals.proposals ?? [])
				}
			} else {
				withAnimation {
					queue = .loaded(proposals)
				}
				self.loading = .waitingMore
			}
			return proposals
		} else {
			withAnimation {
				if !isRequestMore {
					queue = .failed(nil)
				}
			}
		}
		
		return nil
	}
	
}

struct ProposalCell: View {
	
//	@State
	@Binding
	var proposal: SnapshotProposalInfo.SnapshotProposalInfoProposal
	
	@State var reload: Bool = false
	
	private func leadingIcon(_ proposal: SnapshotProposalInfo.SnapshotProposalInfoProposal) -> Text {
		if proposal.state == .closed {
			if proposal.isVoted {
				return Text(Image(systemName: "checkmark.rectangle.fill")).foregroundColor(.appGreen)
				+ Text(" ")
			} else {
				return Text(Image(systemName: "xmark.rectangle.fill"))
					.foregroundColor(.appRed)
				+ Text(" ")
			}
		} else {
			return Text("")
		}
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack(alignment: .top) {
				VStack(alignment: .leading) {
					AvatarAndETHAddressView(ethAddress: proposal.author)
						.id(reload)
						.onChange(of: WalletManager.shared.currentWalletOwnersNickname) { _ in
							reload.toggle()
						}
					Text("\(leadingIcon(proposal))\(proposal.title ?? "")")
						.foregroundColor(.label)
						.font(.rounded(size: 18.0, weight: .semibold))
				}
				Spacer()
				if let name = proposal.state?.cnName {
					SolidColorButton(text: name, bkgColor: proposal.stateColor) {
						
					}
				}
			}
			Text(proposal.body ?? "")
				.foregroundColor(.label.opacity(0.6))
				.font(.rounded(size: 15.0, weight: .regular))
			Spacer()
			if let ago = proposal.end?.timeAgo() {
				let prefix:String = "hellllnext_s".appLocalizable
				Text("\(prefix) \(ago.str)")
					.foregroundColor(.label.opacity(0.4))
					.font(.rounded(size: 14.0, weight: .light))
			}
		}
	}

}

extension SnapshotProposalInfo.SnapshotProposalInfoProposal {
	public var stateColor: Color {
		switch self.state {
		case .active:
			return .appGreen
		case .closed:
			return .appPurple
		case .all:
			return .appGrayMiddle
		default:
			return .appGrayMiddle
		}
	}
}

struct AvatarAndETHAddressView: View {

	@State var ethAddress: String?
	
	var body: some View {
		HStack {
			if let author = ethAddress {
				LGImage(source: Constant.ethHashAvatar(address: author, length: 36), placeholder: {
					Image(systemName: "person.circle")
				},options:[.imageWithFadeAnimation])
				.resizable()
				.cancelOnDisappear(true)
				.aspectRatio(contentMode: .fit)
				.cornerRadius(12)
				.frame(width: 24.0, height: 24.0)
				
				Text(author.aliasNickName().str)
					.font(.rounded(size: 15.0, weight: .regular))
					.foregroundColor(.label)
					.opacity(0.6)
					.padding(.trailing,40.0)
					.lineLimit(1)
			}
		}
	}
}

extension SnapshotProposals: ListEmpty {
	var dataIsEmpty: Bool {
		guard let proposals, !proposals.isEmpty else {
			return true
		}
		return false
	}
}

extension SnapshotProposalInfo.SnapshotProposalInfoProposal {
	static var testProposal: SnapshotProposalInfo.SnapshotProposalInfoProposal = {
		var tmp = SnapshotProposalInfo.SnapshotProposalInfoProposal()
		tmp.pid = "sadadas"
		tmp.title = "你好好你好好你好好你好好xxxxxxxxxxxxxxxxxxx"
		tmp.body = "内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容"
		tmp.state = .closed
		tmp.ipfs = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		tmp.author = "0xfa2B2E4348d6af2d6cd33a5e7dcb5E4eAaC477BC"
		tmp.end = Date(timeIntervalSince1970: 1665399370)
		tmp.choices = ["11111","22222","你好世界"]
		tmp.votes = 1
		var de = SnapshotVotesResultDetail()
		de.created = Date(timeIntervalSince1970: 1665399370)
		de.voter = EthereumAddress.preview2
		de.choice = 2
		de.vp = 23
		de.reason = "理由啊里有"
		tmp.lazy_votes = [
			de
		]
		return tmp
	}()
}

struct ProposalCell_Previews: PreviewProvider {
    static var previews: some View {
//		ProposalCell(proposal: SnapshotProposalInfo.SnapshotProposalInfoProposal.testProposal)
		ProposalCell(proposal: .constant(SnapshotProposalInfo.SnapshotProposalInfoProposal.testProposal))
			.previewLayout(.fixed(width: 387, height: 170))
			.padding()
    }
}
