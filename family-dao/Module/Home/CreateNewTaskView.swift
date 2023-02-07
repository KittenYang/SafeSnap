//
//  CreateNewTaskView.swift
//  family-dao
//
//  Created by KittenYang on 9/23/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import SwiftUIX
import MultiSigKit
import Defaults
import SymbolPicker

struct CreateNewTaskView: View, InputCheckable {
	
	func inputs() -> [[String]] {
		return [
			[self.taskName, "newPorinext_s_recnetfasfsfaf".appLocalizable],
			[self.amount, "sdasdsanewPorinext_s_recnet_sa".appLocalizable],
		]
	}
	
	@State var taskName: String = ""
	@State var amount: String = ""
	@State var saveAsTemplate: Bool = false
	@State var category: String?//Dictionary<String, [StoredAction]>.Element
	
	@Default(.actionCategories) var allCategories
	
	@State var sybomlSheetPresented: Bool = false
	@State var sybomlSheetBKGPresented: Bool = false
	
	@State var selectedSymbol: Symbol? = .init(value: "house")
	@State var selectedSymbolColor = Color.red
	
	let interactor = NetworkAPIInteractor()
	
	var body: some View {
		GeometryReader { proxy in
			VStack(alignment: .center, spacing: 12.0) {
                RoundedText("newsadorindasexd_sda_recnedt".appLocalizable)
					.foregroundColor(Color.label)
					.bold()
				HStack {
					VStack(alignment: .leading) {
						Text("newPorinext_s_recne_sdasdqvfhhkhgt".appLocalizable)
							.font(.rounded(size: 16.0))
							.foregroundColor(Color.appGray9E)
						TextField("nessswPorisnesxt_s_recnesst".appLocalizable, text: $taskName)
                            .font(.rounded(size: 16.0))
							.padding()
							.background(Color.secondarySystemBackground)
							.cornerRadius(12.0)
					}
					if saveAsTemplate {
						Button {
							sybomlSheetPresented = true
						} label: {
							Image(systemName: selectedSymbol!.value)
								.resizable()
								.foregroundColor(.white)
								.scaledToFit()
								.frame(width: 36.0, height: 36.0)
								.padding(.all, 15)
								.background(selectedSymbolColor)
								.cornerRadius(10.0)
								.padding([.leading],25.0)
								.layoutPriority(2)
						}
						.transition(.move(edge: .trailing).combined(with: .opacity))
					}
				}
				if saveAsTemplate {
					Section {
						ColorPicker(selection: $selectedSymbolColor) {
							Text("sadsdnewPodassdrinext_s_recnet".appLocalizable)
								.foregroundColor(Color.appGray9E)
								.font(.rounded(size: 16.0))
						}
					}
					.transition(.move(edge: .top).combined(with: .opacity))
				}
				HStack(alignment:.bottom) {
					VStack(alignment: .leading) {
						Text("monfgnewPorinext_s_recnet".appLocalizable)
							.font(.rounded(size: 16.0))
							.foregroundColor(Color.appGray9E)
						TextField("newPorsppmvbvucinext_s_dasdrecnet".appLocalizable, text: $amount)
                            .font(.rounded(size: 16.0))
							.padding()
							.background(Color.secondarySystemBackground)
							.cornerRadius(12.0)
							.keyboardType(.numberPad)
					}
					Text(WalletManager.shared.currentFamily?.token?.symbol ?? "TOKEN")
						.font(.rounded(size: 18.0))
						.bold()
						.padding([.leading,.bottom],25.0)
//						.frame(width: 65.0, height: 21.0)
						.layoutPriority(2)
				}
				HStack {
					Button {
						saveAsTemplate.toggle()
					} label: {
						HStack(alignment: .center) {
							Circle()
								.frame(width:13, height: 13)
							Text("nehszwPsvgorissnext_s_rsecnet".appLocalizable)
								.font(.rounded(size: 14.0))
						}
						.foregroundColor(saveAsTemplate ? .appTheme : .appGray9E)
						.padding([.top,.bottom], 10.0)
					}
					TaskSwitchView(initial: $category, initialAllSelections: allCategories.compactMap({ $0.name }), showCreateNewCategory: true)
						.frame(maxWidth: .infinity, alignment: .trailing)
						.hidden(!saveAsTemplate)
						.onChange(of: category) { newCateg in
							print("newCateg:\(newCateg ?? "")")
						}
				}
				Button {
					Task {
						await handleCustomTransfer()
					}
				} label: {
					Text("done".appLocalizable)
						.solidBackgroundWithCorner(color: .appTheme, idealWidth: proxy.size.width)
				}
			}
			.animation(.easeInOut(duration: 0.3), value: saveAsTemplate)
			.onAppear {
				category = allCategories.first?.name
			}
			.sheet(isPresented: $sybomlSheetPresented) {
				NavigationView {
					SymbolPickerView(selectedSymbol: $selectedSymbol, selectedColor: .black)
						.navigationTitle("newPorinext_s_reciconslececdenet".appLocalizable)
						.navigationBarTitleDisplayMode(.inline)
				}
			}
//			.sheet(isPresented: $sybomlSheetBKGPresented) {
//				ColorPicker("选择背景色", selection: $selectedSymbolColor)
//			}
		}
	}
	
