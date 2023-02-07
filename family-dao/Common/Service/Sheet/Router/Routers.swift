//
//  Routers.swift
//  family-dao
//
//  Created by KittenYang on 8/22/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import SwiftUI
import MultiSigKit


public class ShowSheetModelContent<Content>: ObservableObject where Content: View {
	@Published public var content: () -> Content
	
	public init(@ViewBuilder _ content: @escaping () -> Content) {
		self.content = content
	}
}

//public typealias ShowSheetModel<Content> = (presented: Bool, sheetContent: ShowSheetModelContent<Content>?)

public class ShowSheetModel<Content>: ObservableObject where Content: View {
	@Published var presented: Bool = false
	@Published var sheetContent: ShowSheetModelContent<Content>?
	
	init(presented: Bool = false, sheetContent: ShowSheetModelContent<Content>? = nil) {
		self.presented = presented
		self.sheetContent = sheetContent
	}
}

class NavigationStackPathManager: ObservableObject {
	static let shared = NavigationStackPathManager()
//	private init() {}
	@Published var path:[AppPage] = []
//	@Published var showCreateNewUserPage: Bool = false
	@Published var showSheetModel: ShowSheetModel<AnyView> = .init()
	
	@Published var visibility: TabBarVisibility = .visible
	@Published var tabbarDimming: Bool = false
	
	@Published var showDimmingViewAction: ((GeometryProxy)->any View)?
	
	static func dismissSheetVC() {
		RunOnMainThread {
			WalletManager.shared.currentContainerID = Constant.AppContainerID
			NavigationStackPathManager.shared.showSheetModel = .init(presented:false)
		}
	}
}

extension AppPage: Hashable {
	static func == (lhs: AppPage, rhs: AppPage) -> Bool {
		switch (lhs, rhs) {
		case (.newUserMemo(let wallet, let name, let password), .newUserMemo(let wallet1, let name1, let password1)):
			return wallet?.address == wallet1?.address && name == name1 && password == password1
		case (.welcome, .welcome):
			return true
		case (.createNewFamily,.createNewFamily):
			return true
		case (.importFamily,.importFamily):
			return true
		case (.newHome,.newHome):
			return true
		case (.queue,.queue):
			return true
		case (.createNewUser,.createNewUser):
			return true
		case (.protect,.protect):
			return true
		case (.importUserFromMemo,.importUserFromMemo):
			return true
		case (.importUserFromiCloud,.importUserFromiCloud):
			return true
		default:
			return false
		}
	}
	
	func hash(into hasher: inout Hasher) {
		switch self {
		case .newUserMemo(let wallet, let name, let password):
			hasher.combine(wallet?.address) // combine with associated value, if it's not `Hashable` map it to some `Hashable` type and then combine result
			hasher.combine(name)
			hasher.combine(password)
		case .welcome:
			hasher.combine("welcome")
		case .createNewFamily:
			hasher.combine("createNewFamily")
		case .importFamily:
			hasher.combine("importFamily")
		case .newHome:
			hasher.combine("newHome")
		case .queue:
			hasher.combine("queue")
		case .createNewUser:
			hasher.combine("createNewUser")
		case .protect:
			hasher.combine("protect")
		case .importUserFromMemo:
			hasher.combine("importUserFromMemo")
		case .importUserFromiCloud:
			hasher.combine("importUserFromiCloud")
		case .changeSafeThrehold:
			hasher.combine("changeSafeThrehold")
		}
	}
}

enum AppPage {

	case welcome //= "welcome"
	case createNewFamily// = "createNewFamily"
	case importFamily// = "importFamily"
	case newHome// = "newHome"
	case queue// = "queue"
	
	/*
	 创建用户
	 */
	case createNewUser// = "createNewUser"
	case newUserMemo(wallet: Wallet?, name: String?, password: String?) //= "newUserMemo"
	case protect(successHandler:((String)->Void)? = nil)// = "protect"
	case importUserFromMemo// = "importUserFromMemo"
	case importUserFromiCloud(_ `for`:ImportUserFromiCloud.ImportFor, _ callback:(([String:String])->Void)? = nil)// = "importUserFromiCloud"
	
	case changeSafeThrehold
	
	var destinationPage: some View {
		switch self {
		case .newUserMemo(let wallet, let name, let password):
			return AnyView(MenoCreateView(wallet: wallet, name: name, password: password))
		case .welcome:
			return AnyView(WelcomeView())
		case .createNewFamily:
			return AnyView(CreateNewFamily())
		case .importFamily:
			return AnyView(ImportFamilyView())
		case .newHome:
			return AnyView(NewHomeView())
		case .queue:
			return AnyView(QueueView())
		case .createNewUser:
			return AnyView(CreateNewUser())
		case .protect(let handler):
			return AnyView(ProtectUI(authoriteSuccessHandler: handler))
		case .importUserFromMemo:
			return AnyView(ImportUserFromMemo())
		case .importUserFromiCloud(let `for`, let callback):
			return AnyView(ImportUserFromiCloud(for: `for`, callback: callback))
		case .changeSafeThrehold:
			return AnyView(ChangeSafeThreholdView())
		}
	}
}
