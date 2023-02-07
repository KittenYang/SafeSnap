//
//  ViewExtension.swift
//  MultiSigKit
//
//  Created by KittenYang on 12/10/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

@available(iOS 14.0, *)
public struct RedactingView<Input: View, Output: View>: View {
	var content: Input
	var modifier: (Input) -> Output
	
	@Environment(\.redactionReasons) private var reasons
	
	public var body: some View {
		if reasons.isEmpty {
			content
		} else {
			modifier(content)
		}
	}
}

@available(iOS 14.0, *)
public extension View {
	func whenRedacted<T: View>(
		apply modifier: @escaping (Self) -> T
	) -> some View {
		RedactingView(content: self, modifier: modifier)
	}
}

public extension View {
	/// Applies a modifier to a view conditionally.
	///
	/// - Parameters:
	///   - condition: The condition to determine if the content should be applied.
	///   - content: The modifier to apply to the view.
	/// - Returns: The modified view.
	@ViewBuilder func modifier<T: View>(
		if condition: @autoclosure () -> Bool,
		then content: (Self) -> T
	) -> some View {
		if condition() {
			content(self)
		} else {
			self
		}
	}
	
	/// Applies a modifier to a view conditionally.
	///
	/// - Parameters:
	///   - condition: The condition to determine the content to be applied.
	///   - trueContent: The modifier to apply to the view if the condition passes.
	///   - falseContent: The modifier to apply to the view if the condition fails.
	/// - Returns: The modified view.
	@ViewBuilder func modifier<TrueContent: View, FalseContent: View>(
		if condition: @autoclosure () -> Bool,
		then trueContent: (Self) -> TrueContent,
		else falseContent: (Self) -> FalseContent
	) -> some View {
		if condition() {
			trueContent(self)
		} else {
			falseContent(self)
		}
	}
}


public extension View {
	@ViewBuilder
	func `if`<V: View>(_ condition: @autoclosure () -> Bool, return result: (Self) -> V) -> some View {
		if condition() {
			result(self)
		} else {
			self
		}
	}
}
