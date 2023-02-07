//
//  DeviceSafeInfoView.swift
//  family-dao
//
//  Created by KittenYang on 8/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import web3swift
import LonginusSwiftUI

/*
 当前家庭、当前用户
 */
struct WalletInfoConfiguration {
	var nameFont: Font
	var addressFont: Font
	var addressIndexFromStart: Int
	var avatar: any View
	
	@ViewBuilder
	static func avatarView(_ author: String) -> some View {
		LGImage(source: Constant.ethHashAvatar(address: author, length: 80), placeholder: {
			Image(systemName: "person.circle")
		},options:[.imageWithFadeAnimation])
		.resizable()
		.cancelOnDisappear(true)
		.aspectRatio(contentMode: .fit)
	}
	
	static func largeWithAddress(_ address: String?) -> WalletInfoConfiguration {
		var large = WalletInfoConfiguration.large()
		if let address {
			large.avatar =
			avatarView(address)
				.frame(width: 40.0, height: 40.0)
				.cornerRadius(20)
		}
		return large
	}
	
	static func large() -> Self {
		WalletInfoConfiguration(nameFont: .rounded(size: 17.0), addressFont: .rounded(size: 15.0), addressIndexFromStart: 10, avatar: avatarView(WalletManager.shared.currentFamily?.address ?? "").frame(width: 40.0, height: 40.0).cornerRadius(20))
	}
	
	static func small() -> Self {
		WalletInfoConfiguration(nameFont: .rounded(size: 14.0), addressFont: .rounded(size: 13.0), addressIndexFromStart: 6, avatar: avatarView(WalletManager.shared.currentWallet?.address ?? "").frame(width: 20.0, height: 20.0).cornerRadius(10))
	}
	
	init(nameFont: Font, addressFont: Font, addressIndexFromStart: Int, avatar: any View) {
		self.nameFont = nameFont
		self.addressFont = addressFont
		self.addressIndexFromStart = addressIndexFromStart
		self.avatar = avatar
	}

}

struct CurrentFamilyInfoNavView: View {
	
//	static let topPaddingInset: Double = 60.0
	
	@Binding var family: FamilyViewModel?
	@Binding var wallet: Wallet?
	@Binding var hide: Bool
	
	static let initialHeight: CGFloat = 50.0
	
	// 0~1
	@Binding var scrollOffsetPercent:CGFloat// = CurrentFamilyInfoNavView.initialHeight
	
	let blurRadius = 10.0
	var blurRadiusOffsetBottom: Double {
		blurRadius + 5.0
	}
	var blurRadiusOffsetTop: Double {
		blurRadius * 2.0
	}
	
	var realHeight: CGFloat {
		return CurrentFamilyInfoNavView.initialHeight-20*scrollOffsetPercent
	}
	
	var body: some View {
		GeometryReader { proxy in
			ZStack(alignment: .top) {
				ZStack(alignment: .top) {
					Group {
						if WalletManager.shared.currentChainLoadingStatus != ChainLoadingStatus.end {
							HStack {
								ProgressView()
								Text(WalletManager.shared.currentChainLoadingStatus.statusDesc)
                                    .font(.rounded(size: 16.0))
							}
						} else {
							WalletInfoView(walletName: .constant(family?.name ?? "newPorinext_sfamilr".appLocalizable), wallet: .constant(family?.multiSigAddress), configuration: .constant(.large()), tapGestureEnable: true)
								.id(family?.multiSigAddress.address ?? "")
								.transition(.blur)
								.overlay(alignment: .trailing) {
									FloatingView(wallet: $wallet)
										.frame(width:100.0, height:realHeight*0.5, alignment: .trailing)
								}
						}
					}
					.padding([.leading,.trailing],15.0)
				}
				.frame(height:realHeight)
				.scaleEffect(1-0.09*scrollOffsetPercent)
			}
			.frame(height:CurrentFamilyInfoNavView.initialHeight,alignment: .top)
			.background(alignment: .bottom) {
				Color.clear
					.edgesIgnoringSafeArea(.top)
					.frame(width: proxy.size.width, height: CurrentFamilyInfoNavView.initialHeight+(UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0)+blurRadiusOffsetTop+blurRadiusOffsetBottom)
					.background(.ultraThinMaterial)
					.blur(radius: blurRadius)
					.offset(y:blurRadiusOffsetBottom)
			}
		}
	}
	
}

struct WalletInfoView: View {

	@Binding var walletName: String?
	@Binding var wallet: EthereumAddress?
	@Binding var configuration: WalletInfoConfiguration
	let tapGestureEnable: Bool
	
