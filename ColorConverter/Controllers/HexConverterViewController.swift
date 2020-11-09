//
//  HexConverterViewController.swift
//  ColorConverter
//
//  Created by Dai Tran on 10/22/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import GoogleMobileAds

class HexConverterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var textField: UITextField!
        
    let allowingCharacters:String = "aAbBcCdDeEfF0123456789"

    var bannerView: GADBannerView!
    
    var isPurchased: Bool {
        GlobalKeychain.getBool(for: KeychainKey.isPurchased) ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isPurchased {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            addBannerViewToView(bannerView)
            
            bannerView.adUnitID = bannerAdsUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
            
            textField.isEnabled = false
            textField.backgroundColor = UIColor.gray
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "unlock"),
                style: .plain,
                target: self,
                action: #selector(didTapUnlock)
            )
        }
        
        // Do any additional setup after loading the view.
        viewColor.layer.cornerRadius = 10
        viewColor.layer.masksToBounds = true
        
        textField.makeRound()
        textField.layer.backgroundColor = UIColor.white.cgColor
        
        setupColor()
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "Roboto-Medium", size: 18)!
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        showColor()
        
        if isPurchased {
            removeAds()
        }
    }
    
    private func setupColor() {
        if #available(iOS 13, *) {
            tabBarController?.tabBar.tintColor = traitCollection.userInterfaceStyle.themeColor
            tabBarController?.tabBar.barTintColor = .secondarySystemBackground
            navigationController?.navigationBar.barTintColor = .secondarySystemBackground
            navigationController?.navigationBar.tintColor = traitCollection.userInterfaceStyle.themeColor
        } else {
            tabBarController?.tabBar.tintColor = .black
            tabBarController?.tabBar.barTintColor = .white
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = .black
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupColor()
    }
    
    @objc private func didTapUnlock() {
        let vc = PurchasingPopupViewController()
        vc.delegate = self
        tabBarController?.present(vc, animated: true)
    }
    
    @IBAction func OnRefreshAction(_ sender: Any) {
        textField.text = "000000"
        ColorConverter.rgb = nil
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
        ColorConverter.rgb = nil
        showColor()
    }

    func showColor() {
        let rgbValue = ColorConverter.rgb ?? ColorConverter.ConvertHexColorToRGB(hexString: textField.text!)
        
        if let rgb = ColorConverter.rgb  {
            let hex = ColorConverter.ConvertRGBToHex(rgb: rgb)
            textField.text = hex
        }
        
        let red = CGFloat(rgbValue.red)
        let green = CGFloat(rgbValue.green)
        let blue = CGFloat(rgbValue.blue)
        let alpha = CGFloat(1.0)
        
        viewColor?.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        ColorConverter.rgb = (red: red, green: green, blue: blue, alpha: alpha)
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

extension HexConverterViewController: PurchasingPopupViewControllerDelegate {
    func removeAds() {
        textField.isEnabled = true
        textField.backgroundColor = .white
        
        bannerView?.removeFromSuperview()
        navigationItem.leftBarButtonItem = nil
    }
}
