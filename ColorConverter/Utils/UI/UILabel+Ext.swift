//
//  UILabel+Ext.swift
//  ColorConverter
//
//  Created by DaiTran on 8/12/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit

extension UILabel {
    func makeRound() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
    }
}
