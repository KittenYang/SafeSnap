//
//  Web3+.swift
//  MultiSigKit
//
//  Created by KittenYang on 1/28/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import web3swift
import BigInt

extension ERC20 {
	// 获取某个 block 的 erc20 balance
	public func getBalance(account: EthereumAddress, blockNumber: BigUInt) throws -> BigUInt {
		let contract = self.web3.contract(Web3.Utils.erc20ABI, at: self.address, abiVersion: 2)
		var transactionOptions = TransactionOptions()
		transactionOptions.callOnBlock = .exactBlockNumber(blockNumber)// 某个区块上的快照，更改这个参数即可
		let result = try contract?.read("balanceOf", parameters: [account] as [AnyObject], extraData: .init(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
		guard let res = result?["0"] as? BigUInt else {
			throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")
		}
		return res
	}
}
