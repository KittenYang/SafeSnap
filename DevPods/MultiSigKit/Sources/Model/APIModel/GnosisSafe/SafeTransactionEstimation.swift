//
//  SafeTransactionEstimation.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/7/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import HandyJSON
import web3swift

/*
 {
	 "currentNonce": 0,
	 "recommendedNonce": 2,
	 "safeTxGas": "38306"
 }
 {
	 "currentNonce": 1,
	 "latestNonce": 5,
	 "safeTxGas": "38306"
 }
 */
public class SafeTransactionEstimation: HandyJSON {
	public var currentNonce: UInt256?
	private var recommendedNonce: UInt256?
	private var latestNonce: UInt256?
	public var safeTxGas: String?
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.currentNonce <-- UInt256Transform()
		mapper <<<
			self.recommendedNonce <-- UInt256Transform()
		mapper <<<
			self.latestNonce <-- UInt256Transform()
	}
	
	public var nonce: UInt256? {
		//第0笔会反复添加，上链了第0笔，后面每一笔都会自动+1
		print("recommendedNonce:\(recommendedNonce?.description), currentNonce:\(currentNonce?.description), latestNonce:\(latestNonce?.description)")
		if let recommendedNonce {
			return recommendedNonce
		}
		if let latestNonce, let currentNonce, latestNonce >= currentNonce, currentNonce != 0 {
			return latestNonce + 1
		}
		return self.recommendedNonce ?? self.currentNonce ?? self.latestNonce
	}
	
	required public init() {}
}
