//
//  BlockChainInteractable.swift
//  family-dao
//
//  Created by KittenYang on 7/31/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift

public typealias SubmitToChainCompletion = (TransactionSendingResult?, Error?)->Void
public typealias RepeatCheckTXCompletion = (TransactionReceipt?)->Void
public typealias RepeatCheckTXTwoAddressCompletion = (EthereumAddress?,EthereumAddress?)

public protocol BlockChainInteractable: AnyObject {
	func repeatCheckCreateMultiSigStatus(chain: Chain.ChainID, transactionResult: TransactionSendingResult?, completion:RepeatCheckTXCompletion?)
}

public extension BlockChainInteractable {
	func repeatCheckCreateMultiSigStatus(chain: Chain.ChainID, transactionResult: TransactionSendingResult?,completion:RepeatCheckTXCompletion?) {
		if let e_tract = transactionResult?.transaction,
		   let hash = e_tract.hash {
			// 每隔 5s 轮询，不断查询链上是否创建完成
			var count = 0
			
			let isMainThread = Thread.isMainThread
			// 注意点： timer 依赖活跃的 runloop，子线程的 runloop 默认是不开启的，可以 async 到主线程，当然也可以在子线程手动开启
			let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
				count += 1
				debugPrint("第\(count)次轮询")
				//hashReceipt.logs[0].address -> 最终的钱包地址 0x19d67c11aa29b15640204e320bac2a3043369a35
				// TODO: 怎么获得真正的 internal transaction？我感觉肯定不能在 log 里找，这次只不过是这个合约正好 emit 了一个 event 而已，运气好
				let hashReceipt = try? ChainManager.global.currentWeb3provider(chain)?.eth.getTransactionReceipt(hash)
				if hashReceipt != nil || count == 24 { // 超时2分钟结束
					// 轮询结束，退出 timer
					timer.invalidate()
					debugPrint("轮询结束")
					completion?(hashReceipt)
					// 轮询结束，停止runloop
					if !isMainThread {
						CFRunLoopStop(RunLoop.current.getCFRunLoop())
					}
				}
			}//timer
			
			let runLoop = RunLoop.current
			runLoop.add(timer, forMode: .default)
			
			// 手动在子线程开启 runloop
			if !isMainThread {
				runLoop.run()
			}
		} else {
			completion?(nil)
		}
	}
}
