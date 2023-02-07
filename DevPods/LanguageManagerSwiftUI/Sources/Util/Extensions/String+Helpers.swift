//
//  File.swift
//  
//
//  Created by abedalkareem omreyh on 09/04/2021.
//

import SwiftUI

public extension String {
  ///
  /// Returns localized key for the string.
  ///
  var localizedKey: LocalizedStringKey {
    return LocalizedStringKey(self)
  }
}


public extension String {
	var languageLocalizable: String {
		var lang = UserDefaults.standard.string(forKey: DefaultsKeys.selectedLanguage.rawValue)// ?? "en"
		if  lang == Languages.deviceLanguage.rawValue {
			lang = Bundle.main.preferredLocalizations.first
		}
		if let lproj = Bundle.main.path(forResource: lang, ofType: "lproj"),
			let bundle = Bundle(path: lproj) {
			return bundle.localizedString(forKey: self, value: nil, table: "Localizable")
		}
		return self
	}
}
