//
//  HomeViewController.swift
//  ColorConverter
//
//  Created by Dai Tran on 10/21/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds

class HomeViewController: UIViewController, MFMailComposeViewControllerDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var themeButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    
    let mainBackgroundColor:[UIColor] = [UIColor.white, UIColor.black]
    
    let mainTintColorNavigationBar:[UIColor] = [UIColor.black, UIColor.orange]
    
    weak var delegate: HomeViewControllerDelegate?
    
    var currentThemeIndex = 0
    
    var labelArray:[UILabel?] = []
    
    var bannerView: GADBannerView!
    
    var isFreeVersion = Bundle.main.infoDictionary?["isFreeVersion"] as? Bool ?? true
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentThemeIndex == 0 ? .default : .lightContent
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
        }
        
        // Do any additional setup after loading the view.        
        labelArray = [themeLabel, feedbackLabel, rateLabel, shareLabel]
        loadColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func OnThemeAction(_ sender: Any) {
        currentThemeIndex = 1 - currentThemeIndex
        UserDefaults.standard.setValue(currentThemeIndex, forKey: "ThemeIndex")
        print(UserDefaults.standard.integer(forKey: "ThemeIndex"))
        loadColor()
    }

    @IBAction func OnDoneAction(_ sender: Any) {
        delegate?.loadTheme()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OnFeedbackAction(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["universappteam@gmail.com"])
        mailComposerVC.setSubject("[Color-Calculator Feedback]")
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OnRateAction(_ sender: Any) {
        let appId:String = "id1300478165"
        
        rateApp(appId: appId) { success in
            print("RateApp \(success)")
        }
    }
    
    @IBAction func OnShareAction(_ sender: Any) {
        let appId:String = "id1300478165"
        let message: String = "https://itunes.apple.com/app/\(appId)"
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = self.view
        present(vc, animated: true)
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
 
    func loadColor() {
        currentThemeIndex = UserDefaults.standard.integer(forKey: "ThemeIndex")
        view.backgroundColor = mainBackgroundColor[currentThemeIndex]
        
        if (currentThemeIndex == 0) {
            themeButton.setImage(#imageLiteral(resourceName: "theme"), for: .normal)
            feedbackButton.setImage(#imageLiteral(resourceName: "feedback"), for: .normal)
            rateButton.setImage(#imageLiteral(resourceName: "rate"), for: .normal)
            shareButton.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        } else {
            themeButton.setImage(#imageLiteral(resourceName: "theme-orange"), for: .normal)
            feedbackButton.setImage(#imageLiteral(resourceName: "feedback-orange"), for: .normal)
            rateButton.setImage(#imageLiteral(resourceName: "rate-orange"), for: .normal)
            shareButton.setImage(#imageLiteral(resourceName: "share-orange"), for: .normal)
        }
        
        setNeedsStatusBarAppearanceUpdate()
        
        for i in 0..<labelArray.count {
            labelArray[i]?.textColor = mainBackgroundColor[1 - currentThemeIndex]
        }
        
        navigationController?.navigationBar.tintColor = mainTintColorNavigationBar[currentThemeIndex]
        navigationController?.navigationBar.barTintColor = mainBackgroundColor[currentThemeIndex]
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: mainBackgroundColor[1 - currentThemeIndex]]
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
