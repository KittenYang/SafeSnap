//
//  family_daoApp.swift
//  family-dao
//
//  Created by KittenYang on 6/25/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import LanguageManagerSwiftUI

@main
struct family_daoApp: App {
	
	let dataStack = CoreDataStack.shared
	
	var body: some Scene {
		WindowGroup {
			LanguageManagerView(.deviceLanguage) {
				AppTabbar()
					.transition(.blurScale)
				//				.environment(\.colorScheme, .light)
				//				.modifier(DarkModeViewModifier())
					.environment(\.managedObjectContext, dataStack.persistentContainer.viewContext)
					.environmentObject(UserSettings.shared)
			}
			.overlayContainer(Constant.AppContainerID, containerConfiguration: .hudConfiguration)
		}
	}
}

class AppThemeViewModel: ObservableObject {
	
	@AppStorage("isDarkMode") var isDarkMode: Bool = true                           // also exists in DarkModeViewModifier()
//	@AppStorage("appTintColor") var appTintColor: AppTintColorOptions = .indigo
	
}

struct DarkModeViewModifier: ViewModifier {
	@ObservedObject var appThemeViewModel: AppThemeViewModel = AppThemeViewModel()
	
	public func body(content: Content) -> some View {
		content
			.preferredColorScheme(appThemeViewModel.isDarkMode ? .dark : appThemeViewModel.isDarkMode == false ? .light : nil)
//			.accentColor(Color(appThemeViewModel.appTintColor.rawValue))
	}
}
