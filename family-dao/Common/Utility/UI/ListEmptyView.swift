//
//  ListEmptyView.swift
//  family-dao
//
//  Created by KittenYang on 1/8/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import NetworkKit

struct ListEmptyView: View, RetryActionable {

	var retryAction: ((_ force: Bool) async -> Void)?
	
	var body: some View {
		VStack(spacing: 5.0) {
			Image("error_center")
				.resizable()
                .frame(minWidth: 0.0,maxWidth: 100, minHeight: 0.0, maxHeight: 100)
                .padding(.bottom,8.0)
			Text("empty_datas".appLocalizable)
                .font(.rounded(size: 28.0))
				.foregroundColor(.systemGray)
				.multilineTextAlignment(.center)
				.padding(.bottom, 30)
			BlurButton(uiImage: nil, text: "retry_text".appLocalizable, subText: nil, baseFontSize: 16.0, action: {
				await retryAction?(true)
			})
//			Button(action: retryAction, label: { Text("Retry").bold() })
		}
	}
}

struct SectionEmptyView: View {
	
	var body: some View {
		VStack(spacing: 5.0) {
			Image("error_center")
				.resizable()
                .frame(minWidth: 0.0,maxWidth: 100, minHeight: 0.0, maxHeight: 100)
                .padding(.bottom,5.0)
			HStack(spacing: 0.0) {
				Spacer()
				Text("empty_datas".appLocalizable)
                    .font(.rounded(size: 20.0))
					.foregroundColor(.systemGray)
					.multilineTextAlignment(.center)
					.padding(.bottom, 30)
				Spacer()
			}
		}
	}
}


struct ListEmptyView_Previews: PreviewProvider {
    static var previews: some View {
		ListEmptyView(retryAction: { force in
			
		})
    }
}