	var body: some View {
		ZStack {
			HStack(alignment: .center) {
				AnyView(configuration.avatar)
				VStack(alignment: .leading) {
					if let walletName = walletName {
						Text(walletName)
							.font(configuration.nameFont)
					}
					if let wallet = wallet {
						Text(wallet.address.replacingRange(indexFromStart: configuration.addressIndexFromStart, indexFromEnd: 4))
							.font(configuration.addressFont)
							.foregroundColor(.gray)
					}
				}
				Spacer(minLength: 0.0)
			}
		}
		.tapGestureIfNeeded(tapGestureEnable) { _ in
			NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
				AnyView(WelcomeView().embedInNavigation())
			}))
		}
		.longPressGestureIfNeeded(tapGestureEnable) {
			let pasteboard = UIPasteboard.general
			pasteboard.string = wallet?.address
			AppHUD.show("copy_suss".appLocalizable)
		}

	}
}

extension View {
	@ViewBuilder
	func tapGestureIfNeeded(_ enable: Bool, perform: @escaping (CoreFoundation.CGPoint) -> Void) -> some View {
		if enable {
			if #available(iOS 16.0, *) {
				self.onTapGesture(perform: perform)
			} else {
				onTapGesture {
					perform(.zero)
				}
			}
		} else {
			self
		}
	}
	
	@ViewBuilder
	func longPressGestureIfNeeded(_ enable: Bool, perform: @escaping () -> Void) -> some View {
		if enable {
			self.onLongPressGesture(perform: perform)
		} else {
			self
		}
	}
}

struct FloatingView: View {
	
	@Binding var wallet: Wallet?
	
//	@EnvironmentObject var pathManager: NavigationStackPathManager
	
	var noAccountConfig: WalletInfoConfiguration {
		var configutation = WalletInfoConfiguration.small()
		configutation.avatar = Image(systemName: "questionmark.circle")
		return configutation
	}
	
	var body: some View {
//		NavigationLink(value: AppPage.createNewUser) {
		BlurButton(uiImage: nil/*UIImage(systemName: "person.crop.circle")?.withTintColor(.label)*/, text: wallet?.name ?? "newPorinext_sloginlog".appLocalizable, subText: nil/*wallet?.address.replacingRange(indexFromStart: 6, indexFromEnd: 4)*/, baseFontSize: 13.0) {
			NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
				AnyView(CreateNewUser().embedInNavigation())
			}))
		}
//		BlurButton {
//		} label: {
//			ZStack {
//				Rectangle()
//					.cornerRadius(30)
//					.frame(width: 168, height: 34.0)
//					.foregroundColor(.white)
//					.shadow(color: .black.opacity(0.1), radius: 8.0)
//				WalletInfoView(walletName: .constant(wallet?.name), wallet: .constant(wallet != nil ? wallet?.ethereumAddress : nil), configuration: .constant(wallet == nil ? noAccountConfig : .small), tapGestureEnable: false)
//					.frame(width: 150,height: 20.0)
//			}
////		}
//		}
	}
}

//struct TopCurrentFamilyModifer: ViewModifier {
//
//	@Binding var offsetPercent: CGFloat
//
//	@Environment(\.currentFamily) var currentFamily: Family?
//	@EnvironmentObject var walletManager: WalletManager
//
//	func body(content: Content) -> some View {
//		content
//			.safeAreaInset(edge: .top, content: {
//				CurrentFamilyInfoNavView(family: .constant(FamilyViewModel(managedObject:currentFamily)), wallet: $walletManager.currentWallet, hide: .constant(false), scrollOffsetPercent: $offsetPercent)
//			})
//	}
//}
//

struct DynamicTopCurrentFamilyModifer: ViewModifier {
	
	@Binding var listOffsetPercent: CGFloat
	
	@FetchRequest(fetchRequest: Family.fetchRequest().selected()) var currentFamily: FetchedResults<Family>

	@EnvironmentObject var walletManager: WalletManager
	
	func body(content: Content) -> some View {
		ZStack(alignment: .top) {
			content
				.safeAreaInset(edge: .top, content: {
					Color.clear.frame(height: CurrentFamilyInfoNavView.initialHeight)
				})
				
			CurrentFamilyInfoNavView(family: .constant(FamilyViewModel(managedObject:currentFamily.first)), wallet: $walletManager.currentWallet, hide: .constant(false), scrollOffsetPercent: $listOffsetPercent)
		}
		.coordinateSpace(name: "home_list")
	}
	
	struct Anchor: ViewModifier {
		
		@Binding var listOffsetPercent: CGFloat
		
		func body(content: Content) -> some View {
			content
				.overlay(alignment: .topLeading) {
					Color.clear.frame(width: 100, height: 40)
						.background(CGRectGeometry(coordinateSpaceName: "home_list"))
						.onPreferenceChange(CGRectPreferenceKey.self, perform: { newRect in
							let initial = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0) + CurrentFamilyInfoNavView.initialHeight + 8.0
							let all: CGFloat = 150.0
							let correctV = EasingFunctionEaseInOutCubic((initial - newRect.minY)/all)
							let diff = max(0.0, correctV)
							if diff <= 1.0 && diff >= 0 {
								let percent = min(1.0, diff)
								listOffsetPercent = percent
								print("percent：\(percent)")
							}
						})
				}
		}
	}
}

extension View {
	func gradientBlurTop() -> some View {
		self.padding(.top,15.0)  // 渐变模糊顶部留白
	}
}
