//
//  CMYKConverterViewController.swift
//  ColorConverter
//
//  Created by Dai Tran on 10/21/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CMYKConverterViewController: UIViewController, UITextFieldDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var cValueLabel: UILabel!
    @IBOutlet weak var mValueLabel: UILabel!
    @IBOutlet weak var yValueLabel: UILabel!
    @IBOutlet weak var kValueLabel: UILabel!
    
    @IBOutlet weak var cLabel: UILabel!
    @IBOutlet weak var mLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var kLabel: UILabel!
    
    @IBOutlet weak var cValueSlider: UISlider!
    @IBOutlet weak var mValueSlider: UISlider!
    @IBOutlet weak var yValueSlider: UISlider!
    @IBOutlet weak var kValueSlider: UISlider!
    
    @IBOutlet weak var viewColor: UIView!
    
    var rgb: RGB?
    
    lazy var valueLabelArray:[UILabel] = [cValueLabel, mValueLabel, yValueLabel, kValueLabel]
    
    lazy var labelArray: [UILabel] = [cLabel, mLabel, yLabel, kLabel]
    
    lazy var sliderArray:[UISlider] = [cValueSlider, mValueSlider, yValueSlider, kValueSlider]
    
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
            
            for i in 0..<sliderArray.count {
                sliderArray[i].isEnabled = false
            }
            
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
        
        setupColor()
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "Roboto-Medium", size: 18)!
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            
            sliderArray.forEach {
                $0.tintColor = traitCollection.userInterfaceStyle.themeColor
            }
        } else {
            tabBarController?.tabBar.tintColor = .black
            tabBarController?.tabBar.barTintColor = .white
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = .black
            
            sliderArray.forEach {
                $0.tintColor = .black
            }
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
        for i in 0..<4 {
            valueLabelArray[i].text = "128"
            sliderArray[i].value = 128
        }
        ColorConverter.rgb = nil
        showColor()
    }
    
    @IBAction func OnSlideValueChanged(_ sender: UISlider) {
        valueLabelArray[sender.tag].text = String(Int(sender.value))
        ColorConverter.rgb = nil
        showColor()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == "") {
            return true
        }
        
        if (textField.text?.count == 6) {
            return false
        }
        
        return true
    }
    
    func showColor() {
        let rgbValue = ColorConverter.rgb ?? ColorConverter.CMYKtoRGB(c: CGFloat(Int(sliderArray[0].value))/255, m: CGFloat(Int(sliderArray[1].value))/255, y: CGFloat(Int(sliderArray[2].value))/255, k: CGFloat(Int(sliderArray[3].value))/255)
        
        if let rgb = ColorConverter.rgb  {
            let cmyk = ColorConverter.RGBtoCMYK(r: rgb.red, g: rgb.green, b: rgb.blue)
            sliderArray[0].value = Float(cmyk.c)*255
            sliderArray[1].value = Float(cmyk.m)*255
            sliderArray[2].value = Float(cmyk.y)*255
            sliderArray[3].value = Float(cmyk.k)*255
            for i in 0..<sliderArray.count {
                valueLabelArray[i].text = String(Int(sliderArray[i].value))
            }
        }
        
        let red = rgbValue.red
        let green = rgbValue.green
        let blue = rgbValue.blue
        let alpha = 1.0
        viewColor?.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: CGFloat(alpha))

        ColorConverter.rgb = (red: rgbValue.red, green: rgbValue.green, blue: rgbValue.blue, alpha: CGFloat(1.0))
    }
    
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

extension CMYKConverterViewController: PurchasingPopupViewControllerDelegate {
    func removeAds() {
        for index in 0..<sliderArray.count {
            sliderArray[index].isEnabled = true
        }
        
        bannerView?.removeFromSuperview()
        navigationItem.leftBarButtonItem = nil
    }
}
