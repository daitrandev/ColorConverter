//
//  Extensions.swift
//  ColorConverter
//
//  Created by Dai Tran on 11/3/18.
//  Copyright © 2018 DaiTranDev. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
}
