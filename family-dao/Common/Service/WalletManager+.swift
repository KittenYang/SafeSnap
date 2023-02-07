//
//  WalletManager+.swift
//  family-dao
//
//  Created by KittenYang on 1/29/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import MultiSigKit
import BigInt
import web3swift

extension WalletManager {
	
	func historicalCurrency() async -> [CurrencyHistory] {
		// 过去7天
		let maxBefore = 6
		let toDate = Date.now
		let balances = ThreadSafeDictionary(dict: [Date:BigUInt]())
		let _ = await withThrowingTaskGroup(of: [BigUInt].self) { _group -> [BigInt] in
			for index in 0..<maxBefore {
				_group.addTask {
					var _to = toDate.beforeDay(index)
					if index != 0 {
						let toCompo = _to.getComponents(.year,.month,.day)
						if let year = toCompo.year,
						   let month = toCompo.month,
						   let day = toCompo.day {
							_to = Date.new(year: year, month: month, day: day).beforeDay(-1).beforeSeconds(1) // at end of the day
						}
					}
					// 每天只取最后的30秒，20s 一个区块
					let _from = _to.beforeSeconds(30)
					print("_from:\(_from),_to:\(_to)")
					let _balance = await NetworkAPIInteractor().getBalanceByTime(fromDate: _from, toDate:_to)
					balances[_to] = _balance?.last ?? BigUInt(0)  // 取30s内最后一个区块的货币总数
					return _balance ?? []
				}
			}
			
			do {
				for try await v in _group {
					print("✅for loop await \(v)")
//					collected.append(value)
				}
			} catch {
				print(error.localizedDescription)
			}
			
			return []
		}

		let correctBals = balances.innerDictionary.sorted(by: { $0.key.timeIntervalSince1970 < $1.key.timeIntervalSince1970 }).compactMap { (date, uint) in
			let year = Calendar.current.component(.year, from: date)
			let month = Calendar.current.component(.month, from: date)
			let day = Calendar.current.component(.day, from: date)
			let newDate = Date.new(year: year, month: month, day: day)

			let amountStr = Int(Web3.Utils.formatToEthereumUnits(uint, toUnits: .eth, decimals: WalletManager.currentFamilyTokenDecimals) ?? "0") ?? 0
			
			return CurrencyHistory(day: newDate, initialValue: 0, yValue: amountStr)
		}
		
		print("✅请求完成：\(correctBals)")
		return correctBals
	}
}
