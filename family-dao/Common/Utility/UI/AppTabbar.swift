//
//  AppTabbar.swift
//  family-dao
//
//  Created by KittenYang on 9/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import Introspect
import Defaults

enum AppTabbarItem:Hashable,Tabbable,Identifiable, Equatable {

	var id: String {
		switch self {
		case .first: return "first"
		case .second: return "second"
		case .third: return "third"
		case .fourth:
			return "fourth"
		case .setting:
			return "app_settings"
		}
	}

	static func == (lhs: AppTabbarItem, rhs: AppTabbarItem) -> Bool {
		return lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	var customHandler: ((any Tabbable) -> Void)? {
		switch self {
		case .first:
			return nil
		case .second(let handler):
			return handler
		case .third:
			return nil
		case .fourth,.setting:
			return nil
		}
	}
	
	case first
	case second(handler:((any Tabbable) -> Void)?)
	case third
	case fourth
	case setting
	
	var tabiconImageName: String {
		switch self {
		case .first: return "tab_home"//"house.fill"
		case .second: return ""
		case .third: return "tab_queue"//"circle.grid.2x1.left.filled"
		case .fourth: return "tab_proposals"// "circle.grid.2x1.right.filled"//"ticket.fill"
		case .setting: return "tab_settings"//"gearshape.fill"
		}
	}
	
	var title: String {
		switch self {
		case .first: return "page_home".appLocalizable
		case .second: return "page_task".appLocalizable
		case .third: return "page_queue".appLocalizable
		case .fourth: return "page_proposal".appLocalizable
		case .setting: return "page_setting".appLocalizable
		}
	}
}

struct AppTabbar: View {
	
	@Default(.firstInstall_user) var firstInstall_user
	@Default(.firstInstall_family) var firstInstall_family
	
	@Namespace private var namespace

	@State var flag: Bool = true
	
	@Environment(\.colorScheme) var systemColorScheme
	@EnvironmentObject var sett: UserSettings
	
	@State private var selection: AppTabbarItem = .first
//	@State private var visibility: TabBarVisibility = .visible
	
	@StateObject var nvspm = NavigationStackPathManager.shared
	@StateObject var wm = WalletManager.shared
	
	@StateObject var snapshotGlobal = SnapshotManager.shared.global
	
	@Environment(\.managedObjectContext) var coreDataContext
	@FetchRequest(fetchRequest: Family.fetchRequest().selected()) var currentFamily: FetchedResults<Family>
	
	private var currentUser: Wallet? {
		wm.currentWallet
	}
	
	init() {
		print("[AppTabbar init!!]")
	}
	
