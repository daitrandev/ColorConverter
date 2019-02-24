//
//  RGBConverterViewController.swift
//  ColorConverter
//
//  Created by Dai Tran on 10/21/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import SideMenu
import MessageUI
import GoogleMobileAds

class RGBConverterViewController: UIViewController, UITextFieldDelegate, HomeViewControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    
    @IBOutlet weak var rValueLabel: UILabel!
    @IBOutlet weak var gValueLabel: UILabel!
    @IBOutlet weak var bValueLabel: UILabel!
    
    @IBOutlet weak var rLabel: UILabel!
    @IBOutlet weak var gLabel: UILabel!
    @IBOutlet weak var bLabel: UILabel!
    
    @IBOutlet weak var rValueSlider: UISlider!
    @IBOutlet weak var gValueSlider: UISlider!
    @IBOutlet weak var bValueSlider: UISlider!
    
    @IBOutlet weak var viewColor: UIView!
    
    var rgb: RGB?
    
    lazy var valueLabelArray:[UILabel] = [rValueLabel, gValueLabel, bValueLabel]
    
    lazy var labelArray:[UILabel] =  [rLabel, gLabel, bLabel]
    
    lazy var sliderArray:[UISlider] = [rValueSlider, gValueSlider, bValueSlider]
    
    let mainBackgroundColor:[UIColor] = [UIColor.white, UIColor.black]
    
    let mainLabelColor: [UIColor] = [UIColor.black, UIColor.orange]
    
    var isLightTheme: Bool = UserDefaults.standard.bool(forKey: isLightThemeKey)
    
    var bannerView: GADBannerView!
    
    var interstitial: GADInterstitial?
    
    var isFreeVersion = Bundle.main.infoDictionary?["isFreeVersion"] as? Bool ?? true
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isLightTheme ? .default : .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isFreeVersion {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            addBannerViewToView(bannerView)
            
            bannerView.adUnitID = "ca-app-pub-7005013141953077/9075404978"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
            
            interstitial = createAndLoadInterstitial()
        }
        
        // Do any additional setup after loading the view.
        viewColor.layer.cornerRadius = 10
        viewColor.layer.masksToBounds = true
        
        if let value = UserDefaults.standard.object(forKey: isLightThemeKey) as? Bool {
            isLightTheme = value
        } else {
            UserDefaults.standard.set(true, forKey: isLightThemeKey)
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTheme()
        showColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func OnRefreshAction(_ sender: Any) {
        for i in 0..<3 {
            valueLabelArray[i].text = String(128)
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
    
    func showColor() {
        let rgbValue = UtilitiesConverter.rgb ?? (red: CGFloat(sliderArray[0].value/255), green: CGFloat(sliderArray[1].value/255), blue: CGFloat(sliderArray[2].value/255),alpha: CGFloat(1))
        
        if let rgb = UtilitiesConverter.rgb  {
            sliderArray[0].value = Float(rgb.red)*255
            sliderArray[1].value = Float(rgb.green)*255
            sliderArray[2].value = Float(rgb.blue)*255
            for i in 0..<sliderArray.count {
                valueLabelArray[i].text = String(Int(sliderArray[i].value))
            }
        }
        let red = rgbValue.red
        let green = rgbValue.green
        let blue = rgbValue.blue
        let alpha = CGFloat(1.0)
        
        viewColor?.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        UtilitiesConverter.rgb = (red: red, green: green, blue: blue, alpha: alpha)
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
    
    private func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-7005013141953077/3308907121")
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        // Remove the following line before you upload the app
        request.testDevices = [ kGADSimulatorID ]
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.setNeedsStatusBarAppearanceUpdate()
    }
}

extension RGBConverterViewController: MenuViewControllerDelegate {
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

extension RGBConverterViewController: MFMailComposeViewControllerDelegate {
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


