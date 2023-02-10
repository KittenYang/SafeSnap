//
//  TermsAndPrivacyView.swift
//  family-dao
//
//  Created by kittenyang on 2023/2/11.
//

import SwiftUI

struct TermsAndPrivacyView: View {
    var body: some View {
        HStack {
            Button {
                NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
                    AnyView(SafariView(url:URL(string: "https://safe.global/terms")!))
                }))
            } label: {
                Text("Terms")
                    .underline()
                    .font(.rounded(size: 14.0))
            }
            Text(" | ")
            Button {
                NavigationStackPathManager.shared.showSheetModel = .init(presented: true, sheetContent: .init({
                    AnyView(SafariView(url:URL(string: "https://safe.global/privacy")!))
                }))
            } label: {
                Text("Privacy Policy")
                    .underline()
                    .font(.rounded(size: 14.0))
            }
        }
    }
}

struct TermsAndPrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndPrivacyView()
    }
}
