//
//  BlockNumber.swift
//  MultiSigKit
//
//  Created by KittenYang on 1/28/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import HandyJSON
import BigInt

public class BlockNumberDataItem: HandyJSON {
	public var signed_at: Date?
	public var height: BigUInt?
	required public init() {}
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.signed_at <-- ISO8601ssZDateTransform()
		mapper <<<
			self.height <-- BigUIntTransform()
	}
}


