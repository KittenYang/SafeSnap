//
//  AppInsetGroupedList.swift
//  family-dao
//
//  Created by KittenYang on 12/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

protocol RetryActionable {
	var retryAction: ((_ force: Bool) async -> Void)? { get set }
}

protocol ListEmpty {
	var dataIsEmpty: Bool { get }
	
//	func initialAction() async -> Void
}

// 通用 group list view
struct AppInsetGroupedList<T:ListEmpty & Hashable>: View, RetryActionable {
	@EnvironmentObject var walletManager: WalletManager
//	@Environment(\.currentFamily) var currentFamily: Family?
	@FetchRequest(fetchRequest: Family.fetchRequest().selected()) var currentFamily: FetchedResults<Family>
	
	var list: any View
	
	var retryAction: ((_ force: Bool) async -> Void)?
	
//	let initialAction: () -> Void
	
	@Binding var queue: Loadable<T>
	
	var body: some View {
		ZStack(alignment: .top) {
			VStack {
				Spacer(minLength: 0)
				content
				Spacer(minLength: 0)
			}
//			Color.red.opacity(0.3)
//				.frame(height: 50.0)
//			CurrentFamilyInfoNavView(family: .constant(FamilyViewModel(managedObject:currentFamily)), wallet: $walletManager.currentWallet, hide: .constant(false))
		}
//		.background(Color.appBackground)
//		.background(.ultraThinMaterial)
//		.id(queue)
		.onChange(of: walletManager.shouldReloadQueue, perform: { v in
			Task {
				await retryAction?(true)
			}
		})
		.onChange(of: currentFamily.first, perform: { v in
			Task {
				await retryAction?(true)
			}
		})
		.onChange(of: walletManager.currentWallet, perform: { v in
			Task {
				await retryAction?(true)
			}
		})
		.onAppear {
			UITableView.appearance().sectionFooterHeight = 0
		}
		.embedInNavigation(/*pathManager*/)
	}
	
	@ViewBuilder
	private var content: some View {
		switch queue {
		case .notRequested:
			AnyView(notRequestedView)
		case .isLoading:
			AnyView(loadingView)
		case .loaded(let data):
			if data.dataIsEmpty {
				ListEmptyView {force in
					await retryAction?(force)
				}
			} else {
				AnyView(
					list.refreshable {
						await retryAction?(false)
					})
			}
		case .failed(let error):
			AnyView(failedView(error))
		}
	}
	
	var notRequestedView: some View {
		Text("")
			.onAppear {
				Task {
					await retryAction?(true)
				}
		}
	}
	
	var loadingView: some View {
		VStack {
			ActivityIndicatorView(style: .medium)
			BlurButton(uiImage: nil, text: "nsdessssxt_ssss".appLocalizable, subText: nil, baseFontSize: 16.0) {
				self.queue.cancelLoading()
			}
		}
	}
	
	func failedView(_ error: Error?) -> some View {
		ErrorView(error: error, retryAction: retryAction)
	}
	
	
}



