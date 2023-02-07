//
//  SwiftUIView.swift
//  family-dao
//
//  Created by KittenYang on 8/27/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import web3swift
import Combine
import Refresh

class LifeMonitor {
	let name: String
	init(name: String) {
		self.name = name
		print("\(name) init")
	}

	deinit {
		print("\(name) deinit")
	}
}

struct QueueView: View {

//	let printer = LifeMonitor(name:"QueueView")
	
	@EnvironmentObject var walletManager: WalletManager
//	@FetchRequest(fetchRequest: Family.fetchRequest().selected()) var currentFamily: FetchedResults<Family>
//	@Environment(\.currentFamily) var currentFamily: Family?
	
	@State var queue: Loadable<FixedSafeHistoryObject> = .notRequested {
		didSet {
			debugPrint(self.queue)
		}
	}
	
	let interactor: NetworkAPIInteractor = NetworkAPIInteractor()
	
	@State var loading: Loading = .noMore
	
	init() {
		
	}
	
	var body: some View {
		AppInsetGroupedList<FixedSafeHistoryObject>(list: list(), retryAction: { force in
			await getSafeQueues(offset: nil, limit: nil, force)
		} , queue: $queue)
		.environment(\.currentQueueType, $queue)
	}

}

extension FixedSafeHistoryObject: ListEmpty {
	var dataIsEmpty: Bool {
		guard !self.storage.isEmpty else {
			return true
		}
		return false
	}
}

// MARK: - Displaying Content
extension QueueView {
	
	@ViewBuilder
	func list() -> some View {
		// 关键就是这里！！！！写成 *self.model.queue.value* 就不会触发更新
//		if let value = queue.value {
			GeometryReader { proxy in
				List {
					ForEach((queue.value?.storage ?? [:]).sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { (key, value) in
						SectionViewModifier(key: .constant(key), values: .init(get: {
							return value
						}, set: { newV in
							self.queue.value?.storage[key] = newV
						}))
							.listRowInsets(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
							.listRowBackground(Color.clear)
					}
					
					if (self.queue.value?.storage[.queued] ?? []/*queueItems*/).count > 0 {
						LoadMoreView(loadingState: $loading, proxy: proxy, runLoadingAction: {
							Task {
								await self.loadMore()
							}
						})
						.id(loading)
					}
				}
//				.id(queue)
				.enableRefreshLoadMore()
				.modifier(DynamicTopCurrentFamilyModifer(listOffsetPercent: .constant(0.0)))
//				.modifier(TopCurrentFamilyModifer(offsetPercent: .constant(0.0)))
				//			.background(Color.clear)
				//			.scrollContentBackground(.hidden)
				.listStyle(InsetGroupedListStyle())
			}
			.transition(.blur)
			.animation(.easeInOut(duration: 0.3), value: queue.value?.storage)
//		}
	}
	
	func getCurrentCount() -> Int {
		return getCountBy(his: self.queue.value?.storage)
	}
	
	func getCountBy(his: FixedSafeHistory?) -> Int {
		guard let his else {
			return 0
		}
		var offSet: Int = 0
		for (_, values) in his {
			for value in values {
				if value.count > 0 {
					offSet += value.count
				}
			}
		}
		return offSet
	}
	
	func canLoadMore() -> Bool {
		return getCurrentCount() >= 0
	}
	
	func getMore(limit:Int) async -> FixedSafeHistory?  {
		let offSet = self.queue.value?.storage[.queued]?.last?.last?.executionInfo?.nonce ?? 0 //getCurrentCount() - 1
		guard offSet >= 0 else {
			return nil
		}

		return await getSafeQueues(offset: Int(offSet) + 1, limit: limit, false)
	}
	
	@discardableResult
	func getSafeQueues(offset:Int?, limit:Int?, _ force: Bool) async -> FixedSafeHistory? {
		// 如果已经有数据了，不需要再次loading
		if case .loaded(_) = self.queue, !force {
		} else {
			let cancelBag = CancelBag()
			queue.setIsLoading(cancelBag: cancelBag)
		}
		
		var isRequestMore: Bool = false
		if let _ = offset, let _ = limit {
			isRequestMore = true
		}
		
		if let history = await self.interactor.getSafeQueues(offset: offset, limit: limit) {
			debugPrint("收到新队列数据")
			if isRequestMore {
				withAnimation {
					let more = history[.queued] ?? []
					self.queue.value?.storage[.queued]?.append(contentsOf: more)
				}
			} else {
				withAnimation {
					queue = .loaded(FixedSafeHistoryObject(history))
				}
				self.loading = .waitingMore
			}
			return history
		} else {
			withAnimation {
				if !isRequestMore {
					queue = .failed(nil)
				}
			}
		}
		
		return nil
	}
	
	func loadMore() async {
		print("加载更多.....")
		let limit = 20
		let new = await getMore(limit: limit)
		if canLoadMore() && (getCountBy(his: new) >= limit) {
			self.loading = .waitingMore
		} else {
			self.loading = .noMore
		}
	}
	
}

struct SwiftUIView_Previews: PreviewProvider {
	static var previews: some View {
		QueueView()
			.environmentObject(WalletManager.shared)
	}
}


public extension EnvironmentValues {
	var currentQueueType: BindingLoadable<FixedSafeHistoryObject> {
		get { return self[CurrentQueueTypeKey.self] }
		set { self[CurrentQueueTypeKey.self] = newValue }
	}
	
	var currentProposalListType: BindingLoadable<SnapshotProposals> {
		get { return self[CurrentProposalListTypeKey.self] }
		set { self[CurrentProposalListTypeKey.self] = newValue }
	}
}

public struct CurrentQueueTypeKey: EnvironmentKey {
	public static let defaultValue: BindingLoadable<FixedSafeHistoryObject> = .constant(Loadable.notRequested)
}


public struct CurrentProposalListTypeKey: EnvironmentKey {
	public static let defaultValue: BindingLoadable<SnapshotProposals> = .constant(Loadable.notRequested)
}
