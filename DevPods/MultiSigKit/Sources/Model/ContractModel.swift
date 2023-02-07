//
//  ContractModel.swift
//  family-dao
//
//  Created by KittenYang on 7/23/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public struct ContractModel: Codable {
	
	public var defaultAddress: String
	public var released: Bool
	public var contractName: String
	public var version: String
	public var networkAddresses: [String: String]
	public var abi: String
	
}
