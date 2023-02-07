//
//  KeychainManager.swift
//  family-dao
//
//  Created by KittenYang on 6/27/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import KeychainAccess

public class KeychainManager {
	public static let KeychainServiceWalletName = "com.kittenyang.family-dao"
	public static let appKeychain_wallet = Keychain(service: KeychainManager.KeychainServiceWalletName)
	
	public static let KeychainServiceFamilyName = "com.kittenyang.family-dao-family"
	public static let appKeychain_family = Keychain(service: KeychainManager.KeychainServiceFamilyName)
	
	public static let KEY = "_&*(^"
	
	public static func changeWalletName(newName:String) -> Bool {
		if var currentWallet = WalletManager.shared.currentWallet {
			let oldPass = KeychainManager.appKeychain_wallet[currentWallet.name]
			KeychainManager.appKeychain_wallet[newName] = oldPass
			do {
				try KeychainManager.appKeychain_wallet.remove(currentWallet.name)
			} catch {
				return false
			}
			// 更新内存里的 wallet
			currentWallet.name = newName
			WalletManager.shared.currentWallet = currentWallet
			return true
		}
		return false
	}
	
	/*
	 [
		"family_1":"park chapter heart soda sunset hungry mention pioneer blind live fortune zebra",
		"family_2":"genre blur pass visit raise regret reveal priority address humor luggage north"
	 ]
	 */
	public static func saveMnemonics(name:String,mnemonics:String) {
		KeychainManager.appKeychain_wallet[name] = mnemonics
	}
	
	public static func saveFamily(familyname:String,chain:Chain.ChainID,familyAddress:String) {
		let newName = "\(familyname)\(KEY)\(chain.rawValue)"
		KeychainManager.appKeychain_family[newName] = familyAddress
	}
	
	public static func getFamilyNameAndChain(by key: String) -> (name:String,chain:Chain.ChainID)? {
		let parts = key.components(separatedBy: Self.KEY)
		if parts.count == 2, let first = parts.first, let last = parts.last {
			return (first,Chain.ChainID(rawValue: last) ?? .ethereumMainnet)
		}
		
		return nil
	}
}
