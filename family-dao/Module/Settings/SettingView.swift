//
//  SettingView.swift
//  family-dao
//
//  Created by KittenYang on 12/25/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import web3swift
import SwiftUIOverlayContainer
import BigInt
import struct LonginusSwiftUI.LGImage
import SafariServices
import NetworkKit
import YYCategories
import LanguageManagerSwiftUI

typealias SettingModel = Pair<String?, [SettingCellModel]>

struct SettingView: View {
	
	@EnvironmentObject var pathManager: NavigationStackPathManager
	
	@EnvironmentObject var languageSettings: LanguageSettings
	
	@EnvironmentObject var userSetting: UserSettings
	
	@FetchRequest(fetchRequest: Family.fetchRequest().selected()) var currentFamily: FetchedResults<Family>
	
	@EnvironmentObject var walletManager: WalletManager
	
	@Environment(\.colorScheme) var colorScheme: ColorScheme
	
//	@AppStorage("isDarkMode") var isDarkMode: Bool = false
	
	init() {
		UITableView.appearance().sectionFooterHeight = 0
		UITableView.appearance().sectionHeaderHeight = 0
		//Use this if NavigationBarTitle is with Large Font
		UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]

		//Use this if NavigationBarTitle is with displayMode = .inline
		UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
	}

	var models: [SettingModel]
	{
		return [
			Pair(nil, switchGroup())
			,Pair("settings_c_user".appLocalizable, currentMain())
			,Pair("settings_c_team".appLocalizable, familySectionModel())
			,Pair("\("settings_c_team_mems".appLocalizable)\(currentFamily.first?.owners.count ?? 0)", ownerSettingCellModels())
			,Pair("settings_general".appLocalizable, general())
			,Pair("settings_support".appLocalizable, [
				.init(icon: .init(named: "twitter_bird"), text: "Twitter", subText: nil, rightIcon: nil, rightView: .init(id: "twi_cell", closure: { _ in
					Link(destination: .init(string: "https://twitter.com/KittenYang")!, label: {
						Text("@KittenYang")
							.font(.rounded(size: 14.0))
					})
				}))
                ,.init(icon:.init(named: "eth_logo_pixel"), text: "Author", subText: nil, rightIcon:.init(systemName: "doc.on.doc"), rightView: .init(id: "tip_jar_cell", closure: { _ in
					Link(destination: .init(string: "https://metamask.app.link/send/0x9D68df58C48ce745306757897bb8FaA3FE72A1BF")!, label: {
						Text("0x9D68df58C48ce745306757897bb8FaA3FE72A1BF")
							.font(.rounded(size: 14.0))
					})
				}), action: .init(id: "copy_tip_jar", closure: {
					let pasteboard = UIPasteboard.general
					   pasteboard.string = "0x9D68df58C48ce745306757897bb8FaA3FE72A1BF"
					AppHUD.show("copy_suss".appLocalizable)
				   }))
//				,.init(icon: .init(named: "discord_icon"), text: "Discord", subText: "", rightIcon: nil)
//				,.init(emoji: "🫶", text: "settings_help".appLocalizable, subText: "", rightIcon: nil)
			])
//			,Pair("", [.init(emoji: "📖", text: "settings_help_about".appLocalizable, subText: "", rightIcon: nil)])
		].filter({ !$0.two.isEmpty })
	}
	
	private func switchGroup() -> [SettingCellModel] {
		var tmp = [SettingCellModel]()
		// 当前家庭
		let allFamil = Family.all
		if allFamil.count > 0 {
			tmp.append(
				.init(text: "settings_switch_t".appLocalizable, subText: "\(Family.all.count)", rightIcon: nil, action: TaggedClosure(id: "all_familys", closure: {
					NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
						AnyView(EditAllFamilyView().embedInNavigation())
					}))
				}))
			)
		}
		
		return tmp
	}
	
	private func currentMain() -> [SettingCellModel] {
		var tmp = [SettingCellModel]()
		// 当前用户
		if let wallet = walletManager.currentWallet {
			tmp.append(
				.init(emoji:"🤠", text: "settings_switch_t_u".appLocalizable, subText: wallet.name, rightIcon: nil, action: TaggedClosure(id: "current_login_user", closure: {
					NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
						AnyView(ChangeNameView(from: .wallet).embedInNavigation())
					}))
				}))
			)
			tmp.append(
				SettingCellModel.ethAddressWithAvatarAndCopy(wallet.address)
			)
		}
		
		return tmp
	}
	
	private func getColorSchemeView() -> some View {
		Picker("", selection: $userSetting.selectedAppearance) { // 3
			ForEach(ColorSchemeAppearance.allCases, id: \.self) { item in // 4
				if let item {
					Text(item.name)
						.foregroundColor(.appBlue)
						.font(.rounded(size: 16.0))
						.bold()
						.addBKG(color: Color(hexString: "F1F1F1"))
						.layoutPriority(1)
				}
			}
		}
		.pickerStyle(.menu)
	}
	
	private func general() -> [SettingCellModel] {
		var tmp = [SettingCellModel]()
		tmp.append(contentsOf: [
			.init(emoji:"👒", text: "settings_switch_t_u_app".appLocalizable, subText: nil, rightIcon: colorScheme == .dark ? .init(systemName: "moon.fill") : .init(systemName: "sun.min.fill"), rightView: .init(id: "getColorSchemeView", closure: { _ in
				getColorSchemeView()
			})),
			.init(emoji:"👄", text: "lanlan".appLocalizable, subText: nil, rightView: .init(id: "LanguageSelectView()", closure: { _ in
				LanguageSelectView()
			}))
		])
		
		return tmp
	}
	
	private func setupColorScheme(_ isDarkMode: Bool) {
		UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
	}
	
    var body: some View {
		List {
			Section {
				LazyVGrid(columns:[GridItem(.adaptive(minimum: 120))
								   ,GridItem(.adaptive(minimum: 120))],
						  alignment: .leading,
						  spacing:10.0,
						  content: {
					HStack {
						Circle()
							.frame(width:13, height: 13)
							.foregroundColor(walletManager.currentWallet != nil ? .appGreen : .gray)
						Text(walletManager.currentWallet != nil ? "heloda_asdas_kkamcgyo79r".appLocalizable : "heloda_asdas_kkamcgyo79r_fasasf".appLocalizable)
					}
					HStack {
						Circle()
							.frame(width:13, height: 13)
							.foregroundColor(walletManager.currentFamily != nil ? .appGreen : .gray)
						Text(walletManager.currentFamily != nil ? "heloda_asdas_kkamcgyo79rfasfas".appLocalizable : "heloda_asdas_kkamcgyo79_mnpfasf".appLocalizable)
					}
					HStack {
						Circle()
							.frame(width:13, height: 13)
							.foregroundColor(walletManager.currentFamily?.token != nil ? .appGreen : .gray)
						Text(walletManager.currentFamily?.token != nil ? "helodgtja_asdas_kkamfsfacgyo79r".appLocalizable : "fasfshelodsssa_asdas_kkamcgyo79r".appLocalizable)
					}
					HStack {
						Circle()
							.frame(width:13, height: 13)
							.foregroundColor(walletManager.spaceURL() != nil ? .appGreen : .gray)
						Text(walletManager.spaceURL() != nil ? "dasfaheloda_asdas_kkamcgyo79r_fasass".appLocalizable : "he_fasffklkffvloda_asdas_kkamcgyo79r".appLocalizable)
					}
					HStack {
						Circle()
							.frame(width:13, height: 13)
							.foregroundColor(walletManager.currentFamily?.chain != nil ? .appGreen : .gray)
						Text("\("heloda_asdas_kkamcgyo79r_curre_chian".appLocalizable) \(walletManager.currentFamily?.chain.web3Networks.name ?? "None")")
					}
				})
				.font(.rounded(size: 13.0))
				.listRowInsets(.init(top: 15.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
				.listRowBackground(Color.clear)
			}
			.padding(.zero)
//			.border(.red)
			
			ForEach(Array(zip(models.indices, models)), id: \.0) { index, model in
				Section(header:header(model.one), footer: footer(index == models.count - 1)) {
					ForEach(model.two, id:\.self) { happy in
						SettingViewCell(happy: .constant(happy))
					}
				}
			}
		}
		.listStyle(.insetGrouped)
		.navigationBarTitle(AppTabbarItem.setting.title)
//		.background(NavigationConfigurator { nc in
//			nc.navigationBar.barTintColor = UIColor(.appTheme)
//			nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
//		})
		.navigationBarTitleDisplayMode(.large)
		// navigationBar 滑动后的背景色
//		.toolbarBackground(Color.appTheme, for: .navigationBar)
//		.toolbar {
//			ToolbarItem(placement: .principal) {
//				HStack {
//					Image(systemName: "sun.min.fill")//moon.fill
//					Text("设置")
//						.font(.headline)
//						.foregroundColor(.orange)
//				}
//			}
//		}
//		.introspectNavigationController(customize: { $0.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white] })
		.toolbar {
			Image(uiImage: UIImage(color: UIColor.clear)?.byResize(to: .init(width: 32.0, height: 32.0)) ?? .init())
			.frame(width: 32, height: 32, alignment: .trailing)
			.modifier(DeveloperModeModifier())
		}
    }

	@ViewBuilder
	private func header(_ string: String?) -> some View {
		if let string {
			Text(string)
                .font(.rounded(size: 16.0))
		}
	}
	
	@ViewBuilder
	private func footer(_ isLast: Bool) -> some View {
		if isLast {
			HStack {
				Spacer()
				Text(AttributedString(UIApplication.versionHeaderText()))
					.multilineTextAlignment(.center)
				Spacer()
			}.padding()
		}
	}
	
	private func familySectionModel() -> [SettingCellModel] {
		var cells = [SettingCellModel]()
		if let token = currentFamily.first?.token {
			if let token_add = token.address {
				cells.append(
					.init(emoji:"🏛️", text: "settings_token".appLocalizable, subText: token_add, rightIcon: .init(systemName: "doc.on.doc"), action: .init(id: "copy_\(token_add)", closure: {
						let pasteboard = UIPasteboard.general
						pasteboard.string = token_add
						AppHUD.show("copy_suss".appLocalizable)
					}))
				)
			}
			if let totalSupply = token.totalSupply {
				cells.append(
					.init(emoji:"💰", text: "token_all_supply".appLocalizable, subText: "\(totalSupply) \(currentFamily.first?.token?.symbol ?? "")", rightIcon: nil, action: nil)
				)
				if let balans = currentFamily.first?.toViewModel?.ownerTokenBalance {
					var allUsed: Int = 0
					balans.forEach { element in
						if let value_int = Int(element.value) {
							allUsed += value_int
						}
					}
					if let totalInt = Int(totalSupply) {
						let rest = totalInt - allUsed
						cells.append(.init(emoji:"💸", text: "token_rest".appLocalizable, subText: "\(rest) \(currentFamily.first?.token?.symbol ?? "")", rightIcon: nil, action: nil))
					}
				}
			}
		}
		if let fam = currentFamily.first {
			var others: [SettingCellModel] = [
				.init(emoji:"👨‍👩‍👦", text: "team_address".appLocalizable, subText: fam.address,rightIcon: .init(systemName: "doc.on.doc"), action: .init(id: "copy_\(fam.address)", closure: {
					let pasteboard = UIPasteboard.general
					pasteboard.string = fam.address
					AppHUD.show("copy_suss".appLocalizable)
				})),
				.init(emoji:"🆔", text: "team_name".appLocalizable, subText: fam.name, rightIcon: nil, action: TaggedClosure(id: "cell_name", closure: {
					NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
						AnyView(ChangeNameView(from: .family).embedInNavigation())
					}))
				})),
				.init(emoji:"👥", text: "team_peo".appLocalizable, subText: "\(fam.threshold)", rightIcon: nil, action: TaggedClosure(id: "safe_threhold", closure: {
					NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
						AnyView(ChangeSafeThreholdView().embedInNavigation())
					}))
				}))
			]
			
			if let spaceDomain = fam.spaceDomain {
				others.append(
					.init(emoji:"🔗", text: "Snapshot URL", subText: spaceDomain, rightIcon: nil, action: TaggedClosure(id: "space_url_cell", closure: {
						if let url = walletManager.spaceURL() {
							NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
								AnyView(SafariView(url:url))
							}))
						}
					}))
				)
			}
			
			cells = others + cells
		}
		
		return cells
	}
	
	fileprivate func ownerSettingCellModels() -> [SettingCellModel] {
		var tmp = [SettingCellModel]()
		if let fam = currentFamily.first {
			let owners = fam.owners.compactMap({ owner in
				SettingCellModel.ethAddressWithAvatarAndCopy(owner)
			})
			tmp.append(contentsOf: owners)
			
			if walletManager.currentWallet != nil {
				tmp.append(
					.init(icon:.init(systemName: "note.text")?.withRenderingMode(.alwaysTemplate), text: "mem_nick".appLocalizable, subText: "", action: TaggedClosure(id: "nick_name_cell", closure: {
						NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
							AnyView(ChangeNickNameView().embedInNavigation())
						}))
					}))
				)
			}
			
			let addOwnerCell = SettingCellModel(icon: .init(systemName: "plus.circle.fill")?.withRenderingMode(.alwaysTemplate), text: "mem_add".appLocalizable, action: TaggedClosure(id: "add_owner_cell", closure: {
				NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
					AnyView(ChangeSafeThreholdView().embedInNavigation())
				}))
			}))
			tmp.append(addOwnerCell)
		}
		
		return tmp
	}
}

