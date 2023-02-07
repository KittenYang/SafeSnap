//
//  FaceIDManager.swift
//  family-dao
//
//  Created by KittenYang on 9/10/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import BiometricAuthentication
import MultiSigKit

//TODO: 修改成 await API
public func FaceID() async -> Bool {
	// 首次登录用户需要使用 FaceID
//	guard let _ = WalletManager.shared.currentWallet else {
//		manager.show(view: BlockView("当前未登录用户"), in: Constant.AppContainerID, using: HUDContainerConfiguration())
//		return
//	}
	let result = await FaceIDManager.checkUser()
	switch result {
	case .success( _):
		return true
	case .failure(let error):
		debugPrint("Authentication Failed")
		let message: String
		switch error {
		case .canceledByUser:
			message = "send_cancel".appLocalizable
		case .fallback:
			message = "send_fail".appLocalizable
		case .canceledBySystem:
			message = "send_cancel_sys".appLocalizable
		default:
			message = error.message()
		}
		await AppHUD.show(message)
		return false
	case .none:
		return false
	}
//	FaceIDManager.checkUser { result in
//		switch result {
//		case .success( _):
//			successHandler()
//		case .failure(let error):
//			debugPrint("Authentication Failed")
//			await AppHUD.show(error.message())
//		}
//	} errorHandler: {
//		await AppHUD.show("无法使用FaceID")
//	}
}

class FaceIDManager {
	
	static func checkUser(reason: String = "face_id_hint".appLocalizable,
						  fallbackTitle: String? = "",
						  cancelTitle: String? = "") async -> Result<Bool, AuthenticationError>? {
		
		return await withCheckedContinuation { conti in
			if BioMetricAuthenticator.canAuthenticate() {
				BioMetricAuthenticator.authenticateWithBioMetrics(reason: reason, fallbackTitle:"send_fail".appLocalizable, cancelTitle: "send_cancel".appLocalizable) { (result) in
					conti.resume(returning: result)
				}
			} else {
				//TODO: 处理用户手动输入密码逻辑
				if let _ = WalletManager.pwdForInput {
					conti.resume(returning: .success(true))
				} else {
					conti.resume(returning: .failure(.biometryNotAvailable))
				}
			}
		}
	}
	
}
