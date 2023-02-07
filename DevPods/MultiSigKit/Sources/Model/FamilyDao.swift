//
//  FamilyDao.swift
//  family-dao
//
//  Created by KittenYang on 7/10/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import web3swift
import GnosisSafeKit
import Defaults
import SwiftUI
import CoreData

public class Family: NSManagedObject, Identifiable {

	public var id: String {
		return address + chainID + name + "\(threshold)" + owners.joined(separator: ",")
	}
//	public var id = UUID()
	
	@NSManaged public var additionDate: Date
	// 创建需要
	@NSManaged public var address: String
	@NSManaged public var chainID: String
	@NSManaged public var name: String
	// 更新需要
	@NSManaged public var nonce: Int64
	@NSManaged public var owners: [String]
	@NSManaged public var ownerTokenBalanceData: Data?
	@NSManaged public var threshold: Int64
	
	@NSManaged public var selection: Selection?
	@NSManaged public var token: FamilyToken?
	
	// Space 空间地址
	@NSManaged public var spaceDomain: String?
		
}

extension Family {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Family> {
		//TODO: 替换成泛型方法
		return NSFetchRequest<Family>(entityName: "Family")
	}
}
