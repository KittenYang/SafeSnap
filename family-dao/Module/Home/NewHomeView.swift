//
//  NewHomeView.swift
//  family-dao
//
//  Created by KittenYang on 8/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import GnosisSafeKit
import web3swift
import Defaults
import SheetKit
import BiometricAuthentication
import Introspect
import NetworkKit
import BigInt

struct NewHomeView: View {
	let interactor: NetworkAPIInteractor = NetworkAPIInteractor()
	
	@StateObject var pathManager = NavigationStackPathManager.shared
//	@StateObject var walletManager = WalletManager.shared
	@EnvironmentObject var walletManager: WalletManager
	@FetchRequest(fetchRequest: Family.fetchRequest().selected()) var currentFamily: FetchedResults<Family>
	
	@Default(.recentActions) var recentActions
	
	@Default(.actionCategories) var defaultActions

	@State var flipped: Bool = false
	
	@Default(.currencyHistory) var currencyHistory
	
//	@State var chartDatas = [CurrencyHistory]()
	
	//@Binding 高级用法
	//Binding 高级用法：监听 Binding 变化
	var flippedBinding: Binding<Bool> {
		Binding {
			$flipped.wrappedValue
		} set: { newvalue, tnx in
			$flipped.transaction(tnx).wrappedValue = newvalue
			observerFlippedChanges()
		}
	}
	
