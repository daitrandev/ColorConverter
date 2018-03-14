//
//  UtilitiesConverter.swift
//  ColorConverter
//
//  Created by Dai Tran on 10/21/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit

// Typealias for RGB color values
public typealias RGB = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

// Typealias for CMYK color values
public typealias CMYK = (cyan: CGFloat, magenta: CGFloat, yellow: CGFloat, black: CGFloat, alpha: CGFloat)

// Typealias for HSV color values
public typealias HSV = (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)

public class UtilitiesConverter {
    public static var rgb:RGB?
    public static func ConvertRGBToHex(rgb: RGB) -> String {
        
        let red = Int(rgb.red * 255)
        let green = Int(rgb.green * 255)
        let blue = Int(rgb.blue * 255)
        
        let redHex = red == 0 ? "00" : String(red, radix: 16)
        let greenHex = green == 0 ? "00" : String(green, radix: 16)
        let blueHex = blue == 0 ? "00" : String(blue, radix: 16)
        
        let result: String = redHex + greenHex + blueHex
        
        return result.uppercased()
    }
        
    public static func ConvertHexColorToRGB(hexString: String) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var hex = hexString
        if hex.count != 6 {
            for _ in hex.count..<6 {
                hex += "0"
            }
        }
        
        var hexArray = [String]()
        for i in stride(from: 0, to: 6, by: 2) {
            let start = hex.index(hex.startIndex, offsetBy: i)
            let end = hex.index(hex.startIndex, offsetBy: i + 2)
            let range = start..<end
            hexArray.append(String(hex[range]))
        }
        
        var RGBValue = [CGFloat]()
        
        for i in 0..<hexArray.count {
            let dec = Int(hexArray[i], radix: 16)!
            RGBValue.append(CGFloat(dec))
        }

        return (red: RGBValue[0]/255, green: RGBValue[1]/255, blue: RGBValue[2]/255, CGFloat(1))
    }
    
    public static func CMYKtoRGB(c : CGFloat, m : CGFloat, y : CGFloat, k : CGFloat) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let r = (1 - c) * (1 - k)
        let g = (1 - m) * (1 - k)
        let b = (1 - y) * (1 - k)
        return (r, g, b, 1)
    }
    
    public static func RGBtoCMYK(r : CGFloat, g : CGFloat, b : CGFloat) -> (c : CGFloat, m : CGFloat, y : CGFloat, k : CGFloat) {
        
        if r==0 && g==0 && b==0 {
            return (0, 0, 0, 1)
        }
        var c = 1 - r
        var m = 1 - g
        var y = 1 - b
        let minCMY = min(c, m, y)
        c = (c - minCMY) / (1 - minCMY)
        m = (m - minCMY) / (1 - minCMY)
        y = (y - minCMY) / (1 - minCMY)
        return (c, m, y, minCMY)
    }
    
    public static func hsv2rgb(_ hsv: HSV) -> RGB {
        // Converts HSV to a RGB color
        var rgb: RGB = (red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        var r: CGFloat
        var g: CGFloat
        var b: CGFloat
        
        let i = Int(hsv.hue * 6)
        let f = hsv.hue * 6 - CGFloat(i)
        let p = hsv.brightness * (1 - hsv.saturation)
        let q = hsv.brightness * (1 - f * hsv.saturation)
        let t = hsv.brightness * (1 - (1 - f) * hsv.saturation)
        switch (i % 6) {
        case 0: r = hsv.brightness; g = t; b = p; break;
            
        case 1: r = q; g = hsv.brightness; b = p; break;
            
        case 2: r = p; g = hsv.brightness; b = t; break;
            
        case 3: r = p; g = q; b = hsv.brightness; break;
            
        case 4: r = t; g = p; b = hsv.brightness; break;
            
        case 5: r = hsv.brightness; g = p; b = q; break;
            
        default: r = hsv.brightness; g = t; b = p;
        }
        
        rgb.red = r
        rgb.green = g
        rgb.blue = b
        rgb.alpha = hsv.alpha
        return rgb
    }
    
    public static func rgb2hsv(_ rgb: RGB) -> HSV {
        // Converts RGB to a HSV color
        var hsb: HSV = (hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.0)
        
        let rd: CGFloat = rgb.red
        let gd: CGFloat = rgb.green
        let bd: CGFloat = rgb.blue
        
        let maxV: CGFloat = max(rd, max(gd, bd))
        let minV: CGFloat = min(rd, min(gd, bd))
        var h: CGFloat = 0
        var s: CGFloat = 0
        let b: CGFloat = maxV
        
        let d: CGFloat = maxV - minV
        
        s = maxV == 0 ? 0 : d / minV;
        
        if (maxV == minV) {
            h = 0
        } else {
            if (maxV == rd) {
                h = (gd - bd) / d + (gd < bd ? 6 : 0)
            } else if (maxV == gd) {
                h = (bd - rd) / d + 2
            } else if (maxV == bd) {
                h = (rd - gd) / d + 4
            }
            
            h /= 6;
        }
        
        hsb.hue = h
        hsb.saturation = s
        hsb.brightness = b
        hsb.alpha = rgb.alpha
        return hsb
    }
}
