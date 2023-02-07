//
//  NetworkErrorModel.swift
//  GisKit
//
//  Created by Qitao Yang on 2020/10/18.
//

import HandyJSON

public class BaseError: Error {
    
    public var name: String?
    public var message: String
    
    public init(_ message: String, name: String? = nil) {
        self.message = message
        self.name = name
    }
}

public struct NetworkErrorModel: HandyJSON {
    public var name: String?
    public var message: String?
    public var code: Int?
    
    public init() {}
}

