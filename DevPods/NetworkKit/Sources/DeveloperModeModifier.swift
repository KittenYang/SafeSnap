//
//  DeveloperModeModifier.swift
//  NetworkKit
//
//  Created by KittenYang on 1/22/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import Combine

public struct DeveloperModeModifier: ViewModifier {
	
	@State var alertIsPresented: Bool = false
	@State var inputPass: String?
	
	struct Anchors {
		static var clickCount = 0
	}
	
	public init() {}
	
	public func body(content: Content) -> some View {
		content
			.textFieldAlert(
				isPresented: $alertIsPresented,
				title: "Input Password",
				text: "",
				placeholder: "",
				action: { newText in
					if newText == "310310" {
						NetworkEnviroment.shared.isDeveloperMode.toggle()
					}
					Anchors.clickCount = 0
				}
			)
			.onTapGesture {
				Anchors.clickCount += 1
				print("Anchors.clickCount +1")
				if Anchors.clickCount == 6 {
					print("alertIsPresented")
					alertIsPresented = true
				}
			}
	}

}

extension View {

	public func textFieldAlert(
		isPresented: Binding<Bool>,
		title: String,
		text: String = "",
		placeholder: String = "",
		action: @escaping (String?) -> Void
	) -> some View {
		self.modifier(TextFieldAlertModifier(isPresented: isPresented, title: title, text: text, placeholder: placeholder, action: action))
	}
	
}

public struct TextFieldAlertModifier: ViewModifier {

	@State private var alertController: UIAlertController?

	@Binding var isPresented: Bool

	let title: String
	let text: String
	let placeholder: String
	let action: (String?) -> Void

	public func body(content: Content) -> some View {
		content.onChange(of: isPresented) { isPresented in
			if isPresented, alertController == nil {
				let alertController = makeAlertController()
				self.alertController = alertController
				
				let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
				if var topController = keyWindow?.rootViewController {
					while let presentedViewController = topController.presentedViewController {
						topController = presentedViewController
					}
					topController.present(alertController, animated: true)
				}
				
			} else if !isPresented, let alertController = alertController {
				alertController.dismiss(animated: true)
				self.alertController = nil
			}
		}
	}

	private func makeAlertController() -> UIAlertController {
		let controller = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		controller.addTextField {
			$0.placeholder = self.placeholder
			$0.text = self.text
		}
		controller.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
			self.action(nil)
			shutdown()
		})
		controller.addAction(UIAlertAction(title: "OK", style: .default) { _ in
			self.action(controller.textFields?.first?.text)
			shutdown()
		})
		return controller
	}

	private func shutdown() {
		isPresented = false
		alertController = nil
	}

}
