//
//  DecodingStrategy.swift
//  SuperCodableJSON
//
//  Created by KittenYang on 6/20/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

extension SuperJSONDecoder {
	
	public enum KeyNotFoundDecodingStrategy {
		case `throw`
		case useDefaultValue
	}
	
	public enum ValueNotFoundDecodingStrategy {
		case `throw`
		case useDefaultValue
		case custom(JSONTransformer)
	}
	
	public enum JSONStringDecodingStrategy {
		case containsKeys([CodingKey])
		case all
	}
}

extension SuperJSONDecoder {
	
	public struct NestedContainerDecodingStrategy {
		
		public enum KeyNotFound {
			case `throw`
			case useEmptyContainer
			case useDefaultValue
		}
		
		public enum ValueNotFound {
			case `throw`
			case useEmptyContainer
			case useDefaultValue
		}
		
		public enum TypeMismatch {
			case `throw`
			case useEmptyContainer
			case useDefaultValue
		}
		
		public var keyNotFound: KeyNotFound
		
		public var valueNotFound: ValueNotFound
		
		public var typeMismatch: TypeMismatch
		
		public init(keyNotFound: KeyNotFound = .useDefaultValue,
								valueNotFound: ValueNotFound = .useDefaultValue,
								typeMismatch: TypeMismatch = .useDefaultValue) {
			self.keyNotFound = keyNotFound
			self.valueNotFound = valueNotFound
			self.typeMismatch = typeMismatch
		}
	}
}

public extension JSONDecoder.KeyDecodingStrategy {
	static func mapper(_ container: [[String]: String]) -> JSONDecoder.KeyDecodingStrategy {
		.custom { SuperJSONKeysConverter(container)($0) }
	}
}

