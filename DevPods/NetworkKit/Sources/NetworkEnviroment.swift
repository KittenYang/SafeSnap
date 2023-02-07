//
//  NetworkEnviroment.swift
//  GisKit
//
//  Created by Qitao Yang on 2020/10/18.
//

import Foundation

public enum EnvironmentType: String, Codable {
	case release
	case debug
}

public class NetworkEnviroment {
	
	public static let shared: NetworkEnviroment = NetworkEnviroment()
	
	private init() {}
	
#if DEBUG
	static let defaultEnvironment = EnvironmentType.debug
	static let defaultDeveloperModeEnabel = true
#else
	static let defaultEnvironment = EnvironmentType.release
	static let defaultDeveloperModeEnabel = false
#endif
	
	// MARK: - api mode
	public var environment: EnvironmentType {
		get {
			if let envString = UserDefaults.standard.value(forKey: "EnviromentKey") as? String {
				return EnvironmentType(rawValue: envString) ?? NetworkEnviroment.defaultEnvironment
			}
			return NetworkEnviroment.defaultEnvironment
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "EnviromentKey")
			// 强制退出，重启进入
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
				guard let _ = self else { return }
				exit(0)
			}
		}
	}
	
	public var isDeveloperMode: Bool {
		get {
			UserDefaults.standard.value(forKey: "DeveloperModeKey") as? Bool ?? NetworkEnviroment.defaultDeveloperModeEnabel
		}
		set {
			UserDefaults.standard.setValue(newValue, forKey: "DeveloperModeKey")
			// 强制退出，重启进入
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
				guard let _ = self else { return }
				exit(0)
			}
		}
	}
	
	// TODO: - URL
	//    public var baseURL: String {
	//        switch environment {
	//        case .debug:
	//            return "https://gisk.kittenyang.com"
	//        default:
	//            return "https://gisk.kittenyang.com"//"https://api.gisk.tech"
	//        }
	//    }
}