	private func handleCustomTransfer() async {
		guard inputFilled() else {
			return
		}
		
		//保存模板
		if saveAsTemplate {
			if let category,
				  let selectedSymbolColor = selectedSymbolColor.toUIColor()?.hexString()  {
				Defaults.addCategory(category, [.init(name: taskName, colorHexString: selectedSymbolColor, iconSymbolName: selectedSymbol!.value, amount: amount, count: 1)])
			} else {
				AppHUD.show("newPorinext_s_recnetPPm_ome_Cloe".appLocalizable)
				return
			}
		}
		
		CreateNewTaskView.hideKeyboard()
		
		if await FaceID() {
			debugPrint("Face ID 认证通过！")
			guard let _amount = amount.convertToBigUInt(), !amount.isEmpty else {
				return
			}
			let txHashInfo = await self.interactor.proposeAction(value: _amount)
			await MainActor.run {
				WalletManager.shared.shouldReloadQueue.toggle()
			}
			if let _ = txHashInfo.0?.txId {
				AppHUD.show("send_ok".appLocalizable)
			} else if let status = txHashInfo.1 {
				AppHUD.show(status.desc)
			}
			SheetManager.dismissAllSheets()
		}
	}
	
}

struct TaskSwitchView<T:StringProtocol>: View {
	
	@Binding var initial: T?
	
	@State var alertIsPresented: Bool = false
	
	@State var selections:[T?]

	// 实现支持新建类别
	var showCreateNewCategory: Bool
	
	init(initial: Binding<T?>, initialAllSelections:[T], showCreateNewCategory: Bool) {
		_selections = State(initialValue: initialAllSelections)
		self._initial = initial
		self.showCreateNewCategory = showCreateNewCategory
	}
	
	var body: some View {
		HStack(spacing: 0.0) {
			Text("newPorinext_s_recnet_leiisnx".appLocalizable)
				.font(.rounded(size: 16.0))
				.foregroundColor(.label)
			if let str = initial {
				Picker(str, selection: $initial) { // 3
					ForEach(selections, id: \.self) { item in // 4
						if let item {
							Text(item)
								.foregroundColor(.appBlue)
								.font(.rounded(size: 16.0))
								.bold()
								.addBKG(color: Color(hexString: "F1F1F1"))
								.layoutPriority(1)
						}
					}
				}
				.pickerStyle(.menu)
				.layoutPriority(2)
			}
			if showCreateNewCategory {
				Button {
					alertIsPresented = true
				} label: {
					Text("newPorinext_s_recnet_newsdas".appLocalizable)
				}				
			}
		}
		.modifier(if: showCreateNewCategory, then: { v in
			v.textFieldAlert(
				isPresented: $alertIsPresented,
				title: "newPorinext_s_recnet_mnasdpasnvsv".appLocalizable,
				text: "",
				placeholder: "",
				action: { newText in
					if let newText = newText as? T, !newText.isEmpty {
						self.selections.append(newText)
						initial = newText
					}
				}
			)
		})
	}
}

struct CreateNewTaskView_Previews: PreviewProvider {
	static var previews: some View {
		CreateNewTaskView(category: "newPorinext_s_recnet_sture".appLocalizable)
	}
}
