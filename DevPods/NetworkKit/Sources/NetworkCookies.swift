//
//  NetworkCookies.swift
//  GisKit
//
//  Created by Qitao Yang on 2020/10/18.
//

import Foundation
import HandyJSON
//import EFFoundation
//import DefaultsKit

public typealias NetworkCookieType = [String: String]

public class NetworkCookies {
    
    public static let shared: NetworkCookies = NetworkCookies()
    
    private var customCookiesString: String {
        set {
					UserDefaults.standard.set(newValue, forKey: "customCookiesStringKey")
        }
        get {
					(UserDefaults.standard.value(forKey: "customCookiesStringKey") as? String) ?? ""
        }
    }
    private var customCookiesCache: NetworkCookieType?
    private var headerCache: NetworkCookieType?
    
    public func getHeaders() -> NetworkCookieType {
        defer {
//            printLog("getHeaders: \(headerCache ?? [:])")
        }
        if let `headerCache` = headerCache {
            return headerCache
        }
        var headers: NetworkCookieType = ["Content-Type": "application/json"]
        let cookieDic = getCookies()
        var cookieHeaderString = ""
        for (key, value) in cookieDic where !value.isEmpty {
            cookieHeaderString += "\(key)=\(value);"
        }
        let cookieHeader: NetworkCookieType = [
            "Cookie": cookieHeaderString,
//            "X-Request-Package-ID": Kuril.packageID,
//            "X-Request-Version": Kuril.version,
            "X-Request-Device": "ios",
            "X-Request-UTM-Source": "appstore"
        ]
        // gapi 登录状态的兼容处理
//        if let token = UserLoginManager.shared.token {
//            cookieHeader.updateValue("Bearer \(token)", forKey: "Authorization")
//        }
        headers.merge(cookieHeader, uniquingKeysWith: { $1 })
        headerCache = headers
        return headers
    }
    
    public func updateCookies(_ newCookies: NetworkCookieType) {
        var oldCookies: NetworkCookieType = getCookies()
        for newCookie in newCookies {
            oldCookies.updateValue(newCookie.value, forKey: newCookie.key)
        }
        if let oldCookiesString = oldCookies.string() {
            customCookiesString = oldCookiesString
            clearCache()
        } else {
            debugPrint("setCookies failed!")
        }
    }
    
    public func clearCookies() {
        customCookiesString = ""
        clearCache()
        
        if let httpCookieStorage: HTTPCookieStorage = URLSessionConfiguration.default.httpCookieStorage {
            for cookie in httpCookieStorage.cookies ?? [] {
                httpCookieStorage.deleteCookie(cookie)
            }
        }
    
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    
    private func getCookies() -> NetworkCookieType {
        if let `customCookiesCache` = customCookiesCache {
            return customCookiesCache
        }
        var cookies: NetworkCookieType = NetworkCookieType()
			
        let customCookies: NetworkCookieType = (customCookiesString.dictionary() as? NetworkCookieType) ?? [:]
        for customCookie in customCookies {
            cookies.updateValue(customCookie.value, forKey: customCookie.key)
        }
        customCookiesCache = cookies
        return cookies
    }
    
    private func clearCache() {
        customCookiesCache = nil
        headerCache = nil
    }
}