struct SettingViewCell: View {
	
	@Binding var happy:SettingCellModel
	
	private func getRightView() -> some View {
		if let v = happy.rightView?.closure(()) {
			return AnyView(v)
		} else {
			return AnyView(EmptyView())
		}
	}
	
	var body: some View {
		Button {
			if let action = happy.action {
				action.closure(())
			}
		} label: {
			HStack(alignment: .center) {
				if let icon = happy.icon {
					Image(uiImage: icon)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width:22, height:22)
						.foregroundColor(.label)
				}
				if let str = happy.iconURL, let url = URL(string: str) {
					LGImage(source: url, placeholder: {
						Image(systemName: "person.circle")
					},options:[.imageWithFadeAnimation])
					.resizable()
					.cancelOnDisappear(true)
					.aspectRatio(contentMode: .fit)
					.cornerRadius(18.0)
					.frame(width: 36.0, height: 36.0)
                    .padding([.vertical], 6.0)
				}
				if let emoji = happy.emoji {
					Text(emoji)
						.font(.rounded(size: 16.0))
						.frame(width:22, height:22)
				}
				Text(happy.text)
					.font(.rounded(size: 17.0))
					.foregroundColor(.label)
				Spacer()
				if let subText = happy.subText {
					Text(subText)
						.font(.rounded(size: 15.0))
						.foregroundColor(.systemGray.opacity(0.8))
				}
				getRightView()
				if happy.action != nil {
					Image(uiImage: happy.rightIcon ?? UIImage(systemName: "chevron.right")!)
						.resizable()
						.renderingMode(.template)
						.foregroundColor(.appGray)
						.frame(width:iconSize().width,height:iconSize().height)
						.scaledToFit()
//						.aspectRatio(contentMode: .fit)
						.fixedSize()
				}
			}
		}
	}
	
	private func iconSize() -> CGSize {
		return happy.rightIcon != nil ? .init(width: 17.0, height: 17.0) : .init(width: 6.0, height: 10.0)
	}
}
struct Pair<A, B> {
	var one: A
	var two: B
	init(_ one: A, _ two: B) {
		self.one = one
		self.two = two
	}
}

