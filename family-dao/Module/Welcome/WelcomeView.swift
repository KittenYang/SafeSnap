//
//  WelcomeView.swift
//  family-dao
//
//  Created by KittenYang on 9/24/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

struct WelcomeView: View {
	
	@EnvironmentObject var pathManager: NavigationStackPathManager
	
	@FetchRequest(fetchRequest: Family.fetchRequest().selected()) var currentFamily: FetchedResults<Family>
	
	@State var alert: Bool = false
	
	var body: some View {
		GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 5.0) {
                let wid: CGFloat = 900
                let hei = wid * (UIImage(named: "welcome_center")?.size.height ?? 1.0) / (UIImage(named: "welcome_center")?.size.width ?? 1.0)
                InfiniteScroller(contentWidth: wid) {
                    Image("welcome_center")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: wid, height: hei)
                }

				Spacer()
                
                VStack(alignment: .leading, spacing: 12.0) {
                    Text("fasfnew_hofasfafme_name_perospn_dasfnjlndasfas".appLocalizable)
                        .foregroundColor(.white)
                        .font(.rounded(size:38.0, weight: .medium))
                        

                    Text("fasfasffnew_hofasfaffasme_nasssme_perospn_dsafsaasf".appLocalizable)
                        .foregroundColor(.white)
                        .font(.rounded(size: 18.0))
                }
                .fixedSize(horizontal: false, vertical: true)// 文字不自动折行，需要写这一句
                .padding()
                VStack(spacing: 12.0) {
					Button {
						handleImportFamily()
					} label: {
						Text("fasfssneaw_hofdsdasfafme_name_perospn".appLocalizable)
							.solidBackgroundWithCorner(color: .appTheme, idealWidth: proxy.size.width)
					}
					Button {
						handleCreateNewFamily()
					} label: {
						Text("new_home_name_new_casodiaas".appLocalizable)
							.clearBackgroundWhiteBorder(idealWidth: proxy.size.width, color:.white)
					}
					if let _ = currentFamily.first {
						Button {
							alert = true
						} label: {
							Text("fasfnew_hofasfafme_name_perospn_exit_famiaa".appLocalizable)
								.foregroundColor(.white)
								.underline(true, color: .white)
						}
					}
				}
                .padding()
			}
//			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Gradient(colors: [.appGradientRed1, .appGradientRed2]))
            .frame(minWidth: proxy.size.width, minHeight: proxy.size.height, alignment: .bottom)
//			.navigationTitle("欢迎")
//			.navigationBarTitleDisplayMode(.inline)
//			.embedInNavigation(pathManager)
			.alert("fsffsafsafi_areireosure".appLocalizable, isPresented: $alert, actions: {
				Button("sdfas_ssfsnew_home_name_perospn".appLocalizable, role: .destructive, action: {
					alert = false
					if let cur_fam = currentFamily.first {
						Task {
							await WalletManager.logOutFamily(cur_fam)
						}
					}
				})
			})
		}
	}
	
}

extension WelcomeView {
	private func handleImportFamily() {
		pathManager.path.append(AppPage.importFamily)
	}
	
	private func handleCreateNewFamily() {
		pathManager.path.append(AppPage.createNewFamily)
	}
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        XcodePreviewsDevice.previews([.iPhoneSE, .iPadAir]) {
            WelcomeView()
//            GeometryReader { geo in
//                VStack(alignment: .leading) {
//                    InfiniteScroller(contentWidth: 200) {
//                        Rectangle()
//                            .foregroundColor(.red)
//                            .frame(width: 200, height:1600)
//                    }
//                    //                .frame(alignment:.bottom)
//                    Text("dfasfssafasffas")
//                        .font(.largeTitle)
//                    //                Spacer()
//                    Text("dfasfssafasffas")
//                        .font(.largeTitle)
//                    Text("dfasfssafasffas")
//                        .font(.largeTitle)
//                }
//                .frame(minWidth: geo.size.width, minHeight: geo.size.height, alignment: .bottom)
//                //            Spacer()
//            }
        }
    }
}


struct InfiniteScroller<Content: View>: View {
    var contentWidth: CGFloat
    var content: (() -> Content)
    
    @State
    var xOffset: CGFloat = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    content()
                    content()
                }
                .offset(x: xOffset, y: 0)
        }
        .disabled(true)
        .onAppear {
            // 坑：里面刚进来的时候有个 resize 动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                    xOffset = -contentWidth
                }
            }
        }
    }
}
