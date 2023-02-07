//
//  ENSDomainsResult.swift
//  MultiSigKit
//
//  Created by KittenYang on 11/6/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import HandyJSON

public class ENSDomainsResult: HandyJSON {
	public var domains: [ENSDomainsResultName]?
	
	public class ENSDomainsResultName: HandyJSON, CustomDebugStringConvertible {
		public var name: String?
		required public init() {}
		
		public var debugDescription: String {
			return name ?? ""
		}
	}
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.domains <-- "data.account.domains"
	}
	
	required public init() {}
}
