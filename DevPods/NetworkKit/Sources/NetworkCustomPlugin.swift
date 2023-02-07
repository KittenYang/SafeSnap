//
//  NetworkCustomPlugin.swift
//  GisKit
//
//  Created by Qitao Yang on 2020/10/18.
//

import Foundation
import Moya
import RxSwift
import Alamofire
//import EFSafeArray
//import EFFoundation
//import SwiftSoup

public class NetworkCustomPlugin: PluginType {
  
	public init() {}
	
    // MARK: - PluginType
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
//        printLog("prepare")
        
        var customRequest: URLRequest = request
        switch target.task {
        case .uploadMultipart, .uploadCompositeMultipart, .uploadFile:
            customRequest.timeoutInterval = 180
        default:
            customRequest.timeoutInterval = 18
        }
        return customRequest
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        // printLog("willSend")
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        // printLog("didReceive")
    }
    
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
    
        switch result {
        case .success(let response):
            
            do {
                //过滤成功的状态码响应
                let _ = try response.filterSuccessfulStatusCodes()
            }
            catch let error {
                return Result<Response, MoyaError>.failure(error as! MoyaError)
            }
            
            NetworkCustomPlugin.handleCookieIfNeededwithResponse(successResponse: response)
            
            let networkError: NetworkErrorModel = response.mapObject(to: NetworkErrorModel.self)
            if let code = networkError.code, code != 0  {
                let baseError: BaseError = BaseError(networkError.message ?? "")
                return Result<Response, MoyaError>.failure(MoyaError.underlying(baseError, nil))
            }
            
        case .failure(let error):
            if let errorDescription: String = error.errorDescription {
                // printLog("errorDescription: \(errorDescription)")
                var message: String = errorDescription
                if message.contains("The Internet connection appears to be offline") {
                    message = "Please check your network"
                } else if message.contains("Could not connect to the server") {
                    message = "Unable to connect to the server!"
                }
                let baseError: BaseError = BaseError(message)
                return Result<Response, MoyaError>.failure(MoyaError.underlying(baseError, nil))
            }
        }
        return result
    }
}

public extension NetworkCustomPlugin {
    static func handleCookieIfNeededwithResponse(successResponse: Response) {
        let headers: Alamofire.HTTPHeaders = successResponse.response?.headers ?? Alamofire.HTTPHeaders()
        let cookies: [String] = headers.filter({ $0.name == "Set-Cookie" || $0.name == "set-cookie" }).map({ $0.value })
        var newCookies: NetworkCookieType = [:]
        for cookie in cookies {
            let regexResults = cookie.cookieRegex()
            for result in regexResults {
                if result.range.location == NSNotFound && result.range.length <= 1 {
                    continue
                }
                let keyValueString = cookie[result.range]
                let keyAndValue: [String] = keyValueString.components(separatedBy: "=")
							if keyAndValue.count == 2, 0 < keyAndValue.count, 1 < keyAndValue.count {
									let key = keyAndValue[0]
									let value = keyAndValue[1]
                    newCookies.updateValue(value, forKey: key)
                }
            }
        }
        if !newCookies.values.isEmpty {
            NetworkCookies.shared.updateCookies(newCookies)
        }
    }
}
