//
//  CMYKConverterViewController.swift
//  ColorConverter
//
//  Created by Dai Tran on 10/21/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CMYKConverterViewController: UIViewController, UITextFieldDelegate, HomeViewControllerDelegate, GADBannerViewDelegate {
    
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
    
    var rgb: RGB?
    
    var valueLabelArray:[UILabel] = []
    
    var labelArray: [UILabel] = []
    
    var sliderArray:[UISlider] = []
    
    let mainBackgroundColor:[UIColor] = [UIColor.white, UIColor.black]
    
    let mainLabelColor: [UIColor] = [UIColor.black, UIColor.orange]
    
    var currentThemeIndex: Int = 0
    
    var bannerView: GADBannerView!
    
    var freeVersion: Bool = true
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentThemeIndex == 0 ? .default : .lightContent
    }
    
    @IBOutlet weak var viewColor: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (freeVersion) {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            addBannerViewToView(bannerView)
            
            bannerView.adUnitID = "ca-app-pub-7005013141953077/9075404978"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }

        // Do any additional setup after loading the view.
        viewColor.layer.cornerRadius = 10
        viewColor.layer.masksToBounds = true
        
        navigationController?.navigationBar.tintColor = UIColor.black
        
        valueLabelArray = [cValueLabel, mValueLabel, yValueLabel, kValueLabel]
        labelArray = [cLabel, mLabel, yLabel, kLabel]
        sliderArray = [cValueSlider, mValueSlider, yValueSlider, kValueSlider]
         
        for i in 0..<sliderArray.count {
            sliderArray[i].isEnabled = !freeVersion
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTheme()
        showColor()
        
        if (freeVersion) {
            let alert = createAlert(title: "Color Calculator++", message: "Upgrade to Color Calculator++ then you can use all functions without ads")
            
            present(alert, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OnRefreshAction(_ sender: Any) {
        for i in 0..<4 {
            valueLabelArray[i].text = "128"
            sliderArray[i].value = 128
        }
        
        showColor()
    }
    
    @IBAction func OnSlideValueChanged(_ sender: UISlider) {
        valueLabelArray[sender.tag].text = String(Int(sender.value))
        UtilitiesConverter.rgb = nil
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let homeVC = nav.topViewController as? HomeViewController {
            homeVC.delegate = self
        }
    }
    
    func showColor() {
        let rgbValue = UtilitiesConverter.rgb ?? UtilitiesConverter.CMYKtoRGB(c: CGFloat(Int(sliderArray[0].value))/255, m: CGFloat(Int(sliderArray[1].value))/255, y: CGFloat(Int(sliderArray[2].value))/255, k: CGFloat(Int(sliderArray[3].value))/255)
        
        if let rgb = UtilitiesConverter.rgb  {
            let cmyk = UtilitiesConverter.RGBtoCMYK(r: rgb.red, g: rgb.green, b: rgb.blue)
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

        UtilitiesConverter.rgb = (red: rgbValue.red, green: rgbValue.green, blue: rgbValue.blue, alpha: CGFloat(1.0))
    }

    
    func loadTheme() {
        currentThemeIndex = UserDefaults.standard.integer(forKey: "ThemeIndex")
        
        view.backgroundColor = mainBackgroundColor[currentThemeIndex]
        
        navigationController?.navigationBar.barTintColor = mainBackgroundColor[currentThemeIndex]
        navigationController?.navigationBar.tintColor = mainLabelColor[currentThemeIndex]
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: mainBackgroundColor[1 - currentThemeIndex]]
        
        tabBarController?.tabBar.barTintColor = mainBackgroundColor[currentThemeIndex]
        tabBarController?.tabBar.tintColor = mainLabelColor[currentThemeIndex]
        
        for i in 0..<valueLabelArray.count {
            valueLabelArray[i].textColor = mainLabelColor[currentThemeIndex]
            labelArray[i].textColor = mainLabelColor[currentThemeIndex]
            sliderArray[i].tintColor = mainLabelColor[currentThemeIndex]
        }
        
        setNeedsStatusBarAppearanceUpdate()
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
