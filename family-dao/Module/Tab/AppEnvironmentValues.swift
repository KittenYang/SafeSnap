//
//  AppEnvironmentValues.swift
//  family-dao
//
//  Created by KittenYang on 8/31/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

extension EnvironmentValues {
	var modalTransitionPercent: CGFloat {
		get { return self[ModalTransitionKey.self] }
		set { self[ModalTransitionKey.self] = newValue }
	}
}

public struct ModalTransitionKey: EnvironmentKey {
	public static let defaultValue: CGFloat = 0
}
