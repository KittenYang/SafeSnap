//
//  AddingOptionRowView.swift
//  family-dao
//
//  Created by KittenYang on 11/26/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

class AnyObservableObject<Value>: ObservableObject {
	
	@Published public var storage: Value

	public init(_ storage: Value) {
		self.storage = storage
	}
	
}

class ValueStore<T:Hashable>: ObservableObject, Hashable {
	static func == (lhs: ValueStore<T>, rhs: ValueStore<T>) -> Bool {
		return lhs.options == rhs.options && lhs.maxOptions == rhs.maxOptions && lhs.placeHolderTxt == rhs.placeHolderTxt && lhs.confirmActionTxt == rhs.confirmActionTxt
	}
	
	
	@Published var options:[T]// = [T]()
	@Published var maxOptions: Int = 0
	
	var placeHolderTxt: T
	var confirmActionTxt: T
	var grayBackgound: Bool
	var icon:UIImage?
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(options)
	}
	
	init(placeHolderTxt: T, confirmActionTxt: T, grayBackgound: Bool,icon:UIImage?,options:[T]?) {
		self.placeHolderTxt = placeHolderTxt
		self.confirmActionTxt = confirmActionTxt
		self.grayBackgound = grayBackgound
		self.icon = icon
		self.options = options ?? [T]()
	}
	
	static func atLeastMember(_ options:[T]) -> Int {
//		if options.count > 1 {
//			return 2 // 至少两个成员
//		}
		if options.count > 0 {
			return 1
		}
		return 0
	}
	
	func handleAddNewOption(_ newOption: T) {
		if !options.contains(newOption) {
			options.append(newOption)
			correctxMaxOption()
		}
	}
	
	func correctxMaxOption() {
		maxOptions = max(min(options.count, maxOptions), Self.atLeastMember(options))
	}
	
	func handleRemoveNewOptionAt(index: Int) {
		if index < options.count {
			AddingRowView.hideKeyboard()
			options.remove(at: index)
			correctxMaxOption()
		}
	}
	
}

struct AddingRowView: View {
	
	@ObservedObject var store: ValueStore<String>

	@FocusState private var focusedField: Int?
	
	init(store:ValueStore<String>) {
		self.store = store
	}
	var body: some View {
		VStack(spacing: 10.0) {
			if !store.options.isEmpty {
				ForEach(Array(zip(store.options.indices, store.options)), id: \.0) { index, member in
					HStack {
						if let image = store.icon {
							Image(uiImage: image)
								.renderingMode(.template)
								.colorMultiply(.label)
						}
						TextField("\(store.placeHolderTxt)\(index+1)",text: .init(get: {
							if index < store.options.count {
								return store.options[index]
							}
							return ""
						}, set: { newValue in
							store.options[index] = newValue
						})/*.animation()*/)
						.lineLimit(2)
						.focused($focusedField, equals: index)
						.foregroundColor(.appGray9E)
						.if(store.grayBackgound){
							$0.padding().background(Color.appGrayF4).cornerRadius(12.0)
						}
						Spacer()
						Button {
							store.handleRemoveNewOptionAt(index: index)
						} label: {
							Image(systemName: "xmark.circle.fill")
								.foregroundColor(.appGrayEA)
						}.buttonStyle(PlainButtonStyle())
						
					}
					.tag(index)
					Divider()
				}
				.transition(.opacity.combined(with: .move(edge: .top)))
				.animation(.easeOut(duration:0.25), value: store.options)
			}
			Button {
				store.handleAddNewOption("")
				focusedField = store.options.count - 1
			} label: {
				HStack {
					Image(systemName: "plus.circle")
					Text(store.confirmActionTxt)
				}.foregroundColor(.appTheme)
			}.buttonStyle(PlainButtonStyle())
		}
	}

}