extension Pair: Equatable where A: Equatable, B: Equatable {
	
}

extension Pair: Hashable where A: Hashable, B: Hashable { }

struct SettingCellModel: Identifiable, Hashable {
	
//	static func == (lhs: SettingCellModel, rhs: SettingCellModel) -> Bool {
//		return lhs.emoji == rhs.emoji &&
//		lhs.icon == rhs.icon &&
//		lhs.iconURL == rhs.iconURL &&
//		lhs.text == rhs.text &&
//		lhs.subText == rhs.subText &&
//		lhs.rightIcon == rhs.rightIcon &&
//		lhs.action == rhs.action
//	}
	

	var id: String {
		return UUID().uuidString
	}
	
	var emoji: String?
	var icon: UIImage?
	var iconURL: String?
	var text: String
	var subText: String?
	var rightIcon: UIImage?
	var rightView: TaggedClosure<Void,any View>?//(any View)?
	var action:TaggedClosure<Void,Void>?
	
	static func ethAddressWithAvatarAndCopy(_ address: String) -> Self {
		return SettingCellModel(iconURL:Constant.ethHashAvatar(address: address, length: 56).absoluteString,text: address, subText: "", rightIcon: .init(systemName: "doc.on.doc"),action: TaggedClosure(id: address, closure: {
			let pasteboard = UIPasteboard.general
			pasteboard.string = address
			Task {
				await AppHUD.show("copy_suss".appLocalizable)
			}
		}))
	}
}