	var body: some View {
		GeometryReader { proxy in
			TabBar(selection: $selection, visibility: .constant(.visible), items: [
				.first,
				.third,
				.second(handler: { item in
					flag.toggle()
					HapticManager.tic()
				}),
				.fourth,
				.setting
			],flag: $flag, namespace: namespace) {
				NewHomeView()
					.tag(AppTabbarItem.first)
				QueueView()
					.tag(AppTabbarItem.third)
				Color.clear
					.tag(AppTabbarItem.second(handler: nil))
				ProposalListView()
					.tag(AppTabbarItem.fourth)
				SettingView()
					.embedInNavigation()
					.tag(AppTabbarItem.setting)
			}
			.tabBar(style: CustomTabBarStyle())
			.tabItem(style: CustomTabItemStyle(namespace: namespace))
			.introspectTabBarController { (UITabBarController) in
				UITabBarController.tabBar.layer.opacity = 0.0
			}
			.colorScheme(sett.selectedAppearance.colorScheme ?? systemColorScheme)
			.overlay(alignment:.bottom, content: {
				ZStack {
					if flag {
						RoundedRectangle(cornerRadius: flag ? 20.0 : 0.0)
							.matchedGeometryEffect(id: "center_circle", in: namespace)
							.foregroundColor(.appTheme)
							.frame(width: flag ? 40.0 : proxy.size.height, height: flag ? 40.0 : 250)
							.allowsHitTesting(false)
							.overlay {
								ZStack {
									Color.appTheme
										.frame(width: 10, height: 10)
										.allowsHitTesting(false)
										.matchedGeometryEffect(id: "center_circle_haha", in: namespace)
										.opacity(flag ? 1.0 : 0.0)
									Image(systemName: "plus")
										.fontWeight(.bold)
										.foregroundColor(.white)
										.rotationEffect(Angle(degrees: flag ? 0.0 : 225.0))
										.matchedGeometryEffect(id: "center_circle_scrollview", in: namespace)
								}
							}
					} else {
						ZStack(alignment: .bottom) {
							Color.black.opacity(0.4)
								.onTapGesture {
									flag.toggle()
								}
							CreateNew(namespace: namespace, flag: $flag)
								.frame(width: flag ? 40.0 : proxy.size.width, height: flag ? 40.0 : 250)
								.opacity(flag ? 0.0 : 1.0)
						}
					}
				}
				.ignoresSafeArea(edges:.all)
				.blurWithZoomSmall(enable: NavigationStackPathManager.shared.tabbarDimming, scale: false)
//				.scaleEffect(NavigationStackPathManager.shared.tabbarDimming ? 0.8 : 1.0)
//				.blur(radius: NavigationStackPathManager.shared.tabbarDimming ? 20.0 : 0.0)
//				.animation(.easeInOut(duration: 0.25), value: NavigationStackPathManager.shared.tabbarDimming)
			})
			.animation(.easeInOut(duration: 0.2), value: flag)
			.sheetWithContainer(isPresented: .constant(firstInstall_user && currentUser == nil && WalletManager.shared.currentChainLoadingStatus == .end), {
				CreateNewUser()
					.embedInNavigation()
					.onDisappear {
						firstInstall_user = false
					}
			})//坑：写在越前面的 sheet 会越先 present，这里就会先 present 新建用户的 sheet
			.sheetWithContainer(isPresented: .constant(firstInstall_family && currentFamily.first == nil && WalletManager.shared.currentChainLoadingStatus == .end)) {
				WelcomeView()
					.embedInNavigation()
					.onDisappear {
						firstInstall_family = false
					}
			}
			.sheetWithContainer(isPresented: $snapshotGlobal.isCreatingSpace) {
				SpaceCreateHackerView()
					.embedInNavigation()
			}
			.sheetWithModel(model: $nvspm.showSheetModel)
			.onAppear {
				// correct the transparency bug for Tab bars
				let tabBarAppearance = UITabBarAppearance()
				tabBarAppearance.configureWithDefaultBackground()
				UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
				// correct the transparency bug for Navigation bars
				let navigationBarAppearance = UINavigationBarAppearance()
				navigationBarAppearance.configureWithOpaqueBackground()
				UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
			}
			.environmentObject(WalletManager.shared)
			.environment(\.currentFamily, currentFamily.first)
		}
	}
}

extension EnvironmentValues {
	var currentFamily: Family? {
		get { return self[CurrentFamilyKey.self] }
		set { self[CurrentFamilyKey.self] = newValue }
	}
}

public struct CurrentFamilyKey: EnvironmentKey {
	public static let defaultValue: Family? = nil
}

struct AppTabbar_Previews: PreviewProvider {
	static var previews: some View {
		AppTabbar()
			.background(.gray)
	}
}


struct CustomTabBarStyle: TabBarStyle {
	
	private let indicatorHeight:CGFloat = 4.0
	private var tabHeight:CGFloat {
		return 49.0 - indicatorHeight
	}
	
