//
//  ChainPicker.swift
//  family-dao
//
//  Created by KittenYang on 1/19/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit

//enum Language : String, CaseIterable { // 1
//	case swift
//	case kotlin
//	case java
//	case javascript
//}

struct ChainPicker: View {
	
	let avaliableChains:[Chain.ChainID] = [.ethereumMainnet,
										  .ethereumGoerli]
	
	@Binding var selectedItem:Chain.ChainID // 2
	
	var body: some View {
		Picker(self.selectedItem.web3Networks.name, selection: $selectedItem) { // 3
			ForEach(avaliableChains, id: \.self) { item in // 4
				Text(item.web3Networks.name) // 5
                    .font(.rounded(size: 16.0))
			}
		}
		.pickerStyle(.menu)
	}
}

struct ChainPicker_Previews: PreviewProvider {
	static var previews: some View {
		XcodePreviewsDevice.previews([.iPhoneSE, .iPhone14ProMax, .iPadAir]) {
			TabView {
				ChainPicker(selectedItem: .constant(.ethereumGoerli))
			}
		}
	}
}
