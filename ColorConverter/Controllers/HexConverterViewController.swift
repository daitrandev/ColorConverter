//
//  HexConverterViewController.swift
//  ColorConverter
//
//  Created by Dai Tran on 10/22/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import SideMenu
import MessageUI
import GoogleMobileAds

class HexConverterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var textField: UITextField!
        
    let allowingCharacters:String = "aAbBcCdDeEfF0123456789"
        
    let mainBackgroundColor:[UIColor] = [UIColor.white, UIColor.black]
    
    let mainLabelColor: [UIColor] = [UIColor.black, UIColor.orange]

    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-7005013141953077/9075404978"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        textField.isEnabled = false
        textField.backgroundColor = UIColor.gray
        
        // Do any additional setup after loading the view.
        viewColor.layer.cornerRadius = 10
        viewColor.layer.masksToBounds = true
        
        textField.makeRound()
        textField.layer.backgroundColor = UIColor.white.cgColor
        
        navigationController?.navigationBar.tintColor = UIColor.black
    }

    override func viewWillAppear(_ animated: Bool) {
        showColor()
    }
    
    @IBAction func OnRefreshAction(_ sender: Any) {
        textField.text = "000000"
        UtilitiesConverter.rgb = nil
        showColor()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (string == "") {
            return true
        }
        
        if (textField.text?.count == 6 || string.count > 6) {
            return false
        }
        
        for character in string {
            if (!allowingCharacters.contains(character)) {
                return false
            }
        }
        
        return true
    }
    
    @IBAction func textFieldEditingChange(_ sender: UITextField) {
        sender.text = sender.text?.uppercased()
        UtilitiesConverter.rgb = nil
        showColor()
    }

    func showColor() {
        let rgbValue = UtilitiesConverter.rgb ?? UtilitiesConverter.ConvertHexColorToRGB(hexString: textField.text!)
        
        if let rgb = UtilitiesConverter.rgb  {
            let hex = UtilitiesConverter.ConvertRGBToHex(rgb: rgb)
            textField.text = hex
        }
        
        let red = CGFloat(rgbValue.red)
        let green = CGFloat(rgbValue.green)
        let blue = CGFloat(rgbValue.blue)
        let alpha = CGFloat(1.0)
        
        viewColor?.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        UtilitiesConverter.rgb = (red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension HexConverterViewController: GADBannerViewDelegate {
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: topLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
        
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
}
