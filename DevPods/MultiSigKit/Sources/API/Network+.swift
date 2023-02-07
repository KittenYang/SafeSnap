//
//  Network+.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/7/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    


import Moya
import RxSwift
import NetworkKit

public extension Network {
	
	static let provider = MoyaProvider<NetworkAPI>(session: session, plugins: plugins)
	
	static var session: Session {
		
		let configuration = URLSessionConfiguration.default
		configuration.headers = .default
		
#if DEBUG
		
#else
		// release 包，能切换API mode，能抓包，能打开审核入口
		if NetworkEnviroment.shared.isDeveloperMode {
			
		} else {
			// 阻止 Charles 抓包
			configuration.connectionProxyDictionary = [:]
		}
#endif
		return Session(configuration: configuration, startRequestsImmediately: false)
	}
	
	static var plugins: [PluginType] {
		func autoLoading(change: NetworkActivityChangeType, target: TargetType) {
			let isShowLoading: Bool = (target as? NetworkAPI)?.isShowLoading ?? false
			if isShowLoading {
				switch change {
				case .began:
					DispatchQueue.main.async {
						//                            HUD.showLoadingHUD()
					}
				case .ended:
					DispatchQueue.main.async {
						//                            HUD.hideLoadingHUD()
					}
				}
			}
		}
		
		func activityIndicator(change: NetworkActivityChangeType, target: TargetType) {
			struct Anchor {
				static var currentRequestCount: Int = 0 {
					didSet {
						DispatchQueue.main.async {
							UIApplication.shared.isNetworkActivityIndicatorVisible = self.currentRequestCount > 0
						}
					}
				}
			}
			switch change {
			case .began: Anchor.currentRequestCount += 1
			case .ended: Anchor.currentRequestCount -= 1
			}
		}
		
		let networkActivityPlugin = NetworkActivityPlugin { (change, target) in
			autoLoading(change: change, target: target)
			activityIndicator(change: change, target: target)
		}
		return [networkActivityPlugin, NetworkCustomPlugin()]
	}
	
	func request(autoLoading: Bool = false, callbackQueue: DispatchQueue? = nil) -> Single<Response> {
		if autoLoading {
			return Network.provider.rx.request(api.autoLoading, callbackQueue: callbackQueue)
		} else {
			return Network.provider.rx.request(api, callbackQueue: callbackQueue)
		}
	}
	
}
