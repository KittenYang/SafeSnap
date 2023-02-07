//
//  Notifications.swift
//  family-dao
//
//  Created by KittenYang on 10/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation

public extension NSNotification.Name {
	// MARK: - Core
	
	static let selectedSafeChanged = NSNotification.Name("io.gnosis.safe.selectedSafeChanged")
	static let selectedSafeUpdated = NSNotification.Name("io.gnosis.safe.selectedSafeUpdated")
	static let selectedSafeTokenUpdated = NSNotification.Name("io.gnosis.safe.selectedSafeTokenUpdated")
	
	static let safeCreationUpdate = NSNotification.Name("io.gnosis.safe.safeCreationUpdate")
}
