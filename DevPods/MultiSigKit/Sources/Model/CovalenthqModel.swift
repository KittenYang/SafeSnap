//
//  CovalenthqModel.swift
//  MultiSigKit
//
//  Created by KittenYang on 1/29/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import HandyJSON

public class CovalenthqModel<T:HandyJSON>: HandyJSON {
	public var data: CovalenthqModelData<T>?
	
	public var error: Bool?
	public var error_message: Bool?
	public var error_code: Bool?
	
	required public init() {}
}

public class CovalenthqModelData<T:HandyJSON>: HandyJSON {
	public var updated_at: Date?
	public var items:[T]?
	public var pagination: CovalenthqModelDataPagination?
	required public init() {}
	
	public func mapping(mapper: HelpingMapper) {
		mapper <<<
			self.updated_at <-- ISO8601SSSDateTransform()
	}
}

public class CovalenthqModelDataPagination: HandyJSON {
	public var has_more: Bool?
	public var page_number: Int?
	public var page_size: Int?
	public var total_count: Int?
	
	required public init() {}
}
