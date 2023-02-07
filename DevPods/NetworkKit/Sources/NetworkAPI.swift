//
//  NetworkAPI.swift
//  GisKit
//
//  Created by Qitao Yang on 2020/10/18.
//

import Foundation
import Moya
import HandyJSON


open class NetworkAPI: Moya.TargetType, HandyJSON {

	//fatalError("请完善 baseURL")
	public static var baseURLString: String = ""
	
    required public init() {}
    
    open var path: String {
			fatalError("请完善 path")
    }
    
	open var method: Moya.Method {
        return Method.get
    }
    
	open var baseURL: URL {
			return URL(string: NetworkAPI.baseURLString)!
    }
    
	open var sampleData: Data {
        return Data()
    }
    
	open var task: Moya.Task {
        switch method {
        case .post:
            var dict: [String: Any] = toJSON() ?? [:]
            if !dict.isEmpty {
                dict.removeValue(forKey: "isShowLoading")
            }
					
						var data: Data?
						let checker = JSONSerialization.isValidJSONObject(dict)
						if checker {
							data = try? JSONSerialization.data(withJSONObject: dict, options: [])
						}
					
            return .requestData(data ?? Data())
        case .get,
             .put:
            var dict: [String: Any] = toJSON() ?? [:]
            if !dict.isEmpty {
                dict.removeValue(forKey: "isShowLoading")
            }
            return .requestParameters(parameters: dict, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
	open var headers: [String: String]? {
        return NetworkCookies.shared.getHeaders()
    }
 
    // MARK: - NetworkLoading
    public var isShowLoading: Bool = false
    public var autoLoading: NetworkAPI {
        self.isShowLoading = true
        return self
    }
    
}
