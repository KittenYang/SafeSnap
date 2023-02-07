//
//  CreateNew.swift
//  family-dao
//
//  Created by KittenYang on 11/26/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

public enum NewAction {
	case newTask
	case newProposal
	case newFamily
	case newUser
	case newTransfer
	
	var displayName:String {
		switch self {
		case .newTask:
			return "fasfnew_hofaffsafsfafme_fsaname_perospnfsafa".appLocalizable
		case .newProposal:
			return "ffasfasfnew_hofsafasfafme_name_perospn".appLocalizable
		case .newFamily:
			return "fassssfnew_hosssfasfasffme_name_ffperospn".appLocalizable
		case .newUser:
			return "fasfnew_hofssasfassfme_ssname_perssospnss".appLocalizable
		case .newTransfer:
			return "fasssfnew_hofasfddafmef_name_perosfsafsapn".appLocalizable
		}
	}
	
	var iconSymbolName: String {
		switch self {
		case .newProposal:
			return "text.aligncenter"
		case .newTask:
			return "circle.dashed.inset.filled"
		case .newFamily:
			return "person.and.background.dotted"
		case .newUser:
			return "face.smiling"
		case .newTransfer:
			return "brain.head.profile"
		}
	}
	
	var colorHex: String {
		switch self {
		case .newProposal:
			return "23AB01"
		case .newTask:
			return "5AC8FA"
		case .newFamily:
			return "FB5858"
		case .newUser:
			return "FFCB14"
		case .newTransfer:
			return "5AC8FA"
		}
	}
}

struct CreateNew: View {
	
	var recentActions: [NewAction] = [.newTask
									  ,.newProposal
									  ,.newFamily
									  ,.newUser
//									  ,.newTransfer
	]
	
	let namespace: Namespace.ID
	
	var flag: Binding<Bool>
	
    var body: some View {
		ZStack(alignment: .top) {
			RoundedRectangle(cornerRadius: 25.0)
				.foregroundColor(.appTheme)
//				.foregroundColor(.appBkgColor)
				.overlay(alignment: .top) {
					Button {
						flag.wrappedValue.toggle()
					} label: {
						Image(systemName: "xmark.circle.fill")
							.resizable()
							.renderingMode(.template)
							.foregroundColor(.white)
							.frame(width: 30.0, height: 30.0)
							.rotationEffect(Angle(degrees: flag.wrappedValue ? 225.0 : 0.0))
					}
					.offset(y:-30.0-14.0)
					.matchedGeometryEffect(id: "center_circle_scrollview", in: namespace)
				}
				.matchedGeometryEffect(id: "center_circle", in: namespace)
			ScrollView(.horizontal, showsIndicators: false) {
				LazyHGrid(rows: [GridItem(.flexible())], alignment: .center, spacing: 15.0, pinnedViews: [.sectionHeaders]) {
					ForEach(recentActions, id: \.self) { action in
						Button {
							sendAction(action)
						} label: {
							VStack {
								Image(systemName: action.iconSymbolName)
									.resizable()
									.scaledToFit()
									.foregroundColor(.white)
									.frame(width: 22.0, height: 22.0)
									.padding(.all,7.0)
									.background(Color(hexString: action.colorHex))
									.cornerRadius(5.0)
								Text(action.displayName)
									.font(.rounded(size: 17.0))
									.foregroundColor(.white)
							}
						}
						.buttonStyle(ScaleButtonStyle())
					}
				}.padding([.leading,.trailing],20.0)
			}
			.matchedGeometryEffect(id: "center_circle_haha", in: namespace)
			.padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0)
		}
//		.background(.appBkgColor)
		.onAppear {
			withAnimation(.easeInOut(duration: 0.35)) { flag.wrappedValue = false }
		}
		.onDisappear {
			withAnimation(.easeInOut(duration: 0.35)) { flag.wrappedValue = true }
		}
//		.hidden(AppTabbar.flag)
//		.animation(.easeInOut(duration: 0.35), value: AppTabbar.flag)
    }
	
	@MainActor private func sendAction(_ action: NewAction)  {
		SheetManager.dismissAllSheets {
			switch action {
			case .newProposal:
				SheetManager.showSheetWithContent(heightFactor:0.7) {
					CreateNewProposalView(voteSystem:SnapshotManager.VotingSystem.single_choice.name)
						.padding()
				}
			case .newTask:
				SheetManager.showSheetWithContent(heightFactor:0.7) {
					CreateNewTaskView()
						.padding()
				}
			case .newFamily:
				NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
					AnyView(CreateNewFamily().embedInNavigation())
				}))
			case .newUser:
				NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
					AnyView(CreateNewUser().embedInNavigation())
				}))
			case .newTransfer:
				break
			}
		}
	}
	
}

struct BiteCircle: Shape {
	func path(in rect: CGRect) -> Path {
		let offset = rect.maxX - 26
		let crect = CGRect(origin: .zero, size: CGSize(width: 26, height: 26)).offsetBy(dx: offset, dy: offset)
		
		var path = Rectangle().path(in: rect)
		path.addPath(Circle().path(in: crect))
		return path
	}
}

struct CreateNew_Previews: PreviewProvider {
	@Namespace private static var namespace
    static var previews: some View {
		CreateNew(namespace: namespace, flag: .constant(false))
			.frame(width: 200, height: 150)
    }
}
