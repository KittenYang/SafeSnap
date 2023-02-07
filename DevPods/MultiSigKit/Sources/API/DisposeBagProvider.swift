//
//  DisposeBagProvider.swift
//  GisKit
//
//  Created by Qitao Yang on 2020/10/18.
//

import Foundation
import UIKit
import RxSwift

fileprivate struct AssociatedKeys {
	static var disposeBag: String = "disposeBag"
}

public protocol DisposeBagProvider {
	var disposeBag: DisposeBag { get }
}

public extension DisposeBagProvider {
	var disposeBag: DisposeBag {
		get {
			if let bag = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag {
				return bag
			}
			let newBag = DisposeBag()
			objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, newBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return newBag
		}
	}
}

extension UIViewController: DisposeBagProvider {}
extension UIView: DisposeBagProvider {}

