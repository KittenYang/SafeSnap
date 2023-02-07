//
//  ENSDomainManager.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/19/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation


public struct ENSDomainManager {
	
	static let interactor: NetworkAPIInteractor = NetworkAPIInteractor()
	static let shared = ENSDomainManager()
	
	public static func getEnsdomainsBy(_ address:String) async -> ENSDomainsResult? {
		return await self.interactor.request(api: .ensdomains(address: address), mapTo: ENSDomainsResult.self, queue: self.interactor.concurrentQueue)
	}
	
}
