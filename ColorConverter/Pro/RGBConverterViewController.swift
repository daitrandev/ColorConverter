//
//  RGBConverterViewController.swift
//  ColorConverter
//
//  Created by Dai Tran on 10/21/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit

class RGBConverterViewController: UIViewController, UITextFieldDelegate, HomeViewControllerDelegate {
    
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
    
    var valueLabelArray:[UILabel] = []
    
    var labelArray:[UILabel] = []
    
    var sliderArray:[UISlider] = []
    
    let mainBackgroundColor:[UIColor] = [UIColor.white, UIColor.black]
    
    let mainLabelColor: [UIColor] = [UIColor.black, UIColor.orange]
    
    var currentThemeIndex: Int = 0
  
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentThemeIndex == 0 ? .default : .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewColor.layer.cornerRadius = 10
        viewColor.layer.masksToBounds = true
                
        if let value = UserDefaults.standard.object(forKey: "ThemeIndex") as? Int {
            currentThemeIndex = value
        } else {
            UserDefaults.standard.set(1, forKey: "ThemeIndex")
        }
        
        setNeedsStatusBarAppearanceUpdate()
        
        valueLabelArray = [rValueLabel, gValueLabel, bValueLabel]
        sliderArray = [rValueSlider, gValueSlider, bValueSlider]
        labelArray = [rLabel, gLabel, bLabel]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTheme()
        showColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let homeVC = nav.topViewController as? HomeViewController {
            homeVC.delegate = self
        }
    }
    
    @IBAction func OnRefreshAction(_ sender: Any) {
        for i in 0..<3 {
            valueLabelArray[i].text = String(128)
            sliderArray[i].value = 128
        }
        
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
}

extension UILabel {
    func makeRound() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
    }
}

extension UITextField {
    func makeRound() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
    }
}


