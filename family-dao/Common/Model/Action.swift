//
//  Action.swift
//  family-dao
//
//  Created by KittenYang on 8/23/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import MultiSigKit
import SwiftUI
import BigInt

public struct ActionModelCategory:Codable, Identifiable, Hashable  {
	static let demo: ActionModelCategory = {
		ActionModelCategory(name: "Demo", actions: [.demo])
	}()
	
	public var name: String
	public var actions:[ActionModel]
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(actions)
	}
	
	public var id: String {
		return "\(self.name)_\(self.actions)"
	}
}

public struct ActionModel:Codable, Identifiable, Hashable {
	public var name: String
	public var colorHexString:String
	public var iconSymbolName: String
	public var amount: String // 每次多少货币
	public var count: Int // 次数
	public var uid: String// = UUID().uuidString
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(colorHexString)
		hasher.combine(iconSymbolName)
		hasher.combine(amount)
		hasher.combine(count)
		hasher.combine(uid)
	}
	
	public var id: String {
		return "\(self.name)_\(self.count)_\(self.amount)_\(self.colorHexString)_\(self.iconSymbolName)_\(uid)"
	}
	
//#if DEBUG
	static let demo = ActionModel(name: "Wash", colorHexString: "E7C203", iconSymbolName: "washer.fill", amount: "7", count: 2)
//#endif
	
	public init(name: String, colorHexString: String, iconSymbolName: String, amount: String, count: Int) {
		self.name = name
		self.colorHexString = colorHexString
		self.iconSymbolName = iconSymbolName
		self.amount = amount
		self.count = count
		self.uid = UUID().uuidString
	}
	
	public func send(byTimes times:Int = 1) async -> Bool {
		if await FaceID() {
			debugPrint("Face ID 认证通过！")
			guard let amount = amount.convertToBigUInt() else {
				return false
			}
			await AppHUD.show("sending".appLocalizable,delay: 4.0)
			let result = await NetworkAPIInteractor().proposeAction(value: amount * BigUInt(times))
			DispatchQueue.main.async {
				WalletManager.shared.shouldReloadQueue.toggle()
			}
			if let _ = result.0?.txId {
				await AppHUD.show("send_ok".appLocalizable)
				return true
			} else if let status = result.1 {
				await AppHUD.show(status.desc)
			}
			return false
		} else {
			return false
		}
	}
}

//public extension UIGradient {
//	var colors:[Color] {
//		return self.data.colors.compactMap({ Color(uiColor:$0) })
//	}
//}
