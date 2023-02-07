//
//  CurrentBalanceCell.swift
//  family-dao
//
//  Created by KittenYang on 8/27/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import NetworkKit

struct CurrentBalanceCell: View {
	var title: String
	var rightText: String
	
	var body: some View {
		HStack {
			Text(title)
				.foregroundColor(Color.label)
			Spacer()
			Text(rightText)
				.foregroundColor(Color.appGreen)
				.bold()
		}
        .font(.rounded(size: 17.0, weight: .medium))
	}
}

struct OtherOwnerBalanceCell: View {
	var title: String
	var rightText: String
	
	var body: some View {
		HStack {
			Text(title)
				.foregroundColor(Color.appGray)
			Spacer()
			Text(rightText)
				.foregroundColor(Color.appGrayMiddle)
				.bold()
        }
        .font(.rounded(size: 16.0, weight: .medium))
	}
}

struct CurrentBalanceCell_Previews: PreviewProvider {
    static var previews: some View {
			CurrentBalanceCell(title: "", rightText: "")
    }
}
