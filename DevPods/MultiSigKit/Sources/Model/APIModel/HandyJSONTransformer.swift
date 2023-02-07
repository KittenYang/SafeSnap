//
//  HandyJSONTransformer.swift
//  MultiSigKit
//
//  Created by KittenYang on 8/8/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import BigInt
import web3swift
import HandyJSON

open class BigUIntTransform: TransformType {
	public typealias Object = BigUInt
	public typealias JSON = String
	
	public func transformToJSON(_ value: BigUInt?) -> String? {
		if let _big_int = value {
			return String(_big_int)
		}
		return nil
	}
	
	public func transformFromJSON(_ value: Any?) -> BigUInt? {
		if let rawString = value as? String {
			return BigUInt(rawString)
		} else if let rawInt = value as? Int {
			return BigUInt(rawInt)
		} else if let rawDouble = value as? Double {
			return BigUInt(rawDouble)
		}
		return nil
	}
}

open class EthereumAddressTransform: TransformType {
	public typealias Object = EthereumAddress
	public typealias JSON = String
	
	public func transformFromJSON(_ value: Any?) -> web3swift.EthereumAddress? {
		if let address = value as? String {
			return EthereumAddress(address)
		}
		return nil
	}
	
	public func transformToJSON(_ value: web3swift.EthereumAddress?) -> String? {
		return value?.address
	}
}

open class EthereumAddressArrayTransform: TransformType {
	public typealias Object = [EthereumAddress]
	public typealias JSON = [[String:String]]
	
	public func transformToJSON(_ value: [EthereumAddress]?) -> [[String : String]]? {
		return value?.compactMap({ ["value":$0.address] })
	}
	
	public func transformFromJSON(_ value: Any?) -> [EthereumAddress]? {
		if let rawJson = value as? [[String:String]] {
			return rawJson
				.compactMap({ $0["value"] })
				.compactMap({ EthereumAddress($0) })
		}
		return nil
	}
}

open class UInt256Transform: TransformType {
	public typealias Object = UInt256
	public typealias JSON = Any
	
	public func transformFromJSON(_ value: Any?) -> UInt256? {
		var result: UInt256?
		if let string = value as? String {
				if string.hasPrefix("0x") {
						let data = Data(ethHex: string)
					result = UInt256(data)
				} else if let uint256 = UInt256(string) {
					result = uint256
				}
		} else if let uint = value as? UInt {
			result = UInt256(uint)
		} else if let int = value as? Int, int >= 0 {
			result = UInt256(int)
		}
		return result
	}
	
	public func transformToJSON(_ value: UInt256?) -> JSON? {
		return value?.description
	}
	
}

open class YMDDateFormatTransform: CustomDateFormatTransform {
	init() {
		super.init(formatString: "yyyy-MM-dd HH:MM:ss")
	}
	open override func transformFromJSON(_ value: Any?) -> Date? {
		if let dateInt = value as? Int {
			let date = Date(timeIntervalSince1970: TimeInterval(dateInt) / 1000.0)
			return date
//			return dateFormatter.date(from: "\(dateInt)")
		}
		return super.transformFromJSON(value)
	}
}

public extension Date {
	func toYMDString() -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")//这个会转换成本地时间
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return formatter.string(from: self)
	}
	
	func timeAgo() -> (str:String,ago:Bool) {
		let input = self//.localTime()
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
		formatter.zeroFormattingBehavior = .dropAll
		
		var calendar = Calendar.current
		calendar.locale = .current//.init(identifier: Locale.preferredLanguages.first!)
		formatter.calendar = calendar
		
		formatter.maximumUnitCount = 1
		
		let now = Date()
		var suffix: String = "new_home_name_perospn_layttttttter".appLocalizable
		var tm = formatter.string(from: now, to: input)
		var ago: Bool = false
		if now > self {
			suffix = "new_home_name_perospn_agooooo".appLocalizable
			tm = formatter.string(from: input, to: now)
			ago = true
		}
		return (String(format: tm ?? "", locale: .current) + suffix, ago)
	}

	func localTime() -> Date {
		let timezone = TimeZone.current
		let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
		return Date(timeInterval: seconds, since: self)
	}
}

public extension TimeInterval {
	var friendString: String? {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
		formatter.unitsStyle = .full
		
		var calendar = Calendar.current
		calendar.locale = .current//.init(identifier: Locale.preferredLanguages.first!)
		formatter.calendar = calendar
		
		let daysString = formatter.string(from: self)
		return daysString
//		print(daysString) // "3
		
//		let time = NSInteger(self)
//
//					let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
//					let seconds = time % 60
//					let minutes = (time / 60) % 60
//					let hours = (time / 3600)
//
//					return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
	}
}

/// HandyJSON mix Decodable
open class DecodableTransform<T:Decodable>: TransformType {
	public typealias Object = T
	public typealias JSON = Data
	
	public func transformFromJSON(_ value: Any?) -> Object? {
		if let rawString = value as? [String:Any],
		   let data = rawString.data {
			do {
				let newdata = try JSONDecoder().decode(T.self, from: data)
				return newdata
			} catch {
				print(error)
			}
		}
		return nil
	}
	
	public func transformToJSON(_ value: Object?) -> JSON? {
		guard let value else { return nil }
		return try? JSONSerialization.data(withJSONObject: value)
	}
}
