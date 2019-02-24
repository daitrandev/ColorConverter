//
//  CMYKConverterViewController.swift
//  ColorConverter
//
//  Created by Dai Tran on 10/21/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import SideMenu
import MessageUI
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
    
    lazy var valueLabelArray:[UILabel] = [cValueLabel, mValueLabel, yValueLabel, kValueLabel]
    
    lazy var labelArray: [UILabel] = [cLabel, mLabel, yLabel, kLabel]
    
    lazy var sliderArray:[UISlider] = [cValueSlider, mValueSlider, yValueSlider, kValueSlider]
    
    let mainBackgroundColor:[UIColor] = [UIColor.white, UIColor.black]
    
    let mainLabelColor: [UIColor] = [UIColor.black, UIColor.orange]
    
    var isLightTheme: Bool = UserDefaults.standard.bool(forKey: isLightThemeKey)
    
    var bannerView: GADBannerView!
    
    var isFreeVersion = Bundle.main.infoDictionary?["isFreeVersion"] as? Bool ?? true
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isLightTheme ? .default : .lightContent
    }
    
    @IBOutlet weak var viewColor: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        if isFreeVersion {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            addBannerViewToView(bannerView)
            
            bannerView.adUnitID = "ca-app-pub-7005013141953077/9075404978"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
            
            for i in 0..<sliderArray.count {
                sliderArray[i].isEnabled = false
            }
        }
        
        // Do any additional setup after loading the view.
        viewColor.layer.cornerRadius = 10
        viewColor.layer.masksToBounds = true
        
        navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTheme()
        showColor()
        if isFreeVersion {
            let alert = createAlert(title: "Color Calculator++", message: "Upgrade to Color Calculator++ then you can use all functions without ads") { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            }
            
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
        UtilitiesConverter.rgb = nil
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
    
    @IBAction func didTapHome(_ sender: Any) {
        let menuViewController = MenuViewController()
        menuViewController.delegate = self
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: menuViewController)
        
        SideMenuManager.default.menuLeftNavigationController?.navigationBar.backgroundColor = .green
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
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
        isLightTheme = UserDefaults.standard.bool(forKey: isLightThemeKey)
        
        view.backgroundColor = isLightTheme ? .white : .black
        
        navigationController?.navigationBar.barTintColor = isLightTheme ? .white : .black
        navigationController?.navigationBar.tintColor = isLightTheme ? .black : .orange
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: isLightTheme ? UIColor.black : UIColor.white]
        
        tabBarController?.tabBar.barTintColor = isLightTheme ? .white : .black
        tabBarController?.tabBar.tintColor = isLightTheme ? .black : .orange
        
        for i in 0..<valueLabelArray.count {
            valueLabelArray[i].textColor = isLightTheme ? .black : .orange
            labelArray[i].textColor = isLightTheme ? .black : .orange
            sliderArray[i].tintColor = isLightTheme ? .black : .orange
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

extension CMYKConverterViewController: MenuViewControllerDelegate {
    func presentMailComposeViewController() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func presentRatingAction() {
        let appId:String = isFreeVersion ? "id1300478165" : "id1300442070"
        
        rateApp(appId: appId) { success in
            print("RateApp \(success)")
        }
    }
    
    func presentShareAction() {
        let appId:String = isFreeVersion ? "id1300478165" : "id1300442070"
        let message: String = "https://itunes.apple.com/app/\(appId)"
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = self.view
        present(vc, animated: true)
    }
    
    func changeTheme() {
        isLightTheme = !isLightTheme
        UserDefaults.standard.set(isLightTheme, forKey: isLightThemeKey)
        loadTheme()
    }
}

extension CMYKConverterViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["universappteam@gmail.com"])
        mailComposerVC.setSubject("[Color-Calculator Feedback]")
        
        return mailComposerVC
    }
}

