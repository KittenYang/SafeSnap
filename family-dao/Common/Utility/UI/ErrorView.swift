//
//  ErrorView.swift
//  family-dao
//
//  Created by KittenYang on 9/8/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import NetworkKit

struct ErrorView: View, RetryActionable {
	let error: Error?
//	let retryAction: () -> Void
	var retryAction: ((_ force: Bool) async -> Void)?
	
	var body: some View {
		VStack(spacing: 1.0) {
			Image("error_center")
				.resizable()
                .frame(minWidth: 0.0,maxWidth: 100, minHeight: 0.0, maxHeight: 100)
			Text("send_failed_reason".appLocalizable)
                .font(.rounded(size: 16.0))
			Text(error?.localizedDescription ?? "send_failed_reason_unknow".appLocalizable)
                .font(.rounded(size: 13.0))
				.multilineTextAlignment(.center)
				.padding(.bottom, 30)
			BlurButton(uiImage: nil, text: "Retry", subText: nil, baseFontSize: 16.0, action: {
				await retryAction?(true)
			})
//			Button(action: retryAction, label: { Text("Retry").bold() })
		}
	}
}

#if DEBUG
struct ErrorView_Previews: PreviewProvider {
	static var previews: some View {
		ErrorView(error: NSError(domain: "", code: 0, userInfo: [
			NSLocalizedDescriptionKey: "Something went wrong"]),
				  retryAction: { force in
			
		})
	}
}
#endif

