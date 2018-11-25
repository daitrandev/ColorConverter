//
//  HexConverterViewController.swift
//  ColorConverter
//
//  Created by Dai Tran on 10/22/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit

class HexConverterViewController: UIViewController, UITextFieldDelegate, HomeViewControllerDelegate {

    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var textField: UITextField!
        
    let allowingCharacters:String = "aAbBcCdDeEfF0123456789"
    
    var currentThemeIndex = 0
    
    let mainBackgroundColor:[UIColor] = [UIColor.white, UIColor.black]
    
    let mainLabelColor: [UIColor] = [UIColor.black, UIColor.orange]
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentThemeIndex == 0 ? .default : .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OnRefreshAction(_ sender: Any) {
        textField.text = ""
        viewColor.backgroundColor = UIColor.black
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let homeVC = nav.topViewController as? HomeViewController {
            homeVC.delegate = self
        }
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
        currentThemeIndex = UserDefaults.standard.integer(forKey: "ThemeIndex")
        
        view.backgroundColor = mainBackgroundColor[currentThemeIndex]
        
        navigationController?.navigationBar.barTintColor = mainBackgroundColor[currentThemeIndex]
        navigationController?.navigationBar.tintColor = mainLabelColor[currentThemeIndex]
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: mainBackgroundColor[1 - currentThemeIndex]]
        
        tabBarController?.tabBar.barTintColor = mainBackgroundColor[currentThemeIndex]
        tabBarController?.tabBar.tintColor = mainLabelColor[currentThemeIndex]
        
        setNeedsStatusBarAppearanceUpdate()
    }
}