struct TaggedClosure<T,R>: Equatable, Hashable {
	let id: String
	let closure: (T) -> R

	static func == (lhs: TaggedClosure, rhs: TaggedClosure) -> Bool {
		return lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

}

struct NavigationConfigurator: UIViewControllerRepresentable {
	var configure: (UINavigationController) -> Void = { _ in }

	func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
		UIViewController()
	}
	func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
		if let nc = uiViewController.navigationController {
			self.configure(nc)
		}
	}

}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}


struct SafariView: UIViewControllerRepresentable {
	
	let url: URL
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
		return SFSafariViewController(url: url)
	}
	
	func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
		
	}
	
}

extension Languages {
	var name: String {
		switch self {
		case .en:
			return "lan_en".appLocalizable
		case .zhHans:
			return "lan_zhs".appLocalizable
		case .deviceLanguage:
			return "color_scheme_system".appLocalizable
		default:
			return self.rawValue
		}
	}
}

struct LanguageSelectView: View {
	
	@EnvironmentObject var languageSettings: LanguageSettings
	
	var body: some View {
		Picker("", selection: $languageSettings.selectedLanguage.animation()) { // 3
			ForEach([Languages.deviceLanguage,
					 Languages.zhHans,
					 Languages.en], id: \.self) { item in // 4
				if let item {
					Text(item.name)
						.foregroundColor(.appBlue)
						.font(.rounded(size: 16.0))
						.bold()
						.addBKG(color: Color(hexString: "F1F1F1"))
						.layoutPriority(1)
				}
			}
		}
		.pickerStyle(.menu)
	}
	
}