	private func observerFlippedChanges() {
		if flipped {
			pathManager.tabbarDimming = true
			HapticManager.select()
//			pathManager.visibility = .invisible
		} else {
			pathManager.tabbarDimming = false
//			pathManager.visibility = .visible
			//TODO: 延迟期间如果有新建了一个
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: .init(block: {
				if flipped == false, self.selectedAction != nil {
					self.selectedAction = nil
				}
			}))
			
		}
	}
	@State var listOffsetPercent: CGFloat = 0.0
	
	var body: some View {
		NavigationStack(path: $pathManager.path) {
			ZStack(alignment: .top) {
//				LinearGradient(colors: [.appGradientTop,.appGradientBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
//					.frame(height: 250.0)
//					.edgesIgnoringSafeArea(.top)
//					.blur(radius: 10.0)
				List {
					Group {
						myOwnValue()
							.gradientBlurTop()
						chart()
//							.modifier(DynamicTopCurrentFamilyModifer.Anchor(listOffsetPercent: $listOffsetPercent))
						//						myOwnValueNormal(["1":"xxxxxx","2":"xxxxxx"])
						mostRecentSection()
						defaultSection()
					}
					.listRowInsets(EdgeInsets(top: 0.0, leading: 10.0, bottom: 0.0, trailing: 10.0))
					.listRowBackground(Color.clear)
					.listRowSeparator(.hidden)
				}
				//				.modifier(TopCurrentFamilyModifer(offsetPercent: $listOffsetPercent))
				//				.scrollContentBackground(.hidden)// 隐藏tableview 背景
				.listStyle(PlainListStyle())
				.modifier(DynamicTopCurrentFamilyModifer(listOffsetPercent: $listOffsetPercent))
				.animation(.easeInOut(duration: 0.3), value: defaultActions)
			}
			.background(.systemGroupedBackground)
			.onAppear {
				getSafeInfo()
			}
			.navigationDestination(for: AppPage.self) { page in
				page.destinationPage
			}
			.blurWithZoomSmall(enable: flipped, scale:false)
			.coordinateSpace(name: "new_home_view")
			.overlay {
				GeometryReader { proxy in
					if let selectedAction, let rect = self.bindedWidths[selectedAction.id] {
						ZStack {
							Color.black
								.opacity(flipped ? 0.4 : 0.0)
								.animation(.linear, value: flipped)
								.onTapGesture {
									flippedBinding.wrappedValue = false
								}
								.ignoresSafeArea(edges:.all)
							
							ThreeDimensionalRotationEffect(flipped: flippedBinding,
														   endBlock: {},
														   fromFrame: rect.size,
														   toFrame: .init(width: 320, height: 300),
														   frontCornerRadius: 9.0,
														   front: ActionCard(action: selectedAction),
														   back: cardBack(selectedAction))
							.animation(.spring(response: 0.38,dampingFraction: 0.8), value: flipped)
							.position(x:proxy.size.width/2, y:proxy.size.height/2)
							.offset(x: !flipped ? rect.origin.x + rect.size.width/2 - proxy.size.width/2 : 0.0, y: !flipped ? rect.origin.y + rect.size.height/2 - (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0) - proxy.size.height/2 : 0.0)
						}
					}
				}
			}
			.onChange(of: currentFamily.first) { _ in
				refreshHistoricalCurrency()
			}
			.onChange(of: walletManager.currentWallet) { _ in
				refreshHistoricalCurrency()
			}
			.onChange(of: walletManager.reloadChart) { _ in
				refreshHistoricalCurrency()
			}
		}
//		.environmentObject(pathManager)
	}
	
	// MARK: 刷新图表，过去7天收入曲线
	private func refreshHistoricalCurrency() {
		if let fam = currentFamily.first?.address, let user = walletManager.currentWallet?.address {
			Task {
				let data = await WalletManager.shared.historicalCurrency()
				self.currencyHistory.saveDatas(family: fam,user: user, data: data)
			}
		}
	}
	
	@ViewBuilder
	func cardBack(_ action: ActionModel) -> some View {
		ChangeActionCountView(action: action, flipped: flippedBinding) { act, count in
//			flippedBinding.wrappedValue = false
			Task {
				let success = await act.send(byTimes: count)
				if success {
					var new = act
					new.count = count
					Defaults.addRecentStoreActions([new])
				}
			}
		}
	}
	
	@ViewBuilder
	func myOwnValue() -> some View {
		if let currentFamily = FamilyViewModel(managedObject: currentFamily.first),
		   let ownerTokenBalance = currentFamily.ownerTokenBalance,
		   ownerTokenBalance.keys.count > 0 {
			let symbol = currentFamily.token?.symbol ?? ""
			Section {
				VStack {
					if let ownerWallet = walletManager.currentWallet,
					   let ownerBalance = ownerTokenBalance[ownerWallet.address] {
						CurrentBalanceCell(title: "newPorinext_s_WON".appLocalizable, rightText: "\(ownerBalance) \(symbol)")
						Divider()
							.frame(height: 0.01)
							.background(.gray)
					}
					otherUsersToken(currentFamily,ownerTokenBalance)
				}
				.groupListStyle()
			}
			.id(UUID())
			.transition(.move(edge: .leading))
			.animation(.linear, value: ownerTokenBalance)
//			.listRowBackground(VisualEffect(style: .prominent))
			.padding(.bottom,15.0)// Section 间隔空白
		} else {
			EmptyView()
		}
	}
	
	@ViewBuilder
	private func otherUsersToken(_ currentFamily: FamilyViewModel, _ ownerTokenBalance:OwnersTokenBalance) -> some View {
		let symbol = currentFamily.token?.symbol ?? ""
		let top5ownerTokenBalanceKeys = currentFamily.top5ownerTokenBalanceKeys().filter({ $0 != walletManager.currentWallet?.address })
		ForEach(Array(top5ownerTokenBalanceKeys.enumerated()), id: \.offset) { index, address in
			if let addressBalance = ownerTokenBalance[address], address != walletManager.currentWallet?.address {
				OtherOwnerBalanceCell(title: getNickName(address: address), rightText: "\(addressBalance) \(symbol)")
				if walletManager.isMyFamily {
					if index != ownerTokenBalance.keys.count - 2 {
						Divider()
							.frame(height: 0.01)
							.background(.gray)
					}
				} else {
					if index != ownerTokenBalance.keys.count - 1 {
						Divider()
							.frame(height: 0.01)
							.background(.gray)
					}
				}
			}
		}
		.id(top5ownerTokenBalanceKeys)
	}
	