	public func tabBar(with geometry: GeometryProxy, itemsContainer: @escaping () -> AnyView) -> some View {
		VStack(spacing: 0.0) {
			VStack(alignment: .underlineCenter,spacing: 0.0) { // 对齐动画关键1
				itemsContainer()
					.frame(height: tabHeight)
				Rectangle()
					.frame(width:20 /*self.bindedWidths[self.selectedItem.selection]?.size.width*/,  height: indicatorHeight)
					.foregroundColor(.appTheme)
					.cornerRadius(indicatorHeight/2.0)
					.animation(.easeInOut(duration: 0.2))
					.padding(.bottom, geometry.safeAreaInsets.bottom)
			}
			.background(.ultraThinMaterial)
			.frame(height: tabHeight + indicatorHeight + geometry.safeAreaInsets.bottom)
			.overlay {
				Color.black
					.opacity(NavigationStackPathManager.shared.tabbarDimming ? 0.2 : 0.0)
					.animation(.linear, value: NavigationStackPathManager.shared.tabbarDimming)
			}
		}
		.blurWithZoomSmall(enable: NavigationStackPathManager.shared.tabbarDimming, scale: false)
//		.scaleEffect(NavigationStackPathManager.shared.tabbarDimming ? 0.8 : 1.0)
//		.blur(radius: NavigationStackPathManager.shared.tabbarDimming ? 20.0 : 0.0)
//		.animation(.easeInOut(duration: 0.25), value: NavigationStackPathManager.shared.tabbarDimming)
	}
	
}

extension View {
	func blurWithZoomSmall(enable:Bool, scale:Bool) -> some View {
		self
			.blur(radius: enable ? 20.0 : 0.0)
//			.modifier(if: scale, then: { $0.scaleEffect(enable ? 0.9 : 1.0) })
			.animation(.easeInOut(duration: 0.25), value: enable)
	}
}

struct CustomTabItemStyle: TabItemStyle {
    
    let namespace: Namespace.ID
    
    public func tabItem(item: any Tabbable, isSelected: Bool, flag: Binding<Bool>) -> some View {
        ZStack {
            Image(item.tabiconImageName)
//            Image(systemName: item.icon)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isSelected ? .appTheme : .gray)
                .aspectRatio(contentMode: .fit)
                .modify(if: item as! AppTabbarItem == AppTabbarItem.second(handler: nil), transform: { v in
                    v.frame(width: 30.0, height: 30.0)
                        .foregroundColor(.white)
                        .padding(8.0)
                        .opacity(flag.wrappedValue ? 1.0 : 0.0)
                })
                .modify(if: item as! AppTabbarItem != AppTabbarItem.second(handler: nil), transform: { v in
                    v.frame(width: 25.0, height: 25.0)
                })
            
        }
        .frame(width: 50, height: 50)
        .contentShape(Rectangle())
    }
    
}

extension View {
	func animate(using animation: Animation = .easeInOut(duration: 1), _ action: @escaping () -> Void) -> some View {
		return onAppear {
			withAnimation(animation) {
				action()
			}
		}
	}
	
	func animateForever(using animation: Animation = .easeInOut(duration: 1), autoreverses: Bool = false, _ action: @escaping () -> Void) -> some View {
		let repeated = animation.repeatForever(autoreverses: autoreverses)
		
		return onAppear {
			withAnimation(repeated) {
				action()
			}
		}
	}
}

extension View {
	func glow(color: Color = .red, radius: CGFloat = 20) -> some View {
		self
			.shadow(color: color, radius: radius / 3)
			.shadow(color: color, radius: radius / 3)
			.shadow(color: color, radius: radius / 3)
	}
	
	func addGlowEffect(color:Color,color1:Color, color2:Color, color3:Color) -> some View {
		self
			.foregroundColor(color)
			.background {
				self
					.foregroundColor(color1).blur(radius: 0).brightness(0.8)
			}
			.background {
				self
					.foregroundColor(color2).blur(radius: 4).brightness(0.35)
			}
			.background {
				self
					.foregroundColor(color3).blur(radius: 2).brightness(0.35)
			}
			.background {
				self
					.foregroundColor(color3).blur(radius: 12).brightness(0.35)
				
			}
	}
}

