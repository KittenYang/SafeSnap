//
//  App+.swift
//  MultiSigKit
//
//  Created by KittenYang on 2/2/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import LanguageManagerSwiftUI

public extension String {
	var appLocalizable: String {
		return self.languageLocalizable
	}
}
