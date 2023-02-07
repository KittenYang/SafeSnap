//
//  Defaults.swift
//  family-dao
//
//  Created by KittenYang on 1/22/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Defaults
import AlscCodableJSON

public extension Defaults.Keys {
	static let recentActions = Key<[ActionModel]>("recentActions", default: [.demo])
	static let actionCategories = Key<[ActionModelCategory]>("actionCategories", default: [.demo])
	static let currencyHistory = Key<StoredCurrencyHistory>("recentDaysCurrencyHistory", default: .init(history: [:]))
	static let firstInstall_family = Key<Bool>("first_install_family", default: true)
	static let firstInstall_user = Key<Bool>("first_install_user", default: true)
}

public extension Defaults {
	static let maxStoreActionCount: Int = 10
	
	static func addRecentStoreActions(_ new: [ActionModel]) {
		var uniqueNew = new
		for index in 0..<uniqueNew.count {
			uniqueNew[index].uid = UUID().uuidString
		}
		var old = Defaults[.recentActions]
		old.append(contentsOf: uniqueNew)
		while old.count > maxStoreActionCount {
			old.removeFirst()
		}
		Defaults[.recentActions] = old
	}
	
	static func removeRecentStoreAction(_ remove: ActionModel) {
		var old = Defaults[.recentActions]
		old.removeAll(where: { $0.name == remove.name })
		Defaults[.recentActions] = old
	}
	
	static func addCategory(_ category: String, _ actions: [ActionModel]) {
		if let index = Defaults[.actionCategories].firstIndex(where: { $0.name == category }) {
			var oldActions = Defaults[.actionCategories][index].actions
			oldActions.append(contentsOf: actions)
			Defaults[.actionCategories][index].actions = oldActions
		} else {
			Defaults[.actionCategories].append(.init(name: category, actions: actions))
		}
	}
	
	static func removeAction(_ actions:[ActionModel]) {
        var shouldRemoveIndex: Int?
		for action in actions {
			if let index = Defaults[.actionCategories].firstIndex(where: { $0.actions.contains(action) }) {
				var oldActions = Defaults[.actionCategories][index].actions
				oldActions.removeAll(where: { $0 == action })
				Defaults[.actionCategories][index].actions = oldActions
                // 如果一个都不剩，并且是 DEMO，直接移除整个 category
                if Defaults[.actionCategories][index].actions.isEmpty {
                    if Defaults[.actionCategories][index].name == ActionModelCategory.demo.name {
                        shouldRemoveIndex = index
                    }
                }
            }
        }
        if let shouldRemoveIndex {
            Defaults[.actionCategories].remove(at: shouldRemoveIndex)
        }
	}
	
}



// MARK: StoreActionCategory
extension ActionModelCategory: Defaults.Serializable {
	public static let bridge = StoreActionCategoryBridge()
}

public struct StoreActionCategoryBridge: Defaults.Bridge {
	public typealias Value = ActionModelCategory
	public typealias Serializable = String

	public func serialize(_ value: Value?) -> Serializable? {
		guard let value = value else {
			return nil
		}
		
		return value.jsonString()
	}

	public func deserialize(_ object: Serializable?) -> Value? {
		guard
			let data = object?.data(using: .utf8),
			let value = try? AlscJSONDecoder().decode(Value.self, from: data)
		else {
			return nil
		}
		return value
	}
}

public extension Encodable {
	
	var dictionary: [String: Any] {
		return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
	}
	
	func jsonString() -> String? {
		guard let data = try? JSONSerialization.data(withJSONObject: self.dictionary, options: []) else {
			return nil
		}
		return String(data: data, encoding: String.Encoding.utf8)
	}
}

// MARK: ActionModel
extension ActionModel: Defaults.Serializable {}

// MARK: CurrencyHistory
extension CurrencyHistory: Defaults.Serializable {}
extension StoredCurrencyHistory: Defaults.Serializable {}

// MARK: 通用 defaults bridge
extension Defaults.Serializable where Self: Codable {
	public static var bridge: ActionModelBridge<Self> {
		return ActionModelBridge<Self>()
	}
}

public struct ActionModelBridge<T:Codable>: Defaults.Bridge {
	public typealias Value = T
	public typealias Serializable = String

	public func serialize(_ value: Value?) -> Serializable? {
		guard let value = value else {
			return nil
		}

		return value.jsonString()
	}

	public func deserialize(_ object: Serializable?) -> Value? {
		guard
			let data = object?.data(using: .utf8),
			let value = try? AlscJSONDecoder().decode(Value.self, from: data)
		else {
			return nil
		}
		return value
	}
}