//	@ViewBuilder
//	func myOwnValueNormal(_ ownerTokenBalance:[String:String]) -> some View {
//		
//		Section(header: Spacer(minLength: CurrentFamilyInfoNavView.topPaddingInset)) {
//			
//			VStack {
//				CurrentBalanceCell(title: "我所持有", rightText: "lalala")
//				Divider()
//					.frame(height: 0.01)
//					.background(.gray)
//				ForEach(Array(ownerTokenBalance.keys.sorted().enumerated()), id: \.offset) { index, address in
//					OtherOwnerBalanceCell(title: getNickName(address: address), rightText: "xxxxx")
//					if index != ownerTokenBalance.keys.count - 1 {
//						Divider()
//							.frame(height: 0.01)
//							.background(.gray)
//					}
//				}
//			}
//			.groupListStyle()
//		}
//		.id(UUID()).transition(.move(edge: .leading))
//		//.id(UUID()).transition(.slide)
//		.animation(.linear, value: walletManager.currentFamily?.ownerTokenBalance)
//		//			.listRowBackground(VisualEffect(style: .prominent))
//		
//	}

	@ViewBuilder
	func chart() -> some View {
		if walletManager.isMyFamily,
		   let fam = currentFamily.first?.address,
		   let user = walletManager.currentWallet?.address,
		   let chartDatas = currencyHistory.datas(family: fam, user: user), !chartDatas.isEmpty {
			Section {
				AreaSimple<CurrencyHistory>(isOverview: false, datas: chartDatas)
			}
			.id(chartDatas)
			.transition(.blur)
			.animation(.easeOut, value: chartDatas)
			.groupListStyle()
			.padding([.bottom],15.0)// Section 间隔空白
		}
	}
	
	@ViewBuilder
	func mostRecentSection() -> some View {
		Section {
			Text("newPorinext_s_recnet".appLocalizable)
				.font(.rounded(size: 20.0))
				.bold()
				.padding(.leading,12.0)
				.listRowInsets(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
			if recentActions.count > 0 {
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHGrid(rows: [GridItem(.flexible())], alignment: .center, spacing: 26.0, pinnedViews: [.sectionHeaders]) {
						ForEach(recentActions, id: \.self) { raw in
							Button {
								Task {
									await raw.send()
								}
							} label: {
								VStack {
									Image(systemName: raw.iconSymbolName)
										.resizable()
										.foregroundColor(.white)
										.frame(width: 22.0, height: 22.0)
										.padding(.all,7.0)
										.background(Color(hexString: raw.colorHexString) )
										.cornerRadius(5.0)
									Text("\(raw.name)(x\(raw.count))")
										.font(.rounded(size: 13.0))
								}
							}
							.buttonStyle(ScaleButtonStyle())
						}
					}
					.introspectScrollView(customize: { $0.clipsToBounds = false })
				}
				.groupListStyle()
				.padding(.bottom,15.0)// Section 间隔空白
			} else {
				SectionEmptyView()
			}
		}
	}
	
	let gridm = [GridItem(.adaptive(minimum: 110, maximum: 150))]
	
	@ViewBuilder
	func defaultSection() -> some View {
		if defaultActions.count > 0 {
			ForEach(defaultActions, id:\.self) { catogory in
				Group {
					Text(catogory.name)
						.font(.rounded(size: 20.0))
						.bold()
						.padding(.leading,12)
					//					.padding(.top,15)
					LazyVGrid(columns: gridm, alignment: .leading, spacing:10.0) {
						hell(catogory)
					}
					.padding([.leading,.trailing],12)
					.padding(.bottom,15.0) // section间隔空白
				}
				.listRowInsets(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
			}
		} else {
			Section {
				Text("newPorinext_s_recnet_catee".appLocalizable)
					.font(.rounded(size: 20.0))
					.bold()
					.padding(.leading,12.0)
					.listRowInsets(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
				SectionEmptyView()
			}
		}
	}
	
	@ViewBuilder
	func hell(_ catogory: ActionModelCategory) -> some View {
		ForEach(catogory.actions, id: \.self) { action in
			Button {
				captureFrame = true
				selectedAction = action
				Delay(0.08) {
					captureFrame = false
					flippedBinding.wrappedValue = true
				}
			} label: {
				ActionCard(action: action)
					.frame(width: 100, height: 115)
					.modifier(if: captureFrame, then: { v in
						v.background(CGRectGeometry(coordinateSpaceName: "new_home_view"))
							.onPreferenceChange(CGRectPreferenceKey.self, perform: {
								self.bindedWidths[action.id] = $0
							})
					})
//					.transition(.scale.combined(with: .opacity))
					.hidden(selectedAction != nil && selectedAction == action)
			}
			.buttonStyle(ScaleButtonStyle())
		}
	}
	
	@State private var bindedWidths = [String:CGRect]()

	@State private var selectedAction: ActionModel?
	
	@State private var captureFrame: Bool = false
	
}

extension NewHomeView {
	private func getNickName(address: String) -> String {
		var title = address.etherAddressDisplay()
		if let nick = walletManager.currentWalletOwnersNickname[address], !nick.isEmpty {
			title = "\(nick)(\(title))"
		}
		return title
	}

	private func getSafeInfo() {
		Task {
			await WalletManager.refreshCurrentSelectedFamily()
		}
		//TODO: 测试 ENS 域名相关 API
//		Task {

//			let domain = WalletManager.shared.currentSpaceDomain?.wthETHSuffix.lowercased() ?? ""//"familydao-dev-13"
			// 创建一个新的 space
//			await SnapshotManager.createSpace(newDomain: domain)
			
			// 提交新提案
//			await SnapshotManager.postAnewProposal(domain: domain, system: .single_choice, title: "Family-Dao-App第4个提案", body: "body不知道说什么，我就哈哈哈", choices: ["红酒","咖啡","可乐"], start: .now, end: .now.addingTimeInterval(TimeInterval(5000))) // 5分钟
			
			// 前100条
//			if let proposals = await SnapshotManager.getAllProposalOfSpace(domain: "\(domain).eth", first: 100) {
//				if let first_pro_id = proposals.proposals?.first?.id {
//					debugPrint("first_pro_id:\(first_pro_id)")
//					if let proposal = await SnapshotManager.checkProposalInfo(pid: first_pro_id)?.proposal {
//						debugPrint("proposal:\(proposal.toJSONString() ?? "nil")")
//					}
//				}
//			}
			
			// 活跃的前100条
//			if let proposals = await SnapshotManager.getAllStateProposalOfSpace(domain: "\(domain).eth", first: 100, state: .closed, startDate: Date(timeIntervalSince1970: 1663933035)) {
//				if let first_pro_id = proposals.proposals?.first?.id {
//					debugPrint("first_pro_id:\(first_pro_id)")
//					if let proposal = await SnapshotManager.checkProposalInfo(pid: first_pro_id)?.proposal {
//						debugPrint("proposal:\(proposal.toJSONString() ?? "nil")")
//					}
//				}
//			}
			
			// 投票最新的一条
//			if let proposals = await SnapshotManager.getAllStateProposalOfSpace(domain: "\(domain).eth", first: 2, state: .active, startDate: Date(timeIntervalSince1970: 1663933035)) {
//				if let first_pro_id = proposals.proposals?.first?.id {
//					debugPrint("first_pro_id:\(first_pro_id)")
//					await SnapshotManager.voteAProposal(domain: "\(domain).eth", proposal: first_pro_id, choice: 3)
//				}
//			}
			
//			guard let props = await SnapshotManager.getAllProposalOfSpace(domain: "\(domain).eth", first: 100)?.proposals else { return }
//			for prop in props {
//				if let prop_id = prop.id {
//					// 获取用户对某个 proposal 的投票
//					let ss = await SnapshotManager.getVotes(proposalID: prop_id)
//					if let votes = ss?.toJSONString() {
//						debugPrint("votes:\(votes)")
//					}
//				}
//			}
			
//			let subscription = await SnapshotManager.getSpaceSubscription(domain: "\(domain).eth")
//			if let subscription = subscription?.toJSONString() {
//				debugPrint("subscription:\(subscription)")
//			}
			
//		}
		
	}
	
}

extension View {
	func groupListStyle() -> some View {
		self
			.padding(.all,12.0)
			.background(Color("appBkgColor"))
			.frame(width: nil, alignment: .center)
			.cornerRadius(10.0)
	}
}


struct NewHomeView_Previews: PreviewProvider {
	static var previews: some View {
		XcodePreviewsDevice.previews([.iPhoneSE, .iPhone14ProMax, .iPadAir]) {
			TabView {
				NewHomeView()
					.environmentObject(WalletManager.shared)
					.tabItem {
						Label("Home", systemImage: "house")
					}
			}
		}
	}
}

extension GeometryProxy {
	// converts from some other coordinate space to the proxy's own
	func convert(_ point: CGPoint, from coordinateSpace: CoordinateSpace) -> CGPoint {
		let frame = self.frame(in: coordinateSpace)
		let localViewPoint = CGPoint(x: point.x-frame.origin.x, y: point.y-frame.origin.y)
		
		// Some system bug? Test in iOS 13.4, 13.5, 14.1, 14.5
		if coordinateSpace == .global {
			switch (UIDevice.current.systemVersion as NSString).floatValue {
			case 13.5:
				return CGPoint(x: localViewPoint.x, y: point.y)
			case 14.5:
				return point
			default: break
			}
		}
		
		return localViewPoint
	}
}
