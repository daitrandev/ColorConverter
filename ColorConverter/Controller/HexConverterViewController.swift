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

class HexConverterViewController: UIViewController, UITextFieldDelegate, HomeViewControllerDelegate {

    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var textField: UITextField!
        
    let allowingCharacters:String = "aAbBcCdDeEfF0123456789"
    
    var isLightTheme: Bool = UserDefaults.standard.bool(forKey: isLightThemeKey)
    
    let mainBackgroundColor:[UIColor] = [UIColor.white, UIColor.black]
    
    let mainLabelColor: [UIColor] = [UIColor.black, UIColor.orange]

    var bannerView: GADBannerView!
    
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
            
            textField.isEnabled = false
            textField.backgroundColor = UIColor.gray
        }
        
        // Do any additional setup after loading the view.
        viewColor.layer.cornerRadius = 10
        viewColor.layer.masksToBounds = true
        
        textField.makeRound()
        textField.layer.backgroundColor = UIColor.white.cgColor
        
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
    
    func loadTheme() {
        isLightTheme = UserDefaults.standard.bool(forKey: isLightThemeKey)
        
        view.backgroundColor = isLightTheme ? .white : .black
        
        navigationController?.navigationBar.barTintColor = isLightTheme ? .white : .black
        navigationController?.navigationBar.tintColor = isLightTheme ? .black : .orange
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: isLightTheme ? UIColor.black : UIColor.white]
        
        tabBarController?.tabBar.barTintColor = isLightTheme ? .white : .black
        tabBarController?.tabBar.tintColor = isLightTheme ? .black : .orange
        
        setNeedsStatusBarAppearanceUpdate()
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

extension HexConverterViewController: MenuViewControllerDelegate {
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

extension HexConverterViewController: MFMailComposeViewControllerDelegate {
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
