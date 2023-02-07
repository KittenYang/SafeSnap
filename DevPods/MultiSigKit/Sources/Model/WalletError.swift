//
//  WalletError.swift
//  family-dao
//
//  Created by KittenYang on 6/26/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public enum WalletError: Error {
	case BioMetricAuthenticateNotSupportAndNoPass
	case FailToBioMetricAuthenticate(Error)
	case FailToGenerateMnemonics
	case FailToCreateKeystore
	case JSONEncoderFailed
	case KeystoreNoAddress
	
	public var description: String {
		switch self {
		case .BioMetricAuthenticateNotSupportAndNoPass:
			return "sfnessw_hvgjyome_jjname_perospn".appLocalizable
		case .FailToBioMetricAuthenticate(_):
			return "fsanew_fhoffme_name_perosdaspn".appLocalizable
		case .FailToGenerateMnemonics:
			return "dasdsafnewfasf_home_name_perospnsfsaf".appLocalizable
		case .FailToCreateKeystore:
			return "new_home_name_perospn_keydajodfailed".appLocalizable
		case .JSONEncoderFailed:
			return "new_home_name_perospn_json_encode_fail".appLocalizable
		case .KeystoreNoAddress:
			return "new_home_name_perospn_kethodoamnnort".appLocalizable
		}
	}
}



struct CreateSafeError: CustomNSError {
	static var errorDomain: String { "io.gnosis.safe.createSafeModel" }
	var errorCode: Int
	var message: String
	var cause: Error? = nil
	
	var errorUserInfo: [String : Any] {
		var result: [String: Any] = [NSLocalizedDescriptionKey: message]
		if let cause = cause {
			result[NSUnderlyingErrorKey]  = cause
		}
		return result
	}
}
