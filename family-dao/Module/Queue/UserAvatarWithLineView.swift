//
//  UserAvatarWithLineView.swift
//  family-dao
//
//  Created by KittenYang on 8/31/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import web3swift
import LonginusSwiftUI

struct UserAvatarWithLineView: View {
	
	@State var title: String
	@State var confirmations: [SafeTxHashInfo.DetailedExecutionInfo.Confirmations]
	
	@State private var w = [CGRect]()
	
	var body: some View {
//		GeometryReader { geo in
//			Text("Hello, World!")
//				.frame(width: geo.size.width * 0.9)
//				.background(.red)
			VStack(alignment: .leading) {
				Text(title)
					.font(.rounded(size: 17.0,weight: .bold))
//					.background(CGRectGeometry())
//					.onPreferenceChange(CGRectPreferenceKey.self, perform: { self.w.append($0) })
				ForEach(confirmations, id:\.hashValue) { confirmation in
					UserAvatarView(confirmation: confirmation)
//						.background(CGRectGeometry())
//						.onPreferenceChange(CGRectPreferenceKey.self, perform: { self.w.append($0) })
				}
			}
			.coordinateSpace(name: "OuterV")
//			.border(.black)
//			.overlay {
//				getPath()
//					.stroke(Color.black, style: StrokeStyle(
//						lineWidth: 2,
//						lineCap: .round,
//						lineJoin: .round
//					))
//			}
	}
	
	func getPath() -> Path {
		var path = Path()
		var first: CGPoint = .zero
		var last: CGPoint = .zero
		for (index, rect) in self.w.enumerated() {
			var circle = Path()
			let newX = rect.origin.x - 5.0
			let newY = rect.origin.y + rect.size.height/2
			circle.move(to: CGPoint(x: newX, y: newY))
			let toPoint = CGPoint(x: newX - 10.0, y: newY)
			circle.addLine(to: toPoint)
			if index == 0 {
				first = toPoint
			}
			if index == self.w.count - 1 {
				last = toPoint
			}
			path.addPath(circle)
		}
		var circle = Path()
		circle.move(to: first)
		circle.addLine(to: last)
		path.addPath(circle)
		return path
	}
}

extension CGRect: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.origin.x)
		hasher.combine(self.origin.y)
		hasher.combine(self.size.width)
		hasher.combine(self.size.height)
	}
}

struct UserAvatarView: View {
	
	@ObservedObject var confirmation: SafeTxHashInfo.DetailedExecutionInfo.Confirmations
	
	func isZero() -> Bool {
		guard let signer = confirmation.signer, let address = EthereumAddress(signer) else {
			return false
		}
		return address == EthereumAddress.ethZero
	}
	
	var body: some View {
		HStack(alignment: .center) {
			if isZero() {
				Image(systemName: isZero() ? "questionmark.circle" : "person.crop.circle.fill")
					.resizable()
					.frame(width: 26.0, height: 26.0)
                    .opacity(0.5)
			} else if let author = confirmation.signer {
				LGImage(source: Constant.ethHashAvatar(address: author, length: 36), placeholder: {
					Image(systemName: "person.crop.circle.fill")
				},options:[.imageWithFadeAnimation])
				.resizable()
				.cancelOnDisappear(true)
				.aspectRatio(contentMode: .fit)
				.cornerRadius(13)
				.frame(width: 26.0, height: 26.0)
			}

			VStack(alignment: .leading, spacing: (confirmation.submittedAt != nil) ? 8.0 : 0.0) {
					sendText()
						.frame(alignment: .leading)
//						.border(.yellow)
				if let submittedAt = confirmation.submittedAt {
					Text(submittedAt, format: .dateTime)
						.font(Font.rounded(size: 14.0))
						.foregroundColor(Color.appGrayMiddle)
						.opacity(confirmation.submittedAt != nil ? 1.0 : 0.0)
				}
//						.border(.green)
//					}
				}
//				.border(.orange)
			}
			
	}
	
	@ViewBuilder
	private func sendText() -> some View {
		if let text = confirmation.signer?.nickNameAttributedString() {
			Text(text).lineLimit(2)
		}
	}
	
}

extension String {
	func nickNameAttributedString() -> AttributedString {
		let fontSize: CGFloat = 15.0
		if self != EthereumAddress.ethZero.address {
			let nick = self.aliasNickName()
//			var world = AttributedString("(\(etherAddressDisplay()))")
			if nick.hasNick {
				var nickName = AttributedString(nick.str)
				nickName.foregroundColor = .label
				nickName.font = Font.rounded(size: fontSize)
				
				var raw = AttributedString("(\(etherAddressDisplay()))")
				raw.font = Font.rounded(size: fontSize)
				raw.foregroundColor = .label.opacity(0.5)
				return nickName + raw
			} else {
				var name = AttributedString(etherAddressDisplay())
				name.font = Font.rounded(size: fontSize)
				name.foregroundColor = .label.opacity(0.5)
				return name
			}
//			if  WalletManager.shared.currentWalletOwnersNickname[self] {
//			} else {
//				world.font = Font.system(size: 13.0)
//				world.foregroundColor = .label
//			}
//			nickName += world
		} else {
            var empty = AttributedString("fasfnew_hofasfafme_name_perospn_rmpeppee".appLocalizable)
            empty.font = .rounded(size: 16.0)
            empty.foregroundColor = .label.opacity(0.5)
            return empty
		}
//		return nickName
	}
}

struct UserAvatarWithLineView_Previews: PreviewProvider {
	static var confir: SafeTxHashInfo.DetailedExecutionInfo.Confirmations = {
		var temp = SafeTxHashInfo.DetailedExecutionInfo.Confirmations()
		temp.signer = EthereumAddress.preview1.address
		return temp
	}()
	
	static var previews: some View {
		UserAvatarWithLineView(title: "fasfnew_hofasfafme_name_perospn_aooalals".appLocalizable, confirmations: [confir])
			.frame(width: 300,height: 200, alignment: .center)
//			.border(.red)
//			.previewLayout(.fixed(width: 300, height: 100))
	}
}


