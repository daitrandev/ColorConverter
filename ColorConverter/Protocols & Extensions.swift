//
//  Protocols & Extensions.swift
//  ColorConverter
//
//  Created by Dai Tran on 3/12/18.
//  Copyright © 2018 DaiTranDev. All rights reserved.
//

import UIKit

protocol HomeViewControllerDelegate:class {
    func loadTheme()
}

extension HomeViewControllerDelegate {
    
    func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No, thanks.", style: .cancel  , handler: nil))
        alert.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { (action) in
            self.rateApp(appId: "id1300442070") { success in
                print("RateApp \(success)")
            }
        }))
        
        return alert
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
