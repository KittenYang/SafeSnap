//
//  NetworkRxSwift.swift
//  GisKit
//
//  Created by Qitao Yang on 2020/10/18.
//

import UIKit
import Moya
import HandyJSON
import RxSwift
import Moya
//import EFFoundation

public typealias BlockBlank = () -> Void
public typealias BlockElement<T> = (T) -> Void
public typealias BlockArray<T> = ([T]) -> Void

// MARK: - ErrorToast
public extension Observable {
    func showErrorToast(_ errorHandler:((BaseError)->Void)? = nil) -> Observable<Element> {
			//TODO: HUD
        return self.do(onNext: { (result) in
            print(result)
        }, onError: { (error) in
//            if !UIApplication.isAppExtension {
                // HapticManager.notification.feedback(.error)
//            }
					if let moyaError = error as? MoyaError {
						
						if let baseError = moyaError.errorUserInfo[NSUnderlyingErrorKey] as? BaseError {
							debugPrint("❌报错:\(baseError.message)")
							errorHandler?(baseError)
						} else if let response = moyaError.response,
											let errJson = try? response.mapJSON() as? [String:Any],
											let name = errJson["code"] as? Int,
											var errMsg = errJson["message"] as? String {
							debugPrint("❌报错:\(errMsg), data:\(errJson)")
							if response.statusCode == 404 {
								errMsg = "404 Not Found"
							}
							errorHandler?(BaseError(errMsg,name: "\(name)"))
						} else {
							switch moyaError {
							case .statusCode(let resp):
								let str = String(data: resp.data, encoding: .utf8)!
								debugPrint("statusCode Error:\(str)")
								errorHandler?(BaseError(str))
							default:
								errorHandler?(BaseError(moyaError.errorDescription ?? ""))
								break
							}
						}
						
					}
        }, onCompleted: {
            
        }, onSubscribe: {
            
        }, onDispose: {
            
        })
    }
    
    func customNetworkErrorHandle(_ handle: @escaping BlockElement<BaseError?>) -> Observable<Element> {
        return self.do(onNext: { (_) in
            
        }, onError: { (error) in
            let moyaError: MoyaError? = error as? MoyaError
            let baseError: BaseError? = moyaError?.errorUserInfo[NSUnderlyingErrorKey] as? BaseError
            handle(baseError)
        }, onCompleted: {
            
        }, onSubscribe: {
            
        }, onDispose: {
            
        })
    }
}

// MARK: - HandyJSON
public extension DateFormatterTransform.JSON {
    func mapObject<T: HandyJSON>(to type: T.Type) -> T {
        return T.deserialize(from: self) ?? T()
    }
    
    func mapArray<T: HandyJSON>(to type: T.Type) -> [T] {
        return [T].deserialize(from: self)?.compactMap { return $0 } ?? []
    }
}

public extension Moya.Response {
    func mapObject<T: HandyJSON>(to type: T.Type) -> T {
        return T.deserialize(from: try? self.mapString()) ?? T()
    }
    
    func mapArray<T: HandyJSON>(to type: T.Type) -> [T] {
        return [T].deserialize(from: try? self.mapString())?.compactMap { return $0 } ?? []
    }
}

public extension ObservableType where Element == DateFormatterTransform.JSON {
    func mapObject<T: HandyJSON>(to type: T.Type) -> Observable<T> {
        return flatMap { json -> Observable<T> in
			//这里打印 api json
            return Observable.just(json.mapObject(to: type))
        }
    }
    
    func mapArray<T: HandyJSON>(to type: T.Type) -> Observable<[T]> {
        return flatMap { json -> Observable<[T]> in
            return Observable.just(json.mapArray(to: type))
        }
    }
}

public extension ObservableType where Self.Element == Moya.Response {
    func mapObject<T: HandyJSON>(to type: T.Type) -> Observable<T> {
        return mapString().mapObject(to: type)
    }
    
    func mapArray<T: HandyJSON>(to type: T.Type) -> Observable<[T]> {
        return mapString().mapArray(to: type)
    }
}
